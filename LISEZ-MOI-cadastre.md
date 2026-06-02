# X-UPsarl — Module cadastral (back-end)

Circuit de validation des lots : **Agent (saisie) → Superviseur (vérification) → DG (validation + signature)**.
Mutations de propriété (cession/vente) à double validation. Historique immuable accessible au DG.

## Démarrage

```
cd ~/Documents/x-upsarl
pip3 install -r requirements.txt
python3 app.py
```

Puis ouvrir : **http://127.0.0.1:8000/gube-plan.html**

> ⚠️ On lance désormais `python3 app.py` (et **non plus** `python3 -m http.server`).
> L'application sert à la fois le site et le module cadastre, sur le port 8000.

## Comptes de démonstration

| Rôle        | Identifiant | Mot de passe | Peut faire                                   |
|-------------|-------------|--------------|----------------------------------------------|
| Agent       | `agent`     | `agent123`   | Saisir / corriger un lot, ajouter ayants droit, soumettre, créer une mutation |
| Superviseur | `super`     | `super123`   | Vérifier ou rejeter (1er niveau)             |
| DG          | `dg`        | `dg123`      | Valider et **signer** (2e niveau), voir l'historique global |

## Parcours

1. Page **Plan / Cadastre** → cliquer une zone → cliquer un îlot → liste des lots (le nombre de lots s'affiche sur chaque îlot).
2. Cliquer un lot → fiche. L'**agent** saisit le numéro (modifiable même s'il vient de l'OCR), la superficie, le propriétaire, les ayants droit, puis **soumet**.
3. Le **superviseur** vérifie (ou rejette avec motif).
4. Le **DG** valide en **signant** dans le cadre prévu (ou rejette).
5. Tout **changement de propriétaire** (cession/vente) passe par : agent → superviseur → DG (signature). Le propriétaire n'est mis à jour qu'après validation DG.
6. Chaque action est tracée dans l'**historique** (par lot, et vue globale pour le DG).

## Réinitialiser / reconstruire la base

```
python3 db/init_db.py
```

(Recrée `db/xup.db` : schéma complet + 13 zones + 108 îlots + 3 comptes + 10 lots de l'îlot 1.)

## Important — mots de passe

Les comptes de démo sont à changer avant tout usage réel. Modifier `app.secret_key` dans `app.py`.
Pour la Zone 1, l'îlot 1 est pré-rempli avec 10 lots (vérifiés sur le plan) ; les autres îlots se
remplissent via le rôle Agent (saisie soumise à validation).
