-- =========================================================================
-- X-UPsarl — Migration 002 : circuit de validation des LOTS
-- Maker / Checker / DG · signature · mutations (cession/vente) · historique
-- À appliquer APRÈS migration_001 et seed_anono_zones.
-- =========================================================================
PRAGMA foreign_keys = ON;

-- -------------------------------------------------------------------------
-- 1. COMPTES applicatifs (rôles du circuit cadastral)
--    role : agent (maker) · superviseur (checker) · dg (validation finale)
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS compte (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    login         TEXT UNIQUE NOT NULL,
    mot_de_passe  TEXT NOT NULL,                 -- hash werkzeug
    nom           TEXT NOT NULL,
    role          TEXT NOT NULL CHECK (role IN ('agent','superviseur','dg')),
    actif         INTEGER DEFAULT 1,
    cree_le       DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------------------
-- 2. Colonnes de workflow ajoutées à la table LOT (créée en migration 001)
--    etat : brouillon -> soumis -> verifie -> valide   (ou 'rejete')
-- -------------------------------------------------------------------------
ALTER TABLE lot ADD COLUMN numero_ocr        TEXT;                 -- proposé par OCR
ALTER TABLE lot ADD COLUMN numero_source     TEXT DEFAULT 'manuel';-- 'ocr' | 'manuel'
ALTER TABLE lot ADD COLUMN etat_validation   TEXT DEFAULT 'brouillon';
ALTER TABLE lot ADD COLUMN maker_id          INTEGER REFERENCES compte(id);
ALTER TABLE lot ADD COLUMN checker_id        INTEGER REFERENCES compte(id);
ALTER TABLE lot ADD COLUMN dg_id             INTEGER REFERENCES compte(id);
ALTER TABLE lot ADD COLUMN dg_signature      TEXT;                 -- image (data URL)
ALTER TABLE lot ADD COLUMN motif_rejet       TEXT;
ALTER TABLE lot ADD COLUMN date_soumission   DATETIME;
ALTER TABLE lot ADD COLUMN date_verification DATETIME;
ALTER TABLE lot ADD COLUMN date_validation   DATETIME;

-- -------------------------------------------------------------------------
-- 3. Ayants droit du propriétaire d'un lot
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lot_ayant_droit (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    lot_id        INTEGER NOT NULL REFERENCES lot(id),
    nom_prenoms   TEXT NOT NULL,
    lien          TEXT,                          -- conjoint, enfant, frère...
    date_naissance DATE,
    cree_le       DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- -------------------------------------------------------------------------
-- 4. Mutations (changement de propriétaire) — double validation obligatoire
--    etat : soumis -> verifie (superviseur) -> valide (DG + signature)
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lot_mutation (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    lot_id           INTEGER NOT NULL REFERENCES lot(id),
    type_mutation    TEXT CHECK (type_mutation IN
                        ('Cession','Vente','Succession','Donation','Autre')),
    ancien_proprietaire TEXT,
    nouveau_proprietaire TEXT,
    nouveau_contact  TEXT,
    montant          INTEGER,                    -- XOF (si vente)
    date_mutation    DATE,
    motif            TEXT,
    etat_validation  TEXT DEFAULT 'soumis',      -- soumis | verifie | valide | rejete
    maker_id         INTEGER REFERENCES compte(id),
    checker_id       INTEGER REFERENCES compte(id),
    dg_id            INTEGER REFERENCES compte(id),
    dg_signature     TEXT,
    motif_rejet      TEXT,
    date_soumission  DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_verification DATETIME,
    date_validation  DATETIME
);

-- -------------------------------------------------------------------------
-- 5. Historique / audit IMMUABLE — accessible au DG
--    Une ligne par action ; jamais modifiée ni supprimée par l'applicatif.
-- -------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS lot_historique (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    lot_id        INTEGER REFERENCES lot(id),
    mutation_id   INTEGER REFERENCES lot_mutation(id),
    action        TEXT NOT NULL,                 -- creation, modification, soumission,
                                                 -- verification, validation, rejet,
                                                 -- mutation_soumise/verifiee/validee/rejetee
    champ         TEXT,
    ancienne_valeur TEXT,
    nouvelle_valeur TEXT,
    acteur_id     INTEGER REFERENCES compte(id),
    acteur_nom    TEXT,
    acteur_role   TEXT,
    horodatage    DATETIME DEFAULT CURRENT_TIMESTAMP,
    details       TEXT
);
CREATE INDEX IF NOT EXISTS idx_hist_lot ON lot_historique(lot_id);
CREATE INDEX IF NOT EXISTS idx_mutation_lot ON lot_mutation(lot_id);
CREATE INDEX IF NOT EXISTS idx_adroit_lot ON lot_ayant_droit(lot_id);

-- =========================================================================
-- FIN MIGRATION 002
-- =========================================================================
