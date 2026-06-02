-- X-UPsarl — Migration 001 : hiérarchie ZONE → ÎLOT → LOT (Anono V001). Additive, non destructive.
PRAGMA foreign_keys = ON;
CREATE TABLE IF NOT EXISTS zone (
  id INTEGER PRIMARY KEY AUTOINCREMENT, village_id INTEGER NOT NULL REFERENCES village(id),
  numero INTEGER NOT NULL, libelle TEXT, composition_ilots TEXT, nb_ilots INTEGER DEFAULT 0,
  superficie REAL, plan_page INTEGER, geojson TEXT, cree_le DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(village_id, numero));
CREATE INDEX IF NOT EXISTS idx_zone_village ON zone(village_id);
CREATE TABLE IF NOT EXISTS ilot (
  id INTEGER PRIMARY KEY AUTOINCREMENT, zone_id INTEGER NOT NULL REFERENCES zone(id),
  numero TEXT NOT NULL, libelle TEXT, nb_lots INTEGER DEFAULT 0, superficie REAL, geojson TEXT,
  cree_le DATETIME DEFAULT CURRENT_TIMESTAMP, UNIQUE(zone_id, numero));
CREATE INDEX IF NOT EXISTS idx_ilot_zone ON ilot(zone_id);
CREATE TABLE IF NOT EXISTS lot (
  id INTEGER PRIMARY KEY AUTOINCREMENT, ilot_id INTEGER NOT NULL REFERENCES ilot(id),
  numero TEXT NOT NULL, superficie REAL,
  statut_foncier TEXT DEFAULT 'Non renseigné', titre_propriete TEXT,
  occupation TEXT DEFAULT 'Non renseigné',
  proprietaire_nom TEXT, proprietaire_prenoms TEXT, proprietaire_contact TEXT, grande_famille TEXT,
  occupant_nom TEXT, occupant_contact TEXT, gps_centroide TEXT, gps_polygone TEXT,
  patrimoine_id INTEGER REFERENCES patrimoine(id), statut_saisie TEXT DEFAULT 'a_saisir',
  operateur_saisie_id INTEGER REFERENCES utilisateur(id),
  cree_le DATETIME DEFAULT CURRENT_TIMESTAMP, modifie_le DATETIME, UNIQUE(ilot_id, numero));
CREATE INDEX IF NOT EXISTS idx_lot_ilot ON lot(ilot_id);
ALTER TABLE patrimoine ADD COLUMN lot_id INTEGER REFERENCES lot(id);
ALTER TABLE contrat_bail ADD COLUMN lot_id INTEGER REFERENCES lot(id);
