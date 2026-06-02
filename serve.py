#!/usr/bin/env python3
"""
X-UPsarl — Serveur de développement local
=========================================

Lance un serveur HTTP qui :
  - sert tous les fichiers du prototype (index.html, assets/, etc.)
  - expose une mini-API REST sur la base SQLite (db/xup.db) :
      GET /api/villages
      GET /api/contrats?village=V001
      GET /api/patrimoines?village=V001
      GET /api/locataires?village=V001
      GET /api/projets
      GET /api/sites-litigieux
      GET /api/stats?village=V001
      POST /api/contrats/identifiant   (génère un nouvel identifiant)

Utilisation :
    python3 serve.py [--port 8000] [--no-open]

Aucune dépendance externe : utilise uniquement la bibliothèque standard Python.
"""
import os
import sys
import json
import sqlite3
import argparse
import webbrowser
from http.server import HTTPServer, SimpleHTTPRequestHandler
from urllib.parse import urlparse, parse_qs

ROOT = os.path.dirname(os.path.abspath(__file__))
DB_PATH = os.path.join(ROOT, 'db', 'xup.db')
SCHEMA  = os.path.join(ROOT, 'db', 'schema.sql')
SEED    = os.path.join(ROOT, 'db', 'seed.sql')


def bootstrap_db():
    """Reconstruit xup.db depuis schema.sql + seed.sql si la base est absente ou vide."""
    need_rebuild = (not os.path.exists(DB_PATH)) or os.path.getsize(DB_PATH) < 1024
    if not need_rebuild:
        return
    print("  • Initialisation de la base SQLite depuis schema.sql + seed.sql...")
    if os.path.exists(DB_PATH):
        try: os.remove(DB_PATH)
        except OSError: pass
    conn = sqlite3.connect(DB_PATH)
    for path in (SCHEMA, SEED):
        if not os.path.exists(path):
            raise FileNotFoundError(f"Fichier manquant : {path}")
        with open(path, encoding='utf-8') as f:
            conn.executescript(f.read())
    conn.commit()
    conn.close()
    print(f"  • Base prête : {DB_PATH}")


def db():
    """Ouvre une connexion SQLite avec accès par nom de colonne."""
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def rows_to_json(rows):
    return [dict(r) for r in rows]


class XUPHandler(SimpleHTTPRequestHandler):

    def __init__(self, *args, **kwargs):
        # Sert le dossier x-upsarl/
        super().__init__(*args, directory=ROOT, **kwargs)

    # Logs plus jolis
    def log_message(self, fmt, *args):
        sys.stdout.write(f"  \033[36m{self.address_string()}\033[0m  {fmt % args}\n")

    def _json(self, payload, status=200):
        body = json.dumps(payload, ensure_ascii=False, indent=2).encode('utf-8')
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Content-Length', str(len(body)))
        self.send_header('Access-Control-Allow-Origin', '*')
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        u = urlparse(self.path)
        if u.path == '/api' or u.path.startswith('/api/'):
            return self._handle_api(u)
        # Sert un fichier statique
        return super().do_GET()

    def do_POST(self):
        u = urlparse(self.path)
        if u.path == '/api/contrats/identifiant':
            length = int(self.headers.get('Content-Length', 0))
            body = self.rfile.read(length) if length else b'{}'
            try:
                data = json.loads(body)
            except Exception:
                data = {}
            village = data.get('village') or 'V001'
            variante = data.get('variante') or 'A'
            with db() as conn:
                row = conn.execute(
                    "SELECT v.id, v.code_village, v.code_court, cc.dernier_yyy "
                    "FROM village v JOIN compteur_contrat cc ON cc.village_id = v.id "
                    "WHERE v.code_village = ?", (village,)).fetchone()
                if not row:
                    return self._json({'error': f'Village {village} inconnu'}, 404)
                nouveau = row['dernier_yyy'] + 1
                ident = f"{row['code_village']}-GUBE-{row['code_court']}{nouveau:03d}{variante}"
                conn.execute(
                    "UPDATE compteur_contrat SET dernier_yyy = ? WHERE village_id = ?",
                    (nouveau, row['id']))
                conn.commit()
                return self._json({
                    'identifiant': ident,
                    'village': village,
                    'numero': nouveau,
                    'variante': variante,
                })
        self.send_error(404, "Endpoint POST inconnu")

    # ---------- Routes API ----------
    def _handle_api(self, u):
        path = u.path
        qs = parse_qs(u.query)
        v = (qs.get('village') or [None])[0]

        try:
            with db() as conn:
                if path == '/api/villages':
                    rows = conn.execute(
                        "SELECT code_village, code_court, nom, commune, "
                        "chef_nom || ' ' || chef_prenoms AS chef, statut "
                        "FROM village ORDER BY code_village").fetchall()
                    return self._json(rows_to_json(rows))

                if path == '/api/stats':
                    if not v:
                        return self._json({'error': 'paramètre village requis'}, 400)
                    contrats   = conn.execute("SELECT count(*) FROM contrat_bail cb JOIN village v ON v.id=cb.village_id WHERE v.code_village=?", (v,)).fetchone()[0]
                    bailleurs  = conn.execute("SELECT count(DISTINCT bailleur_nom||bailleur_prenoms) FROM contrat_bail cb JOIN village v ON v.id=cb.village_id WHERE v.code_village=?", (v,)).fetchone()[0]
                    preneurs   = conn.execute("SELECT count(DISTINCT preneur_nom||preneur_prenoms) FROM contrat_bail cb JOIN village v ON v.id=cb.village_id WHERE v.code_village=?", (v,)).fetchone()[0]
                    locataires = conn.execute("SELECT count(*) FROM locataire l JOIN appartement a ON a.id=l.appartement_id JOIN patrimoine p ON p.id=a.patrimoine_id JOIN village vi ON vi.id=p.village_id WHERE vi.code_village=?", (v,)).fetchone()[0]
                    quartiers  = conn.execute("SELECT count(*) FROM quartier q JOIN village vi ON vi.id=q.village_id WHERE vi.code_village=?", (v,)).fetchone()[0]
                    return self._json({
                        'village': v,
                        'contrats': contrats, 'bailleurs': bailleurs,
                        'preneurs': preneurs, 'locataires': locataires,
                        'quartiers': quartiers,
                    })

                if path == '/api/contrats':
                    if v:
                        rows = conn.execute("""
                            SELECT cb.identifiant, cb.zone, cb.lot_numero, cb.ilot_numero,
                                   cb.superficie, cb.type_construction,
                                   cb.bailleur_nom || ' ' || cb.bailleur_prenoms AS bailleur,
                                   cb.preneur_nom  || ' ' || cb.preneur_prenoms  AS preneur,
                                   cb.date_debut_bail, cb.date_fin_bail, cb.statut_workflow,
                                   cb.date_saisie
                              FROM contrat_bail cb
                              JOIN village vi ON vi.id = cb.village_id
                             WHERE vi.code_village = ?""", (v,)).fetchall()
                    else:
                        rows = conn.execute("""
                            SELECT identifiant, zone, lot_numero, ilot_numero, superficie,
                                   type_construction,
                                   bailleur_nom || ' ' || bailleur_prenoms AS bailleur,
                                   preneur_nom  || ' ' || preneur_prenoms  AS preneur,
                                   date_debut_bail, date_fin_bail, statut_workflow, date_saisie
                              FROM contrat_bail""").fetchall()
                    return self._json(rows_to_json(rows))

                if path == '/api/patrimoines':
                    sql = """SELECT p.identifiant, p.statut, p.zone, p.lot_numero, p.ilot_numero,
                                    p.superficie, p.titre_propriete, p.grande_famille,
                                    p.proprietaire_nom || ' ' || p.proprietaire_prenoms AS proprietaire,
                                    p.dotation, p.loyer_numeraire, p.souhait
                               FROM patrimoine p JOIN village v ON v.id = p.village_id"""
                    if v: rows = conn.execute(sql + " WHERE v.code_village = ?", (v,)).fetchall()
                    else: rows = conn.execute(sql).fetchall()
                    return self._json(rows_to_json(rows))

                if path == '/api/locataires':
                    sql = """SELECT l.id, l.nom || ' ' || l.prenoms AS nom_complet,
                                    a.numero AS appartement, a.type_appt,
                                    p.identifiant AS patrimoine,
                                    p.lot_numero || ' / ' || p.ilot_numero AS lot_ilot,
                                    l.loyer, l.numero_recu, l.date_saisie
                               FROM locataire l
                               JOIN appartement a ON a.id = l.appartement_id
                               JOIN patrimoine p  ON p.id = a.patrimoine_id
                               JOIN village v     ON v.id = p.village_id"""
                    if v: rows = conn.execute(sql + " WHERE v.code_village = ?", (v,)).fetchall()
                    else: rows = conn.execute(sql).fetchall()
                    return self._json(rows_to_json(rows))

                if path == '/api/projets':
                    rows = conn.execute("""
                        SELECT id, nom, type_bail, ville, commune, superficie_m2,
                               montant_total, montant_collecte, part_sociale,
                               duree_execution_jours, nombre_studios, nombre_chambres,
                               periode_exploitation_ans, taux_rentabilite, statut,
                               ROUND(montant_collecte * 100.0 / montant_total, 1) AS pct
                          FROM projet_investissement""").fetchall()
                    return self._json(rows_to_json(rows))

                if path == '/api/sites-litigieux':
                    rows = conn.execute("""
                        SELECT titre_foncier, acd, lotissement, commune,
                               nature_litige, juridiction, statut, description
                          FROM site_litigieux""").fetchall()
                    return self._json(rows_to_json(rows))

                if path == '/api/quittances':
                    rows = conn.execute("""
                        SELECT q.numero_recu, l.nom || ' ' || l.prenoms AS locataire,
                               q.mois_paye, q.montant, q.moyen_paiement,
                               q.date_paiement, q.statut
                          FROM quittance q JOIN locataire l ON l.id = q.locataire_id
                         ORDER BY q.date_paiement DESC""").fetchall()
                    return self._json(rows_to_json(rows))

                if path == '/api':
                    return self._json({
                        'service': 'X-UPsarl API (prototype)',
                        'endpoints': [
                            'GET  /api/villages',
                            'GET  /api/stats?village=V001',
                            'GET  /api/contrats?village=V001',
                            'GET  /api/patrimoines?village=V001',
                            'GET  /api/locataires?village=V001',
                            'GET  /api/projets',
                            'GET  /api/sites-litigieux',
                            'GET  /api/quittances',
                            'POST /api/contrats/identifiant  (body: {"village":"V001","variante":"A"})',
                        ]
                    })
        except sqlite3.Error as e:
            return self._json({'error': str(e)}, 500)

        return self._json({'error': f'route inconnue : {path}'}, 404)


def main():
    p = argparse.ArgumentParser(description='Serveur local X-UPsarl')
    p.add_argument('--port', type=int, default=8000, help='Port HTTP (défaut 8000)')
    p.add_argument('--host', default='127.0.0.1', help='Hôte (défaut 127.0.0.1)')
    p.add_argument('--no-open', action='store_true', help='Ne pas ouvrir le navigateur')
    args = p.parse_args()

    bootstrap_db()

    url = f"http://{args.host}:{args.port}/"
    server = HTTPServer((args.host, args.port), XUPHandler)
    print("\n" + "─" * 70)
    print(f"  X-UPsarl — serveur de développement")
    print("─" * 70)
    print(f"  Site             : {url}")
    print(f"  Documentation API: {url}api")
    print(f"  Base de données  : {DB_PATH}")
    print("─" * 70)
    print("  Ctrl+C pour arrêter")
    print()

    if not args.no_open:
        try:
            webbrowser.open(url)
        except Exception:
            pass

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n  Serveur arrêté.")
        server.server_close()


if __name__ == '__main__':
    main()
