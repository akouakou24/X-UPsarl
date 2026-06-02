#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
X-UPsarl — Back-end cadastral (Flask)
Circuit de validation des lots : Agent (maker) -> Superviseur (checker) -> DG (validation + signature)
Mutations de propriété (cession/vente) avec double validation. Historique immuable accessible au DG.

Lancement :
    cd ~/Documents/x-upsarl
    pip3 install flask
    python3 app.py
    -> http://127.0.0.1:8000/gube-plan.html
Comptes de démo : agent/agent123 · super/super123 · dg/dg123
"""
import os, sqlite3, json
from functools import wraps
from datetime import datetime
from flask import (Flask, request, session, redirect, url_for,
                   render_template_string, send_from_directory, abort, jsonify)
from werkzeug.security import check_password_hash

HERE = os.path.dirname(os.path.abspath(__file__))
DB   = os.path.join(HERE, "db", "xup.db")

app = Flask(__name__, static_folder=None)
app.secret_key = "xup-cadastre-secret-key-change-me"

# --------------------------------------------------------------------------- DB
def db():
    con = sqlite3.connect(DB)
    con.row_factory = sqlite3.Row
    con.execute("PRAGMA foreign_keys=ON")
    return con

def log(con, *, lot_id=None, mutation_id=None, action="", champ=None,
        old=None, new=None, details=None):
    u = session.get("user", {})
    con.execute("""INSERT INTO lot_historique
        (lot_id,mutation_id,action,champ,ancienne_valeur,nouvelle_valeur,
         acteur_id,acteur_nom,acteur_role,details)
        VALUES(?,?,?,?,?,?,?,?,?,?)""",
        (lot_id, mutation_id, action, champ,
         None if old is None else str(old), None if new is None else str(new),
         u.get("id"), u.get("nom"), u.get("role"), details))

# ------------------------------------------------------------------------ AUTH
def login_required(f):
    @wraps(f)
    def w(*a, **k):
        if "user" not in session:
            return redirect(url_for("login", next=request.path))
        return f(*a, **k)
    return w

def role_required(*roles):
    def deco(f):
        @wraps(f)
        def w(*a, **k):
            if "user" not in session:
                return redirect(url_for("login", next=request.path))
            if session["user"]["role"] not in roles:
                return page("Accès refusé",
                    f"<div class='alert'>Action réservée à : {', '.join(roles)}. "
                    f"Vous êtes connecté comme <b>{session['user']['role']}</b>.</div>"
                    "<a class='btn' href='javascript:history.back()'>Retour</a>")
            return f(*a, **k)
        return w
    return deco

# --------------------------------------------------------------------- TEMPLATE
BASE = """<!DOCTYPE html><html lang="fr"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{{title}} — X-UPsarl Cadastre</title>
<link rel="stylesheet" href="/assets/css/style.css">
<style>
:root{--b:#2280C4;--bd:#1A6BA9;--o:#F39200;--br:#7D4E2D;--bg:#F4F4F4;--bo:#D9D9D9;}
body{font-family:Arial,Helvetica,sans-serif;color:#333;margin:0;background:#fff;}
.cad-top{background:var(--b);color:#fff;padding:10px 20px;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:8px;}
.cad-top a{color:#fff;text-decoration:none;}
.cad-top .who{font-size:.85rem;opacity:.95}
.cad-top .badge{background:rgba(255,255,255,.2);padding:2px 10px;border-radius:12px;font-weight:700;font-size:.75rem;text-transform:uppercase;margin-left:6px}
.wrap{max-width:1080px;margin:0 auto;padding:18px 18px 60px;}
.crumb{font-size:.88rem;color:#6b6b6b;margin:6px 0 16px}.crumb a{color:var(--b);text-decoration:none}
h1{color:var(--b);font-size:1.4rem;margin:.2em 0}h2{color:var(--b);font-size:1.1rem}
.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(110px,1fr));gap:10px}
.tile{border:1px solid var(--bo);border-radius:8px;padding:12px;text-align:center;text-decoration:none;color:#333;background:#fff;transition:.15s;display:block}
.tile:hover{border-color:var(--b);box-shadow:0 3px 10px rgba(34,128,196,.15)}
.tile .n{font-weight:700;font-size:1.05rem}.tile .s{font-size:.72rem;color:#6b6b6b;margin-top:3px}
table{border-collapse:collapse;width:100%;font-size:.9rem;background:#fff}
th{background:var(--b);color:#fff;text-align:left;padding:8px}td{border-bottom:1px solid var(--bo);padding:8px}
tr:hover td{background:#f6fbff}
.btn{display:inline-block;background:var(--b);color:#fff;border:none;border-radius:6px;padding:8px 14px;font-weight:600;cursor:pointer;text-decoration:none;font-size:.9rem}
.btn:hover{background:var(--bd)}.btn.o{background:var(--o)}.btn.br{background:var(--br)}.btn.g{background:#1FA12C}.btn.r{background:#D62828}.btn.gray{background:#888}
.badge2{display:inline-block;padding:2px 9px;border-radius:11px;font-size:.74rem;font-weight:700}
.b-brouillon{background:#eee;color:#666}.b-soumis{background:#FCE7C8;color:#8a5a12}
.b-verifie{background:#dbeafe;color:#1A6BA9}.b-valide{background:#dcfce7;color:#15803d}.b-rejete{background:#fee2e2;color:#b91c1c}
form.card,.card{background:#fff;border:1px solid var(--bo);border-radius:10px;padding:18px;margin:14px 0}
label{display:block;font-size:.8rem;color:#555;margin:10px 0 3px;font-weight:600}
input,select,textarea{width:100%;padding:8px;border:1px solid var(--bo);border-radius:6px;font-size:.9rem;box-sizing:border-box}
.row{display:grid;grid-template-columns:1fr 1fr;gap:12px}
.alert{background:#fee2e2;color:#b91c1c;border:1px solid #fca5a5;border-radius:8px;padding:12px;margin:10px 0}
.ok{background:#dcfce7;color:#15803d;border:1px solid #86efac;border-radius:8px;padding:12px;margin:10px 0}
.hist{font-size:.84rem}.hist td{padding:6px 8px}
.sigbox{border:1px dashed var(--b);border-radius:8px;background:#fafdff}
.muted{color:#6b6b6b;font-size:.82rem}
.flow{display:flex;gap:6px;align-items:center;margin:8px 0;font-size:.8rem;flex-wrap:wrap}
.flow span{padding:3px 10px;border-radius:12px;background:#eee;color:#777}
.flow span.on{background:var(--b);color:#fff}
</style></head><body>
<div class="cad-top">
  <div><a href="/gube-plan.html">◂ Plan / Cadastre</a> &nbsp;|&nbsp; <a href="/cadastre/zone/1">Zones</a>
    {% if user.role=='dg' %} &nbsp;|&nbsp; <a href="/cadastre/historique">Historique global</a>{% endif %}</div>
  <div class="who">{% if user %}{{user.nom}} <span class="badge">{{user.role}}</span>
     &nbsp; <a href="/cadastre/logout">Déconnexion</a>{% endif %}</div>
</div>
<div class="wrap">{{ body|safe }}</div></body></html>"""

def page(title, body):
    return render_template_string(BASE, title=title, body=body,
                                  user=session.get("user"))

def etat_badge(e):
    lib = {"brouillon":"Brouillon","soumis":"Soumis (à vérifier)",
           "verifie":"Vérifié (à valider DG)","valide":"Validé DG","rejete":"Rejeté"}
    return f"<span class='badge2 b-{e}'>{lib.get(e,e)}</span>"

def flow(e):
    order = ["brouillon","soumis","verifie","valide"]
    cur = order.index(e) if e in order else -1
    names = ["Saisie","Soumis","Vérifié","Validé DG"]
    out = []
    for i,n in enumerate(names):
        out.append(f"<span class='{'on' if i<=cur and e!='rejete' else ''}'>{n}</span>")
        if i < len(names)-1: out.append("›")
    if e=="rejete": out.append("&nbsp; <span class='badge2 b-rejete'>Rejeté</span>")
    return "<div class='flow'>"+" ".join(out)+"</div>"

# ------------------------------------------------------------------- ROUTES web
@app.route("/cadastre/login", methods=["GET","POST"])
def login():
    msg = ""
    if request.method == "POST":
        con = db()
        r = con.execute("SELECT * FROM compte WHERE login=? AND actif=1",
                        (request.form.get("login","").strip(),)).fetchone()
        if r and check_password_hash(r["mot_de_passe"], request.form.get("pwd","")):
            session["user"] = {"id":r["id"],"nom":r["nom"],"role":r["role"],"login":r["login"]}
            con.close()
            return redirect(request.args.get("next") or url_for("zone", znum=1))
        con.close(); msg = "<div class='alert'>Identifiants incorrects.</div>"
    body = f"""<h1>Connexion — Cadastre</h1>{msg}
    <form class="card" method="post" style="max-width:380px">
      <label>Identifiant</label><input name="login" autofocus>
      <label>Mot de passe</label><input type="password" name="pwd">
      <div style="margin-top:14px"><button class="btn">Se connecter</button></div>
      <p class="muted" style="margin-top:14px">Comptes de démo :<br>
      agent / agent123 (saisie) · super / super123 (vérification) · dg / dg123 (validation)</p>
    </form>"""
    return page("Connexion", body)

@app.route("/cadastre/logout")
def logout():
    session.pop("user", None)
    return redirect(url_for("login"))

@app.route("/cadastre/zone/<int:znum>")
@login_required
def zone(znum):
    con = db()
    z = con.execute("SELECT * FROM zone WHERE village_id=1 AND numero=?", (znum,)).fetchone()
    if not z: con.close(); abort(404)
    ilots = con.execute("""SELECT i.*,
        (SELECT COUNT(*) FROM lot WHERE lot.ilot_id=i.id) AS nlots,
        (SELECT COUNT(*) FROM lot WHERE lot.ilot_id=i.id AND etat_validation='valide') AS nvalides
        FROM ilot i WHERE i.zone_id=? ORDER BY CAST(i.numero AS INT), i.numero""",(z["id"],)).fetchall()
    con.close()
    tiles = ""
    for i in ilots:
        extra = (" · %d✓" % i["nvalides"]) if i["nvalides"] else ""
        tiles += (f"<a class='tile' href='/cadastre/ilot/{i['id']}'>"
                  f"<div class='n'>Îlot {i['numero']}</div>"
                  f"<div class='s'>{i['nlots']} lot(s){extra}</div></a>")
    body = f"""<div class="crumb"><a href="/gube-plan.html">Plan</a> › Zone {znum}</div>
    <h1>Zone {znum} — Îlots</h1>
    <p class="muted">{z['composition_ilots']}</p>
    <div class="grid">{tiles}</div>"""
    return page(f"Zone {znum}", body)

@app.route("/cadastre/ilot/<int:ilot_id>")
@login_required
def ilot(ilot_id):
    con = db()
    i = con.execute("""SELECT i.*, z.numero AS znum FROM ilot i
        JOIN zone z ON i.zone_id=z.id WHERE i.id=?""",(ilot_id,)).fetchone()
    if not i: con.close(); abort(404)
    lots = con.execute("SELECT * FROM lot WHERE ilot_id=? ORDER BY id",(ilot_id,)).fetchall()
    con.close()
    rows = "".join(
        f"<tr><td><a href='/cadastre/lot/{l['id']}'>{l['numero']}</a></td>"
        f"<td>{l['proprietaire_nom'] or '—'} {l['proprietaire_prenoms'] or ''}</td>"
        f"<td>{(str(l['superficie'])+' m²') if l['superficie'] else '—'}</td>"
        f"<td>{etat_badge(l['etat_validation'] or 'brouillon')}</td></tr>" for l in lots)
    add = ("<a class='btn o' href='/cadastre/ilot/%d/ajout'>+ Ajouter un lot</a>" % ilot_id
           if session["user"]["role"]=="agent" else "")
    body = f"""<div class="crumb"><a href="/gube-plan.html">Plan</a> ›
      <a href="/cadastre/zone/{i['znum']}">Zone {i['znum']}</a> › Îlot {i['numero']}</div>
    <h1>Îlot {i['numero']} — {len(lots)} lot(s)</h1>
    <p>{add}</p>
    <table><tr><th>N° Lot</th><th>Propriétaire</th><th>Superficie</th><th>État</th></tr>{rows or '<tr><td colspan=4 class=muted>Aucun lot. </td></tr>'}</table>"""
    return page(f"Îlot {i['numero']}", body)

@app.route("/cadastre/ilot/<int:ilot_id>/ajout", methods=["POST","GET"])
@role_required("agent")
def ajout_lot(ilot_id):
    con = db()
    if request.method=="POST":
        num = request.form.get("numero","").strip() or "Lxx"
        src = "ocr" if request.form.get("source")=="ocr" else "manuel"
        cur = con.execute("""INSERT INTO lot(ilot_id,numero,numero_source,etat_validation,statut_saisie)
                             VALUES(?,?,?,'brouillon','en_cours')""",(ilot_id,num,src))
        lid = cur.lastrowid
        log(con, lot_id=lid, action="creation", champ="numero", new=num,
            details=f"Lot créé (source numéro: {src})")
        con.execute("UPDATE ilot SET nb_lots=(SELECT COUNT(*) FROM lot WHERE lot.ilot_id=?) WHERE id=?",(ilot_id,ilot_id))
        con.commit(); con.close()
        return redirect(url_for("lot_detail", lot_id=lid))
    con.close()
    body = f"""<h1>Ajouter un lot</h1>
    <form class="card" method="post" style="max-width:460px">
      <label>Numéro du lot</label><input name="numero" placeholder="ex : 245 (laisser vide si inconnu)">
      <label>Origine du numéro</label>
      <select name="source"><option value="manuel">Saisie manuelle</option>
        <option value="ocr">Proposé par OCR (à confirmer)</option></select>
      <div style="margin-top:14px"><button class="btn">Créer le lot</button>
        <a class="btn gray" href="/cadastre/ilot/{ilot_id}">Annuler</a></div>
    </form>"""
    return page("Ajouter un lot", body)

@app.route("/cadastre/lot/<int:lot_id>")
@login_required
def lot_detail(lot_id):
    con = db()
    l = con.execute("""SELECT l.*, i.numero AS inum, z.numero AS znum, i.id AS iid
        FROM lot l JOIN ilot i ON l.ilot_id=i.id JOIN zone z ON i.zone_id=z.id
        WHERE l.id=?""",(lot_id,)).fetchone()
    if not l: con.close(); abort(404)
    ad = con.execute("SELECT * FROM lot_ayant_droit WHERE lot_id=? ORDER BY id",(lot_id,)).fetchall()
    muts = con.execute("SELECT * FROM lot_mutation WHERE lot_id=? ORDER BY id DESC",(lot_id,)).fetchall()
    hist = con.execute("""SELECT * FROM lot_historique WHERE lot_id=? OR mutation_id IN
        (SELECT id FROM lot_mutation WHERE lot_id=?) ORDER BY id DESC""",(lot_id,lot_id)).fetchall()
    con.close()
    role = session["user"]["role"]
    e = l["etat_validation"] or "brouillon"
    can_edit  = role=="agent" and e in ("brouillon","rejete","valide")
    can_check = role=="superviseur" and e=="soumis"
    can_dg    = role=="dg" and e=="verifie"

    # --- bloc édition (agent) ---
    edit = ""
    if can_edit:
        edit = f"""<form class="card" method="post" action="/cadastre/lot/{lot_id}/save">
          <h2>Saisie / correction (Agent)</h2>
          <div class="row">
            <div><label>N° de lot {'<span class=muted>(proposé OCR : '+l['numero_ocr']+')</span>' if l['numero_ocr'] else ''}</label>
              <input name="numero" value="{l['numero'] or ''}"></div>
            <div><label>Superficie (m²)</label><input name="superficie" value="{l['superficie'] or ''}"></div>
          </div>
          <div class="row">
            <div><label>Propriétaire — Nom</label><input name="pnom" value="{l['proprietaire_nom'] or ''}"></div>
            <div><label>Propriétaire — Prénoms</label><input name="pprenoms" value="{l['proprietaire_prenoms'] or ''}"></div>
          </div>
          <div class="row">
            <div><label>Contact propriétaire</label><input name="pcontact" value="{l['proprietaire_contact'] or ''}"></div>
            <div><label>Grande famille</label><input name="famille" value="{l['grande_famille'] or ''}"></div>
          </div>
          <div class="row">
            <div><label>Statut foncier</label>
              <select name="statut">{_opts(['Non renseigné','Titre Foncier','ACD','Attestation villageoise',"Lettre d'attribution",'En cours','Litige','Libre'], l['statut_foncier'])}</select></div>
            <div><label>Occupation</label>
              <select name="occupation">{_opts(['Non renseigné','Bâti','Non bâti','Réservé','Espace public'], l['occupation'])}</select></div>
          </div>
          <div style="margin-top:14px">
            <button class="btn" name="action" value="save">Enregistrer (brouillon)</button>
            <button class="btn o" name="action" value="submit">Enregistrer et soumettre ▸</button>
          </div>
        </form>
        <form class="card" method="post" action="/cadastre/lot/{lot_id}/adroit">
          <h2>Ajouter un ayant droit</h2>
          <div class="row"><div><label>Nom & prénoms</label><input name="nom" required></div>
          <div><label>Lien</label><input name="lien" placeholder="conjoint, enfant..."></div></div>
          <div style="margin-top:10px"><button class="btn br">Ajouter</button></div>
        </form>"""

    # --- actions checker / dg ---
    act = ""
    if can_check:
        act = f"""<form class="card" method="post" action="/cadastre/lot/{lot_id}/verifier">
          <h2>Vérification (Superviseur)</h2>
          <p class="muted">Contrôlez les informations saisies, puis transmettez au DG ou rejetez.</p>
          <button class="btn g" name="action" value="ok">✓ Vérifier et transmettre au DG</button>
          <input name="motif" placeholder="motif si rejet" style="margin-top:10px">
          <button class="btn r" name="action" value="rejet" style="margin-top:8px">Rejeter</button>
        </form>"""
    if can_dg:
        act = f"""<form class="card" method="post" action="/cadastre/lot/{lot_id}/valider" onsubmit="return sig()">
          <h2>Validation finale (Directeur Général)</h2>
          <p class="muted">Signez dans le cadre ci-dessous puis validez. La signature est horodatée et conservée.</p>
          <canvas id="sg" width="420" height="130" class="sigbox" style="touch-action:none"></canvas><br>
          <button type="button" class="btn gray" onclick="clr()">Effacer</button>
          <input type="hidden" name="signature" id="sigdata">
          <div style="margin-top:12px">
            <button class="btn g" name="action" value="ok">✓ Valider et signer</button>
            <input name="motif" placeholder="motif si rejet" style="margin-top:10px">
            <button class="btn r" name="action" value="rejet" style="margin-top:8px">Rejeter</button>
          </div>
          {SIG_JS}
        </form>"""

    # --- mutation (cession / vente) ---
    mut_form = ""
    if role=="agent" and e=="valide":
        mut_form = f"""<form class="card" method="post" action="/cadastre/lot/{lot_id}/mutation">
          <h2>Changement de propriétaire (cession / vente)</h2>
          <p class="muted">Soumis à double validation : Superviseur puis DG (signature).</p>
          <div class="row">
            <div><label>Type</label><select name="type">{_opts(['Cession','Vente','Succession','Donation','Autre'])}</select></div>
            <div><label>Montant (XOF, si vente)</label><input name="montant"></div>
          </div>
          <div class="row">
            <div><label>Nouveau propriétaire</label><input name="nouveau" required></div>
            <div><label>Contact</label><input name="contact"></div>
          </div>
          <label>Motif / référence acte</label><input name="motif">
          <div style="margin-top:12px"><button class="btn o">Soumettre la mutation ▸</button></div>
        </form>"""

    # mutations existantes + actions
    mrows = ""
    for m in muts:
        a = ""
        if role=="superviseur" and m["etat_validation"]=="soumis":
            a = (f"<form method=post action='/cadastre/mutation/{m['id']}/verifier' style='display:inline'>"
                 f"<button class='btn g'>Vérifier</button></form>")
        if role=="dg" and m["etat_validation"]=="verifie":
            a = f"<a class='btn g' href='/cadastre/mutation/{m['id']}/valider'>Valider + signer</a>"
        mrows += (f"<tr><td>{m['type_mutation']}</td><td>{m['ancien_proprietaire'] or '—'} → "
                  f"<b>{m['nouveau_proprietaire']}</b></td><td>{etat_badge_mut(m['etat_validation'])}</td>"
                  f"<td>{a}</td></tr>")
    mut_table = (f"<div class='card'><h2>Mutations</h2><table><tr><th>Type</th><th>Transfert</th>"
                 f"<th>État</th><th></th></tr>{mrows}</table></div>") if muts else ""

    # ayants droit
    adlist = "".join(f"<li>{x['nom_prenoms']} <span class='muted'>({x['lien'] or '—'})</span></li>" for x in ad)
    adblock = f"<div class='card'><h2>Ayants droit</h2><ul>{adlist or '<li class=muted>Aucun</li>'}</ul></div>"

    # historique
    hrows = "".join(
        f"<tr><td>{h['horodatage']}</td><td>{h['acteur_nom'] or '—'} "
        f"<span class='muted'>({h['acteur_role'] or ''})</span></td><td>{h['action']}</td>"
        f"<td>{(h['details'] or '')}{(' · '+h['champ']+': '+(h['ancienne_valeur'] or '')+' → '+(h['nouvelle_valeur'] or '')) if h['champ'] else ''}</td></tr>"
        for h in hist)
    histblock = (f"<div class='card'><h2>Historique</h2>"
                 f"<table class='hist'><tr><th>Date</th><th>Acteur</th><th>Action</th><th>Détail</th></tr>"
                 f"{hrows or '<tr><td colspan=4 class=muted>—</td></tr>'}</table></div>")

    sig_view = ""
    if l["dg_signature"]:
        sig_view = (f"<div class='card'><h2>Signature DG</h2>"
                    f"<img src='{l['dg_signature']}' style='max-width:300px;border:1px solid #ddd'><br>"
                    f"<span class='muted'>Validé le {l['date_validation'] or ''}</span></div>")

    info = f"""<div class="card">
      <h2>Lot {l['numero']} — Îlot {l['inum']} (Zone {l['znum']})</h2>
      {flow(e)} {etat_badge(e)}
      {('<div class=alert>Motif de rejet : '+l['motif_rejet']+'</div>') if e=='rejete' and l['motif_rejet'] else ''}
      <p><b>Propriétaire :</b> {(l['proprietaire_nom'] or '—')} {l['proprietaire_prenoms'] or ''}
       &nbsp;·&nbsp; <b>Superficie :</b> {(str(l['superficie'])+' m²') if l['superficie'] else '—'}
       &nbsp;·&nbsp; <b>Statut :</b> {l['statut_foncier'] or '—'}</p>
    </div>"""

    body = (f"""<div class="crumb"><a href="/gube-plan.html">Plan</a> ›
      <a href="/cadastre/zone/{l['znum']}">Zone {l['znum']}</a> ›
      <a href="/cadastre/ilot/{l['iid']}">Îlot {l['inum']}</a> › Lot {l['numero']}</div>
      <h1>Fiche du lot</h1>""" + info + sig_view + edit + act + mut_form + mut_table + adblock + histblock)
    return page(f"Lot {l['numero']}", body)

def _opts(values, current=None):
    return "".join(f"<option {'selected' if v==current else ''}>{v}</option>" for v in values)

def etat_badge_mut(e):
    lib={"soumis":"Soumise (à vérifier)","verifie":"Vérifiée (à valider DG)","valide":"Validée DG","rejete":"Rejetée"}
    cls={"soumis":"b-soumis","verifie":"b-verifie","valide":"b-valide","rejete":"b-rejete"}.get(e,"b-brouillon")
    return f"<span class='badge2 {cls}'>{lib.get(e,e)}</span>"

SIG_JS = """<script>
var c=document.getElementById('sg'),x=c.getContext('2d'),d=0;
x.lineWidth=2;x.strokeStyle='#0b3a5b';
function pos(e){var r=c.getBoundingClientRect();var t=e.touches?e.touches[0]:e;return[t.clientX-r.left,t.clientY-r.top];}
function dn(e){d=1;var p=pos(e);x.beginPath();x.moveTo(p[0],p[1]);e.preventDefault();}
function mv(e){if(!d)return;var p=pos(e);x.lineTo(p[0],p[1]);x.stroke();e.preventDefault();}
function up(){d=0;}
c.addEventListener('mousedown',dn);c.addEventListener('mousemove',mv);window.addEventListener('mouseup',up);
c.addEventListener('touchstart',dn);c.addEventListener('touchmove',mv);c.addEventListener('touchend',up);
function clr(){x.clearRect(0,0,c.width,c.height);}
function sig(){var btn=event.submitter;if(btn&&btn.value==='rejet')return true;
  var blank=document.createElement('canvas');blank.width=c.width;blank.height=c.height;
  if(c.toDataURL()===blank.toDataURL()){alert('Veuillez signer avant de valider.');return false;}
  document.getElementById('sigdata').value=c.toDataURL();return true;}
</script>"""

# --------------------------------------------------------------- ACTIONS (POST)
@app.route("/cadastre/lot/<int:lot_id>/save", methods=["POST"])
@role_required("agent")
def lot_save(lot_id):
    con = db()
    l = con.execute("SELECT * FROM lot WHERE id=?",(lot_id,)).fetchone()
    fields = {"numero":"numero","superficie":"superficie","proprietaire_nom":"pnom",
              "proprietaire_prenoms":"pprenoms","proprietaire_contact":"pcontact",
              "grande_famille":"famille","statut_foncier":"statut","occupation":"occupation"}
    for col, fld in fields.items():
        new = request.form.get(fld,"").strip()
        old = l[col]
        if (str(old or "") != new):
            con.execute(f"UPDATE lot SET {col}=? WHERE id=?",(new or None,lot_id))
            log(con, lot_id=lot_id, action="modification", champ=col, old=old, new=new)
    con.execute("UPDATE lot SET modifie_le=CURRENT_TIMESTAMP WHERE id=?",(lot_id,))
    action = request.form.get("action")
    if action=="submit":
        con.execute("""UPDATE lot SET etat_validation='soumis', maker_id=?, date_soumission=CURRENT_TIMESTAMP,
                       statut_saisie='complet' WHERE id=?""",(session["user"]["id"],lot_id))
        log(con, lot_id=lot_id, action="soumission", details="Soumis pour vérification")
    con.commit(); con.close()
    return redirect(url_for("lot_detail", lot_id=lot_id))

@app.route("/cadastre/lot/<int:lot_id>/adroit", methods=["POST"])
@role_required("agent")
def lot_adroit(lot_id):
    con = db(); nom=request.form.get("nom","").strip()
    if nom:
        con.execute("INSERT INTO lot_ayant_droit(lot_id,nom_prenoms,lien) VALUES(?,?,?)",
                    (lot_id,nom,request.form.get("lien","").strip() or None))
        log(con, lot_id=lot_id, action="ayant_droit_ajout", new=nom)
        con.commit()
    con.close(); return redirect(url_for("lot_detail", lot_id=lot_id))

@app.route("/cadastre/lot/<int:lot_id>/verifier", methods=["POST"])
@role_required("superviseur")
def lot_verifier(lot_id):
    con = db()
    if request.form.get("action")=="rejet":
        con.execute("UPDATE lot SET etat_validation='rejete', motif_rejet=? WHERE id=?",
                    (request.form.get("motif","").strip() or "Non précisé",lot_id))
        log(con, lot_id=lot_id, action="rejet", details="Rejeté par superviseur: "+request.form.get("motif",""))
    else:
        con.execute("""UPDATE lot SET etat_validation='verifie', checker_id=?,
                       date_verification=CURRENT_TIMESTAMP, motif_rejet=NULL WHERE id=?""",
                    (session["user"]["id"],lot_id))
        log(con, lot_id=lot_id, action="verification", details="Vérifié, transmis au DG")
    con.commit(); con.close()
    return redirect(url_for("lot_detail", lot_id=lot_id))

@app.route("/cadastre/lot/<int:lot_id>/valider", methods=["POST"])
@role_required("dg")
def lot_valider(lot_id):
    con = db()
    if request.form.get("action")=="rejet":
        con.execute("UPDATE lot SET etat_validation='rejete', motif_rejet=? WHERE id=?",
                    (request.form.get("motif","").strip() or "Non précisé",lot_id))
        log(con, lot_id=lot_id, action="rejet", details="Rejeté par DG: "+request.form.get("motif",""))
    else:
        con.execute("""UPDATE lot SET etat_validation='valide', dg_id=?, dg_signature=?,
                       date_validation=CURRENT_TIMESTAMP, statut_saisie='valide' WHERE id=?""",
                    (session["user"]["id"], request.form.get("signature",""), lot_id))
        log(con, lot_id=lot_id, action="validation", details="Validé et signé par le DG")
    con.commit(); con.close()
    return redirect(url_for("lot_detail", lot_id=lot_id))

# ----- mutations
@app.route("/cadastre/lot/<int:lot_id>/mutation", methods=["POST"])
@role_required("agent")
def mutation_create(lot_id):
    con = db()
    l = con.execute("SELECT proprietaire_nom,proprietaire_prenoms FROM lot WHERE id=?",(lot_id,)).fetchone()
    ancien = f"{l['proprietaire_nom'] or ''} {l['proprietaire_prenoms'] or ''}".strip()
    cur = con.execute("""INSERT INTO lot_mutation(lot_id,type_mutation,ancien_proprietaire,
        nouveau_proprietaire,nouveau_contact,montant,motif,maker_id,etat_validation)
        VALUES(?,?,?,?,?,?,?,?,'soumis')""",
        (lot_id,request.form.get("type"),ancien,request.form.get("nouveau","").strip(),
         request.form.get("contact","").strip(),request.form.get("montant") or None,
         request.form.get("motif","").strip(),session["user"]["id"]))
    log(con, lot_id=lot_id, mutation_id=cur.lastrowid, action="mutation_soumise",
        old=ancien, new=request.form.get("nouveau",""), details="Mutation soumise")
    con.commit(); con.close()
    return redirect(url_for("lot_detail", lot_id=lot_id))

@app.route("/cadastre/mutation/<int:mid>/verifier", methods=["POST"])
@role_required("superviseur")
def mutation_verifier(mid):
    con = db(); m=con.execute("SELECT * FROM lot_mutation WHERE id=?",(mid,)).fetchone()
    con.execute("""UPDATE lot_mutation SET etat_validation='verifie', checker_id=?,
                   date_verification=CURRENT_TIMESTAMP WHERE id=?""",(session["user"]["id"],mid))
    log(con, lot_id=m["lot_id"], mutation_id=mid, action="mutation_verifiee", details="Mutation vérifiée")
    con.commit(); con.close()
    return redirect(url_for("lot_detail", lot_id=m["lot_id"]))

@app.route("/cadastre/mutation/<int:mid>/valider", methods=["GET","POST"])
@role_required("dg")
def mutation_valider(mid):
    con = db(); m=con.execute("SELECT * FROM lot_mutation WHERE id=?",(mid,)).fetchone()
    if request.method=="POST":
        if request.form.get("action")=="rejet":
            con.execute("UPDATE lot_mutation SET etat_validation='rejete', motif_rejet=? WHERE id=?",
                        (request.form.get("motif","").strip() or "Non précisé",mid))
            log(con, lot_id=m["lot_id"], mutation_id=mid, action="mutation_rejetee")
        else:
            con.execute("""UPDATE lot_mutation SET etat_validation='valide', dg_id=?, dg_signature=?,
                           date_validation=CURRENT_TIMESTAMP WHERE id=?""",
                        (session["user"]["id"],request.form.get("signature",""),mid))
            # applique le changement de propriétaire au lot
            con.execute("""UPDATE lot SET proprietaire_nom=?, proprietaire_prenoms='',
                           proprietaire_contact=? WHERE id=?""",
                        (m["nouveau_proprietaire"], m["nouveau_contact"], m["lot_id"]))
            log(con, lot_id=m["lot_id"], mutation_id=mid, action="mutation_validee",
                old=m["ancien_proprietaire"], new=m["nouveau_proprietaire"],
                details="Mutation validée et signée par le DG ; propriétaire mis à jour")
        con.commit(); con.close()
        return redirect(url_for("lot_detail", lot_id=m["lot_id"]))
    con.close()
    body = f"""<h1>Validation de mutation (DG)</h1>
    <form class="card" method="post" onsubmit="return sig()">
      <p>Transfert : <b>{m['ancien_proprietaire'] or '—'}</b> → <b>{m['nouveau_proprietaire']}</b>
      ({m['type_mutation']}{', '+str(m['montant'])+' XOF' if m['montant'] else ''})</p>
      <p class="muted">Signez puis validez.</p>
      <canvas id="sg" width="420" height="130" class="sigbox" style="touch-action:none"></canvas><br>
      <button type="button" class="btn gray" onclick="clr()">Effacer</button>
      <input type="hidden" name="signature" id="sigdata">
      <div style="margin-top:12px"><button class="btn g" name="action" value="ok">✓ Valider et signer</button>
      <input name="motif" placeholder="motif si rejet" style="margin-top:10px">
      <button class="btn r" name="action" value="rejet" style="margin-top:8px">Rejeter</button></div>
      {SIG_JS}
    </form>"""
    return page("Validation mutation", body)

# ----- historique global (DG)
@app.route("/cadastre/historique")
@role_required("dg")
def historique():
    con = db()
    h = con.execute("""SELECT hh.*, l.numero AS lnum FROM lot_historique hh
        LEFT JOIN lot l ON hh.lot_id=l.id ORDER BY hh.id DESC LIMIT 500""").fetchall()
    con.close()
    rows="".join(f"<tr><td>{x['horodatage']}</td><td>Lot {x['lnum'] or '—'}</td>"
        f"<td>{x['acteur_nom'] or '—'} <span class=muted>({x['acteur_role'] or ''})</span></td>"
        f"<td>{x['action']}</td><td>{x['details'] or ''}</td></tr>" for x in h)
    return page("Historique global",
        f"<h1>Historique global (accès DG)</h1><table class='hist'>"
        f"<tr><th>Date</th><th>Lot</th><th>Acteur</th><th>Action</th><th>Détail</th></tr>{rows}</table>")

# ----- résolveur îlot (depuis la page plan) : zone+numéro -> fiche îlot
@app.route("/cadastre/go")
@login_required
def go_ilot():
    znum = request.args.get("zone","1")
    num  = request.args.get("num","")
    con = db()
    r = con.execute("""SELECT i.id FROM ilot i JOIN zone z ON i.zone_id=z.id
        WHERE z.village_id=1 AND z.numero=? AND i.numero=?""",(znum,num)).fetchone()
    con.close()
    if not r: abort(404)
    return redirect(url_for("ilot", ilot_id=r["id"]))

# ----- API compteurs pour la page plan
@app.route("/cadastre/api/zone/<int:znum>/counts")
def api_counts(znum):
    con = db()
    rows = con.execute("""SELECT i.numero AS num,
        (SELECT COUNT(*) FROM lot WHERE lot.ilot_id=i.id) AS n
        FROM ilot i JOIN zone z ON i.zone_id=z.id WHERE z.village_id=1 AND z.numero=?""",(znum,)).fetchall()
    con.close()
    return jsonify({r["num"]: r["n"] for r in rows})

# ----- fichiers statiques (sert le site existant sur le même port)
@app.route("/")
def home(): return redirect("/index.html")

@app.route("/<path:fp>")
def static_files(fp):
    full = os.path.join(HERE, fp)
    if os.path.isfile(full):
        return send_from_directory(HERE, fp)
    abort(404)

if __name__ == "__main__":
    print("X-UPsarl Cadastre — http://127.0.0.1:8000  (Ctrl+C pour arrêter)")
    app.run(host="0.0.0.0", port=8000, debug=True)
