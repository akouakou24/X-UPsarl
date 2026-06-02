-- =========================================================================
-- X-UPsarl — Migration 003 : documents terrain des lots
-- Les FICHIERS sont stockés sur disque (dossier uploads/) ; seules les
-- MÉTADONNÉES sont en base → base légère et performante.
-- =========================================================================
PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS lot_document (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    lot_id        INTEGER NOT NULL REFERENCES lot(id),
    type_document TEXT,                       -- TF, ACD, attestation, photo...
    nom_fichier   TEXT NOT NULL,
    chemin        TEXT NOT NULL,              -- chemin sur le serveur
    taille        INTEGER,                    -- octets
    mime          TEXT,
    uploaded_by   INTEGER REFERENCES compte(id),
    uploaded_nom  TEXT,
    cree_le       DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_doc_lot ON lot_document(lot_id);
