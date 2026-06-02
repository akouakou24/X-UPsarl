# X-UPsarl — Prototype web + base de données

Prototype HTML/CSS/JS multi-pages et schéma SQLite mettant en œuvre les exigences du
cahier des charges **CDC-XUP-WEB-MOB-V1.2** (juin 2026). Charte graphique conforme
aux maquettes fournies (bleu institutionnel, orange/brun, blanc cassé).

## Lancement rapide

1. **Ouvrir le site dans le navigateur** : double-cliquer sur `index.html`.
2. **Explorer la base de données** : `python3 db/query_demo.py`
3. **Recharger la BD à zéro** : supprimer `db/xup.db` puis exécuter dans un shell
   disposant de sqlite3 :
   ```bash
   sqlite3 db/xup.db < db/schema.sql
   sqlite3 db/xup.db < db/seed.sql
   ```

## Arborescence

```
x-upsarl/
├── index.html                     Accueil — Garantir / Augmenter / S'assurer
├── concept.html                   Le Concept — mutualisation / bail / participatif
├── investir.html                  Catalogue des opportunités d'investissement
├── investir-detail.html           Fiche projet (ex. BINGERVILLE ANADER)
├── e-regul.html                   Services de régulation foncière
├── inscription.html               Inscription Investisseur / Propriétaire-Bailleur
├── gube.html                      Le GUBE — Vue d'ensemble du village
├── gube-contrats.html             Liste des contrats de bail
├── gube-nouveau-contrat.html      Saisie d'un nouveau contrat de bail
├── gube-patrimoine.html           Gestion Locative — liste des locataires
├── gube-nouveau-patrimoine.html   Saisie d'un nouveau patrimoine (propriétaire)
├── gube-nouveau-locataire.html    Saisie d'un nouveau locataire
├── contacts.html                  Page Contacts
├── assets/
│   ├── css/style.css              Charte graphique X-UPsarl
│   ├── js/app.js                  Interactions (génération identifiant, calculs)
│   ├── js/data.js                 Données fictives ivoiriennes (miroir de la BD)
│   └── img/logo.svg               Logo X-UPsarl vectoriel
└── db/
    ├── schema.sql                 21 tables : villages, contrats, patrimoine, …
    ├── seed.sql                   Données fictives ivoiriennes
    ├── xup.db                     Base SQLite prête à l'emploi
    └── query_demo.py              Démonstration de requêtes
```

## Couverture fonctionnelle

| Module CDC | Page(s) HTML | Tables BD |
|---|---|---|
| § 6 Site vitrine | index, concept, contacts | — |
| § 7 Investir | investir, investir-detail | `projet_investissement`, `souscription` |
| § 8 e-Régul | e-regul | `site_litigieux`, `rapport_verification` |
| § 9 Le GUBE | gube*, gube-contrats, gube-nouveau-contrat | `village`, `quartier`, `contrat_bail`, `patrimoine`, `ayant_droit_*`, `compteur_contrat` |
| § 9.6 Gestion locative | gube-patrimoine, gube-nouveau-locataire | `appartement`, `locataire`, `quittance` |
| § 9.2 Paramétrage villages | (form village dans gube.html) | `village`, `quartier`, `village_operateur` |
| § 9.3 Nomenclature V00X-GUBE-XXYYYZ | génération auto JS + table BD | `compteur_contrat` |
| § 10 Inscription & KYC | inscription | `utilisateur` (champs `statut_kyc`) |
| § 10.5 Signature OTP | (à brancher dans tunnel) | `signature_otp` |
| § 11 Espaces personnels | (à compléter) | `notification`, `souscription` |

## Génération automatique d'identifiants (CDC § 9.3)

Format normalisé **`V00X-GUBE-XXYYYZ`** :

- `V00X` : code village (V001 = Anono, V002 = Akouai-Santai, V003 = Anonkouakouté)
- `GUBE` : constante du module
- `XX`   : code court 2 lettres (AO, AS, AK)
- `YYY`  : compteur séquentiel par village (table `compteur_contrat`)
- `Z`    : version/variante (A = initial, B,C,… avenants)

Côté JS, la fonction `XUP_genererIdentifiantContrat(codeVillage, variante)` est
exposée par `assets/js/data.js`. Côté BD, le compteur est stocké dans la table
`compteur_contrat` (incrément applicatif lors de l'insert).

## Données fictives ivoiriennes incluses

- 3 villages pilotes : **Anono**, **Akouai-Santai**, **Anonkouakouté**.
- 6 quartiers (Anono-Centre, Anono-Plateau, …).
- 8 utilisateurs (investisseurs, bailleurs, opérateurs, admin) — `INV-0001` à `ADM-0001`.
- 5 patrimoines, 4 contrats, 8 appartements, 6 locataires.
- 4 projets d'investissement : Bingerville Anader, Anono Residence, Anonkouakoute Lots, Cocody 2 Plateaux.
- 6 souscriptions, 8 quittances, 3 sites litigieux, 2 signatures OTP.

## Charte graphique appliquée (CDC § 16.2)

| Couleur | Valeur | Usage |
|---|---|---|
| Bleu institutionnel | `#2280C4` | logo, boutons, accents |
| Bleu secondaire    | `#5BA8DD` | dégradés |
| Orange / Brun      | `#7D4E2D` | onglets GUBE, tab Patrimoine |
| Orange vif         | `#F39200` | CTA Investisseur, SOUSCRIRE |
| Gris fonds         | `#F4F4F4` | sections de formulaire |
| Texte              | `#333333` | corps |

## Limites connues / suite

Ce livrable est un **prototype haute fidélité** : il met en œuvre la couche
présentation et le modèle de données. Les briques suivantes du CDC sont
**stubées** et restent à implémenter pour une mise en production :

- Tunnel de souscription complet en 5 étapes (CDC § 7.4).
- Service de signature électronique OTP réel (CDC § 10.5).
- Passerelles paiement (Orange Money / MTN / Moov / Wave / cartes).
- KYC OCR + liveness check (CDC § 10.2).
- Application mobile iOS/Android (CDC § 13).
- Back-office d'administration (CDC § 12).
- Notifications push/SMS/e-mail.

Ces modules nécessitent un back-end serveur (Node/Python/Java) et des intégrations
tierces hors du périmètre d'une session de prototypage.
