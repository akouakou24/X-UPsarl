#!/usr/bin/env python3
"""Reconstruit xup.db proprement : schéma + zones/îlots + workflow + comptes + lots îlot 1."""
import sqlite3, os
from werkzeug.security import generate_password_hash
HERE=os.path.dirname(os.path.abspath(__file__))
DB=os.path.join(HERE,"xup.db")
open(DB,"wb").close()  # vide le fichier existant (suppression interdite par le mount)
con=sqlite3.connect(DB); cur=con.cursor()
for sqlfile in ["schema.sql","seed.sql","migration_001_zones_ilots_lots.sql",
                "seed_anono_zones.sql","migration_002_lots_workflow.sql","migration_003_documents.sql"]:
    cur.executescript(open(os.path.join(HERE,sqlfile),encoding="utf-8").read())
    print("appliqué:",sqlfile)
# Comptes du circuit
comptes=[("agent","agent123","BAMBA Karim (Agent)","agent"),
         ("super","super123","OUATTARA Aminata (Superviseur)","superviseur"),
         ("dg","dg123","KOUADIO Eric (Directeur Général)","dg")]
for login,pwd,nom,role in comptes:
    cur.execute("INSERT INTO compte(login,mot_de_passe,nom,role) VALUES(?,?,?,?)",
                (login,generate_password_hash(pwd,method="pbkdf2:sha256"),nom,role))
# îlot 1 (zone 1) = 10 lots vérifiés sur le plan
iid=cur.execute("SELECT i.id FROM ilot i JOIN zone z ON i.zone_id=z.id WHERE z.village_id=1 AND z.numero=1 AND i.numero='1'").fetchone()[0]
for k in range(1,11):
    cur.execute("""INSERT INTO lot(ilot_id,numero,etat_validation,statut_saisie)
                   VALUES(?,?, 'brouillon','a_saisir')""",(iid,f"L{k:02d}"))
cur.execute("UPDATE ilot SET nb_lots=(SELECT COUNT(*) FROM lot WHERE lot.ilot_id=ilot.id)")
con.commit()
print("\n--- Récapitulatif ---")
print("zones :",cur.execute("SELECT COUNT(*) FROM zone").fetchone()[0])
print("îlots :",cur.execute("SELECT COUNT(*) FROM ilot").fetchone()[0])
print("lots  :",cur.execute("SELECT COUNT(*) FROM lot").fetchone()[0])
print("comptes:",[r[0] for r in cur.execute("SELECT login FROM compte")])
print("îlot 1 -> lots:",[r[0] for r in cur.execute("SELECT numero FROM lot WHERE ilot_id=? ORDER BY numero",(iid,))])
con.close()
