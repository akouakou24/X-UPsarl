# X-UPsarl — Déploiement (Netlify + PWA)

## Architecture en deux parties

La plateforme se compose de deux briques :

1. **Site statique (public) → Netlify.** Pages d'accueil, Le Concept, Investir, e-Régul (+ simulateurs), GUBE, et le **visualiseur Plan / Cadastre** (zones, plan global, zoom). Installable en **PWA** et consultable hors-ligne.
2. **Module de gestion cadastrale (back-end Flask) → hébergeur Python.** Connexion, circuit de validation Agent → Superviseur → DG, signatures, upload de documents, historique. **Netlify n'exécute pas Python** : ce module va sur un hébergeur séparé (Render, Railway, un VPS…).

Sur la version Netlify seule, le plan est consultable ; la gestion des lots affiche un message invitant à se connecter au serveur applicatif.

---

## A. Mettre le site statique en ligne sur Netlify

### Méthode 1 — Glisser-déposer (la plus simple)

1. Aller sur https://app.netlify.com → **Add new site** → **Deploy manually**.
2. Glisser le **dossier `x-upsarl`** dans la zone de dépôt.
3. Netlify publie le site et donne une URL (ex. `https://xupsarl.netlify.app`).

> Avant de glisser, supprimez/excluez les fichiers serveur si vous voulez un dépôt propre : `app.py`, `serve.py`, `db/`, `uploads/`, `Plan Anono/`, `__pycache__/`. Le fichier `netlify.toml` bloque déjà l'accès à ces chemins même s'ils sont présents.

### Méthode 2 — Via GitHub (déploiement automatique à chaque push)

1. Sur Netlify : **Add new site** → **Import an existing project** → **GitHub** → choisir le dépôt `X-UPsarl`.
2. Build command : *(laisser vide)* · Publish directory : `.`
3. **Deploy**. À chaque `git push`, Netlify redéploie automatiquement.

La configuration (`netlify.toml`) gère déjà : URLs propres (`/gube`, `/gube-plan`…), page 404, en-têtes de sécurité, en-têtes PWA, et le blocage des fichiers sensibles.

---

## B. PWA (application installable + hors-ligne)

C'est déjà en place : `manifest.webmanifest`, `service-worker.js`, icônes (`assets/img/icon-192/512`). Une fois le site en HTTPS sur Netlify :

- **Mobile (Android/iOS)** : ouvrir le site → menu du navigateur → « Ajouter à l'écran d'accueil ».
- **Ordinateur (Chrome/Edge)** : icône d'installation dans la barre d'adresse.
- **Hors-ligne** : les pages déjà visitées restent consultables sans connexion.

> La PWA exige le HTTPS — automatique sur Netlify. En local (`http://127.0.0.1`), le service worker fonctionne aussi (exception navigateur pour localhost).

---

## C. Héberger le module de gestion (back-end Flask)

Exemple avec **Render** (gratuit pour démarrer) :

1. Créer un compte sur https://render.com → **New** → **Web Service** → connecter le dépôt GitHub.
2. **Build command** : `pip install -r requirements.txt && python3 db/init_db.py`
3. **Start command** : `gunicorn app:app` (`gunicorn` est déjà dans `requirements.txt`).
4. Déployer. Render fournit une URL (ex. `https://xupsarl-cadastre.onrender.com`).

> SQLite convient pour démarrer, mais le disque de Render est éphémère : pour la production, prévoir une base persistante (PostgreSQL) et un stockage de fichiers persistant (les uploads). Le schéma est déjà compatible PostgreSQL.

### Relier le site Netlify au back-end

Deux options :
- **Simple** : héberger TOUT le projet sur Render (Flask sert aussi les pages statiques) et utiliser Render comme adresse unique. Netlify devient alors la vitrine publique uniquement.
- **Proxy** : sur Netlify, rediriger `/cadastre/*` vers le back-end. Remplacer dans `netlify.toml` la règle `/cadastre/*` par :

```toml
[[redirects]]
  from = "/cadastre/*"
  to = "https://VOTRE-BACKEND.onrender.com/cadastre/:splat"
  status = 200
  force = true
```

---

## Récapitulatif de ce qui fonctionne où

| Fonction | Netlify (statique) | Back-end Flask |
|---|:---:|:---:|
| Site public, e-Régul + simulateurs | ✅ | ✅ |
| Visualiseur Plan / Cadastre (zones, plan global, zoom) | ✅ | ✅ |
| PWA (installable, hors-ligne) | ✅ | — |
| Connexion + rôles (Agent/Superviseur/DG) | ❌ | ✅ |
| Saisie des lots, validation, signature, historique | ❌ | ✅ |
| Upload de documents terrain | ❌ | ✅ |

> Avant mise en production : changer les mots de passe de démo et `app.secret_key` dans `app.py`.
