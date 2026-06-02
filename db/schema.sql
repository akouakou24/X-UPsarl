-- =========================================================================
-- X-UPsarl — Plateforme d'intermédiation immobilière et foncière
-- Schéma de base de données (SQLite / compatible PostgreSQL)
-- Référence : CDC-XUP-WEB-MOB-V1.2
-- =========================================================================

PRAGMA foreign_keys = ON;

-- -------------------------------------------------------------------------
-- 1. UTILISATEURS ET AUTHENTIFICATION
-- -------------------------------------------------------------------------

CREATE TABLE utilisateur (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    identifiant     TEXT UNIQUE NOT NULL,            -- Code unique utilisateur
    civilite        TEXT CHECK (civilite IN ('M.', 'Mme', 'Mlle')),
    nom             TEXT NOT NULL,
    prenoms         TEXT NOT NULL,
    date_naissance  DATE,
    lieu_naissance  TEXT,
    nature_piece    TEXT,                            -- CNI, passeport, attestation
    numero_piece    TEXT,
    nationalite     TEXT DEFAULT 'Ivoirienne',
    adresse_postale TEXT,
    pays_residence  TEXT DEFAULT 'Côte d''Ivoire',
    ville           TEXT,
    commune         TEXT,
    quartier        TEXT,
    telephone       TEXT,
    mobile          TEXT,
    courriel        TEXT UNIQUE NOT NULL,
    mot_de_passe    TEXT NOT NULL,                   -- Hash bcrypt/argon2
    profil          TEXT NOT NULL CHECK (profil IN
                       ('investisseur','bailleur','locataire',
                        'operateur','admin','partenaire')),
    statut_kyc      TEXT DEFAULT 'en_attente'
                       CHECK (statut_kyc IN
                       ('en_attente','en_cours','valide','rejete')),
    statut_compte   TEXT DEFAULT 'actif'
                       CHECK (statut_compte IN
                       ('actif','suspendu','archive')),
    double_auth     INTEGER DEFAULT 0,               -- 0/1
    employeur       TEXT,
    fonction        TEXT,
    frequence_apport TEXT,
    montant_apport  INTEGER,                          -- en XOF
    cree_le         DATETIME DEFAULT CURRENT_TIMESTAMP,
    modifie_le      DATETIME
);

CREATE INDEX idx_utilisateur_courriel ON utilisateur(courriel);
CREATE INDEX idx_utilisateur_profil   ON utilisateur(profil);

-- -------------------------------------------------------------------------
-- 2. PARAMÉTRAGE DES VILLAGES (CDC § 9.2)
-- -------------------------------------------------------------------------

CREATE TABLE village (
    id                INTEGER PRIMARY KEY AUTOINCREMENT,
    code_village      TEXT UNIQUE NOT NULL,           -- V001, V002, V003...
    code_court        TEXT UNIQUE NOT NULL,           -- AO, AS, AK (2 lettres)
    nom               TEXT NOT NULL,
    commune           TEXT,
    sous_prefecture   TEXT,
    chef_nom          TEXT,
    chef_prenoms      TEXT,
    chef_contact      TEXT,
    latitude          REAL,
    longitude         REAL,
    superficie_totale REAL,                           -- en m²
    superficie_bail   REAL,
    photo_bandeau     TEXT,
    statut            TEXT DEFAULT 'actif'
                          CHECK (statut IN ('actif','suspendu','archive')),
    cree_le           DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE quartier (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    village_id  INTEGER NOT NULL REFERENCES village(id),
    libelle     TEXT NOT NULL,
    UNIQUE(village_id, libelle)
);

CREATE TABLE village_operateur (
    village_id     INTEGER NOT NULL REFERENCES village(id),
    utilisateur_id INTEGER NOT NULL REFERENCES utilisateur(id),
    PRIMARY KEY (village_id, utilisateur_id)
);

-- -------------------------------------------------------------------------
-- 3. PATRIMOINE FONCIER ET BÂTI (CDC § 9.6)
-- -------------------------------------------------------------------------

CREATE TABLE patrimoine (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    identifiant     TEXT UNIQUE NOT NULL,             -- V00X-GUBE-XXYYYZ
    village_id      INTEGER NOT NULL REFERENCES village(id),
    statut          TEXT CHECK (statut IN
                       ('Terrain nu','Maisons Basses',
                        'Maisons à Etages','Mixte')),
    zone            TEXT,
    lot_numero      TEXT,
    ilot_numero     TEXT,
    superficie      REAL,
    titre_propriete TEXT,
    grande_famille  TEXT,
    proprietaire_nom        TEXT,
    proprietaire_prenoms    TEXT,
    proprietaire_naissance  DATE,
    proprietaire_lieu_naiss TEXT,
    proprietaire_piece      TEXT,
    proprietaire_tel        TEXT,
    proprietaire_mobile     TEXT,
    dotation        INTEGER,                          -- en XOF
    loyer_numeraire INTEGER,                          -- en XOF
    nature          TEXT,
    souhait         TEXT CHECK (souhait IN
                       ('Maisons Basses','Maisons à Etages','Mixte')),
    operateur_saisie_id INTEGER REFERENCES utilisateur(id),
    cree_le         DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE ayant_droit_proprietaire (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    patrimoine_id INTEGER NOT NULL REFERENCES patrimoine(id),
    nom_prenoms   TEXT NOT NULL,
    date_naissance DATE
);

-- -------------------------------------------------------------------------
-- 4. CONTRATS DE BAIL EMPHYTÉOTIQUE (CDC § 9.5)
-- -------------------------------------------------------------------------

CREATE TABLE contrat_bail (
    id                INTEGER PRIMARY KEY AUTOINCREMENT,
    identifiant       TEXT UNIQUE NOT NULL,           -- V00X-GUBE-XXYYYZ
    village_id        INTEGER NOT NULL REFERENCES village(id),
    patrimoine_id     INTEGER REFERENCES patrimoine(id),
    statut            TEXT CHECK (statut IN
                          ('Terrain nu','Maisons Basses',
                           'Maisons à Etages','Mixte')),
    zone              TEXT,
    lot_numero        TEXT,
    ilot_numero       TEXT,
    superficie        REAL,
    titre_propriete   TEXT,

    -- Bailleur
    bailleur_nom      TEXT,
    bailleur_prenoms  TEXT,
    bailleur_naissance DATE,
    bailleur_lieu_naiss TEXT,
    bailleur_piece    TEXT,
    bailleur_tel      TEXT,
    bailleur_mobile   TEXT,

    -- Preneur (investisseur)
    preneur_nom       TEXT,
    preneur_prenoms   TEXT,
    preneur_naissance DATE,
    preneur_lieu_naiss TEXT,
    preneur_piece     TEXT,
    preneur_tel       TEXT,
    preneur_mobile    TEXT,

    -- Détails sur la concession
    type_construction TEXT,                           -- Maisons Basses / à Etages / Mixte
    objet_construction TEXT,                          -- Habitation/Commerce/Hôtel/Autres

    -- Composition (nombre)
    nb_entree_couche      INTEGER DEFAULT 0,
    nb_studios            INTEGER DEFAULT 0,
    nb_2pieces            INTEGER DEFAULT 0,
    nb_3pieces            INTEGER DEFAULT 0,
    nb_4pieces            INTEGER DEFAULT 0,
    nb_magasins_simples   INTEGER DEFAULT 0,
    nb_magasins_mezzanine INTEGER DEFAULT 0,
    nb_autres             INTEGER DEFAULT 0,
    -- TOTAL_MAISONS calculé en applicatif

    -- Durées
    duree_construction_mois  INTEGER,
    duree_exploitation_mois  INTEGER,
    date_debut_bail          DATE,
    date_fin_bail            DATE,                    -- Calculée

    operateur_saisie_id INTEGER REFERENCES utilisateur(id),
    date_saisie         DATETIME DEFAULT CURRENT_TIMESTAMP,
    statut_workflow     TEXT DEFAULT 'saisi'
                            CHECK (statut_workflow IN
                            ('saisi','valide_superviseur','signe','actif','clos'))
);

CREATE INDEX idx_contrat_village ON contrat_bail(village_id);
CREATE INDEX idx_contrat_identifiant ON contrat_bail(identifiant);

CREATE TABLE ayant_droit_bailleur (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    contrat_id   INTEGER NOT NULL REFERENCES contrat_bail(id),
    nom_prenoms  TEXT NOT NULL,
    date_naissance DATE
);

CREATE TABLE ayant_droit_preneur (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    contrat_id   INTEGER NOT NULL REFERENCES contrat_bail(id),
    nom_prenoms  TEXT NOT NULL,
    date_naissance DATE
);

-- -------------------------------------------------------------------------
-- 5. GESTION LOCATIVE (CDC § 9.6.2/3)
-- -------------------------------------------------------------------------

CREATE TABLE appartement (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    patrimoine_id   INTEGER NOT NULL REFERENCES patrimoine(id),
    numero          TEXT NOT NULL,                    -- ex : A1, B12
    type_appt       TEXT CHECK (type_appt IN
                       ('Studio','2 Pièces','3 Pièces','4 Pièces',
                        'Entrée-couché','Magasin','Magasin Mezzanine')),
    superficie      REAL,
    loyer_mensuel   INTEGER,                          -- en XOF
    statut          TEXT DEFAULT 'libre'
                       CHECK (statut IN ('libre','occupe','reserve'))
);

CREATE TABLE locataire (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    appartement_id  INTEGER NOT NULL REFERENCES appartement(id),
    nom             TEXT NOT NULL,
    prenoms         TEXT NOT NULL,
    cni             TEXT,
    date_naissance  DATE,
    lieu_naissance  TEXT,
    telephone       TEXT,
    mobile          TEXT,
    loyer           INTEGER,
    numero_recu     TEXT,
    date_saisie     DATETIME DEFAULT CURRENT_TIMESTAMP,
    operateur_saisie_id INTEGER REFERENCES utilisateur(id)
);

-- -------------------------------------------------------------------------
-- 6. ENCAISSEMENTS / QUITTANCEMENT (CDC § 9.7)
-- -------------------------------------------------------------------------

CREATE TABLE quittance (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    locataire_id  INTEGER NOT NULL REFERENCES locataire(id),
    mois_paye     TEXT NOT NULL,                      -- AAAA-MM
    montant       INTEGER NOT NULL,
    moyen_paiement TEXT CHECK (moyen_paiement IN
                       ('Orange Money','MTN Money','Moov Money','Wave',
                        'Espèces','Virement','Carte')),
    numero_recu   TEXT UNIQUE,
    date_paiement DATE NOT NULL,
    statut        TEXT DEFAULT 'paye'
                       CHECK (statut IN ('paye','en_retard','impaye')),
    pdf_url       TEXT
);

-- -------------------------------------------------------------------------
-- 7. CATALOGUE D'INVESTISSEMENT (CDC § 7)
-- -------------------------------------------------------------------------

CREATE TABLE projet_investissement (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    nom             TEXT NOT NULL,                    -- ex : Bingerville Anader
    type_bail       TEXT CHECK (type_bail IN
                       ('Bail Emphytéotique','Bail à Construction',
                        'Acquisition en Pleine Propriété')),
    description     TEXT,
    nature_projet   TEXT,
    ville           TEXT,
    commune         TEXT,
    village_id      INTEGER REFERENCES village(id),
    superficie_m2   REAL,
    montant_total   INTEGER NOT NULL,                 -- en XOF
    montant_collecte INTEGER DEFAULT 0,
    part_sociale    INTEGER,                          -- ticket minimum
    duree_execution_jours INTEGER,
    nombre_studios  INTEGER,
    nombre_chambres INTEGER,
    periode_exploitation_ans INTEGER,
    taux_rentabilite REAL,                            -- %
    image_principale TEXT,
    statut          TEXT DEFAULT 'en_collecte'
                       CHECK (statut IN
                       ('en_collecte','finance','livre','en_exploitation','rembourse')),
    date_ouverture  DATE,
    date_cloture    DATE,
    cree_le         DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE souscription (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    investisseur_id INTEGER NOT NULL REFERENCES utilisateur(id),
    projet_id       INTEGER NOT NULL REFERENCES projet_investissement(id),
    montant         INTEGER NOT NULL,
    date_souscription DATE NOT NULL,
    statut          TEXT DEFAULT 'en_attente'
                       CHECK (statut IN
                       ('en_attente','payee','confirmee','en_exploitation',
                        'remboursee','en_defaut')),
    moyen_paiement  TEXT,
    reference_paiement TEXT,
    signature_otp_ref TEXT,
    pdf_certificat  TEXT
);

-- -------------------------------------------------------------------------
-- 8. SIGNATURE ÉLECTRONIQUE OTP (CDC § 10.5)
-- -------------------------------------------------------------------------

CREATE TABLE signature_otp (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    utilisateur_id  INTEGER NOT NULL REFERENCES utilisateur(id),
    document_type   TEXT NOT NULL,                    -- bulletin_souscription, contrat_bail...
    document_id     INTEGER,                          -- FK polymorphique
    document_hash   TEXT NOT NULL,                    -- SHA-256
    otp_hash        TEXT NOT NULL,                    -- hash de l'OTP
    otp_canal       TEXT DEFAULT 'SMS'
                       CHECK (otp_canal IN ('SMS','Email','WhatsApp')),
    otp_destinataire TEXT,                            -- numéro masqué
    horodatage_emission DATETIME NOT NULL,
    horodatage_validation DATETIME,
    statut          TEXT CHECK (statut IN
                       ('emis','valide','invalide','expire')),
    tentatives      INTEGER DEFAULT 0,
    adresse_ip      TEXT,
    user_agent      TEXT,
    coord_gps       TEXT,                             -- lat,lon
    pdf_signe       TEXT                              -- chemin du PDF/A signé
);

-- -------------------------------------------------------------------------
-- 9. e-RÉGUL (CDC § 8)
-- -------------------------------------------------------------------------

CREATE TABLE site_litigieux (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    titre_foncier TEXT,
    acd          TEXT,
    lotissement  TEXT,
    livre_foncier TEXT,
    commune      TEXT,
    nature_litige TEXT,
    juridiction  TEXT,
    statut       TEXT,
    description  TEXT
);

CREATE TABLE rapport_verification (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    utilisateur_id INTEGER NOT NULL REFERENCES utilisateur(id),
    reference     TEXT UNIQUE NOT NULL,
    type_service  TEXT,                               -- etat_foncier, securisation...
    titre_foncier TEXT,
    acd           TEXT,
    lotissement   TEXT,
    resultat      TEXT,
    pdf_url       TEXT,
    date_emission DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------------------
-- 10. NOTIFICATIONS ET JOURNAUX
-- -------------------------------------------------------------------------

CREATE TABLE notification (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    utilisateur_id INTEGER NOT NULL REFERENCES utilisateur(id),
    canal         TEXT CHECK (canal IN ('email','sms','push','in_app')),
    sujet         TEXT,
    message       TEXT,
    lu            INTEGER DEFAULT 0,
    cree_le       DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_log (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    utilisateur_id INTEGER REFERENCES utilisateur(id),
    action       TEXT NOT NULL,
    table_nom    TEXT,
    enregistrement_id INTEGER,
    adresse_ip   TEXT,
    horodatage   DATETIME DEFAULT CURRENT_TIMESTAMP,
    details      TEXT                                  -- JSON
);

-- -------------------------------------------------------------------------
-- 11. SÉQUENCES D'IDENTIFIANTS DE CONTRAT PAR VILLAGE (CDC § 9.3)
-- -------------------------------------------------------------------------

CREATE TABLE compteur_contrat (
    village_id INTEGER PRIMARY KEY REFERENCES village(id),
    dernier_yyy INTEGER DEFAULT 0                     -- 0..999
);

-- =========================================================================
-- FIN DU SCHÉMA
-- =========================================================================
