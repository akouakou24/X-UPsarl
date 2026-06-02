#!/usr/bin/env python3
"""
X-UPsarl — Démonstration de requêtes SQL sur la base xup.db
Lance simplement :  python3 query_demo.py
"""
import sqlite3, os, sys

DB = os.path.join(os.path.dirname(__file__), 'xup.db')

def section(title):
    print('\n' + '=' * 72)
    print(' ' + title)
    print('=' * 72)

def tabulate(cursor):
    cols = [c[0] for c in cursor.description]
    rows = cursor.fetchall()
    widths = [max(len(str(c)), *(len(str(r[i])) for r in rows)) if rows else len(str(c))
              for i, c in enumerate(cols)]
    print(' | '.join(c.ljust(widths[i]) for i, c in enumerate(cols)))
    print('-+-'.join('-' * w for w in widths))
    for r in rows:
        print(' | '.join(str(r[i]).ljust(widths[i]) for i in range(len(cols))))

def main():
    if not os.path.exists(DB):
        print(f"ERREUR : base introuvable à {DB}")
        sys.exit(1)

    conn = sqlite3.connect(DB)

    section("Villages paramétrés (CDC § 9.2)")
    tabulate(conn.execute(
        "SELECT code_village, code_court, nom, commune, statut FROM village"))

    section("Compteurs séquentiels par village (CDC § 9.3)")
    tabulate(conn.execute("""
        SELECT v.code_village, v.code_court, v.nom, c.dernier_yyy
          FROM village v JOIN compteur_contrat c ON c.village_id = v.id"""))

    section("Patrimoine (avec identifiants V00X-GUBE-XXYYYZ)")
    tabulate(conn.execute("""
        SELECT identifiant, statut, lot_numero, ilot_numero, superficie,
               proprietaire_nom, proprietaire_prenoms
          FROM patrimoine"""))

    section("Contrats de bail actifs")
    tabulate(conn.execute("""
        SELECT identifiant,
               bailleur_nom || ' ' || bailleur_prenoms AS bailleur,
               preneur_nom  || ' ' || preneur_prenoms  AS preneur,
               type_construction,
               date_debut_bail, date_fin_bail
          FROM contrat_bail
         WHERE statut_workflow IN ('actif','signe')"""))

    section("Locataires & loyers mensuels")
    tabulate(conn.execute("""
        SELECT l.nom || ' ' || l.prenoms AS locataire,
               a.numero AS appartement, a.type_appt,
               l.loyer
          FROM locataire l JOIN appartement a ON a.id = l.appartement_id"""))

    section("Projets d'investissement et collecte")
    tabulate(conn.execute("""
        SELECT nom, type_bail,
               montant_total AS objectif,
               montant_collecte AS collecte,
               ROUND(montant_collecte * 100.0 / montant_total, 1) AS pct_pct,
               taux_rentabilite AS taux,
               statut
          FROM projet_investissement"""))

    section("Souscriptions confirmées")
    tabulate(conn.execute("""
        SELECT u.identifiant AS investisseur,
               p.nom AS projet,
               s.montant, s.date_souscription, s.moyen_paiement
          FROM souscription s
          JOIN utilisateur u ON u.id = s.investisseur_id
          JOIN projet_investissement p ON p.id = s.projet_id"""))

    section("Sites litigieux (e-Régul)")
    tabulate(conn.execute(
        "SELECT titre_foncier, commune, nature_litige, statut FROM site_litigieux"))

    section("Quittances récentes")
    tabulate(conn.execute("""
        SELECT q.numero_recu, l.nom || ' ' || l.prenoms AS locataire,
               q.mois_paye, q.montant, q.moyen_paiement, q.statut
          FROM quittance q JOIN locataire l ON l.id = q.locataire_id
         ORDER BY q.date_paiement DESC LIMIT 8"""))

    section("Démonstration — Génération d'un nouvel identifiant de contrat")
    # Récupère le dernier compteur pour le village V001 et propose le suivant
    cur = conn.execute("""
        SELECT v.code_village, v.code_court, c.dernier_yyy
          FROM village v JOIN compteur_contrat c ON c.village_id = v.id
         WHERE v.code_village = 'V001'""")
    code_v, code_c, dernier = cur.fetchone()
    nouveau_yyy = dernier + 1
    nouvel_id = f"{code_v}-GUBE-{code_c}{nouveau_yyy:03d}A"
    print(f"  Prochain identifiant pour {code_v} ({code_c}) : {nouvel_id}")

    conn.close()
    print("\nFin de la démonstration.")

if __name__ == '__main__':
    main()
