-- =========================================================================
-- X-UPsarl — Jeu de données fictives ivoiriennes
-- =========================================================================

-- VILLAGES
INSERT INTO village (code_village, code_court, nom, commune, sous_prefecture,
    chef_nom, chef_prenoms, chef_contact, latitude, longitude,
    superficie_totale, superficie_bail, statut) VALUES
('V001','AO','Anono','Cocody','Cocody','KOUASSI','Bernard','+225 07 08 12 34 56',5.3622,-3.9956, 4800000, 1200000, 'actif'),
('V002','AS','Akouai-Santai','Bingerville','Bingerville','N''GUESSAN','Adou','+225 05 06 78 90 12',5.3500,-3.8800, 3200000, 480000, 'actif'),
('V003','AK','Anonkouakouté','Cocody','Cocody','YAO','Konan','+225 01 02 34 56 78',5.3700,-3.9800, 2700000, 360000, 'actif');

-- QUARTIERS d'Anono
INSERT INTO quartier (village_id, libelle) VALUES
(1,'Anono-Centre'),(1,'Anono-Plateau'),(1,'Anono-Extension'),
(1,'Anono-Lac'),(1,'Anono-Marché'),(1,'Anono-Forêt'),
(2,'Akouai-Santai-Centre'),(2,'Akouai-Santai-Bord-Lac'),
(3,'Anonkouakouté-Village'),(3,'Anonkouakouté-Extension');

-- UTILISATEURS (mots de passe = hash factice 'demo_hash_...')
INSERT INTO utilisateur (identifiant, civilite, nom, prenoms, date_naissance,
    lieu_naissance, nature_piece, numero_piece, nationalite, adresse_postale,
    ville, commune, quartier, telephone, mobile, courriel, mot_de_passe,
    profil, statut_kyc, employeur, fonction, frequence_apport, montant_apport) VALUES
-- Investisseurs
('INV-0001','M.','KOUAME','Jean-Pierre','1982-05-14','Yamoussoukro','CNI','C0012345678','Ivoirienne','08 BP 1234 Abidjan 08','Abidjan','Cocody','Riviera Palmeraie','+225 27 22 44 55 66','+225 07 88 99 11 22','jp.kouame@xup-demo.ci','demo_hash_1','investisseur','valide','SGBCI','Cadre bancaire','Mensuelle',500000),
('INV-0002','Mme','TRAORE','Mariam','1990-11-02','Bouaké','CNI','C0023456789','Ivoirienne','06 BP 5678 Abidjan 06','Abidjan','Plateau','Indénié','+225 27 20 33 44 55','+225 05 66 77 88 99','mariam.traore@xup-demo.ci','demo_hash_2','investisseur','valide','BICICI','Directrice marketing','Trimestrielle',1500000),
('INV-0003','M.','DIABATE','Mamadou','1978-03-22','Korhogo','Passeport','19P234567','Ivoirienne','01 BP 999 Abidjan 01','Abidjan','Marcory','Zone 4','+225 27 21 55 66 77','+225 01 23 45 67 89','mamadou.diabate@xup-demo.ci','demo_hash_3','investisseur','valide','MTN CI','Ingénieur réseau','Mensuelle',250000),
-- Propriétaires-bailleurs villageois
('BAI-0001','M.','KOUASSI','Bernard','1955-07-08','Anono','CNI','C9988776655','Ivoirienne','Village Anono','Abidjan','Cocody','Anono-Centre','+225 27 22 47 80 00','+225 07 08 12 34 56','b.kouassi@xup-demo.ci','demo_hash_4','bailleur','valide',NULL,'Chef de village','Annuelle',NULL),
('BAI-0002','M.','N''GUESSAN','Adou','1962-02-19','Akouai-Santai','CNI','C8877665544','Ivoirienne','Village Akouai-Santai','Bingerville','Bingerville','Centre','+225 27 22 47 80 11','+225 05 06 78 90 12','adou.nguessan@xup-demo.ci','demo_hash_5','bailleur','valide',NULL,'Chef de village','Annuelle',NULL),
-- Opérateurs de saisie
('OPE-0001','M.','BAMBA','Karim','1992-09-30','Abidjan','CNI','C1122334455','Ivoirienne','Cocody','Abidjan','Cocody','Angré 8e Tranche','+225 27 22 90 11 00','+225 07 12 34 56 78','karim.bamba@xupsarl.ci','demo_hash_6','operateur','valide','X-UPsarl','Opérateur terrain','—',NULL),
('OPE-0002','Mlle','OUATTARA','Aminata','1995-04-15','Daloa','CNI','C2233445566','Ivoirienne','Cocody','Abidjan','Cocody','Riviera 3','+225 27 22 90 11 22','+225 07 23 45 67 89','aminata.ouattara@xupsarl.ci','demo_hash_7','operateur','valide','X-UPsarl','Opératrice terrain','—',NULL),
-- Admin
('ADM-0001','M.','KOUADIO','Eric','1980-01-10','Abidjan','CNI','C0099887766','Ivoirienne','Plateau','Abidjan','Plateau','Plateau','+225 27 20 31 00 00','+225 07 00 00 00 01','admin@xupsarl.ci','demo_hash_8','admin','valide','X-UPsarl','DSI','—',NULL);

-- AFFECTATION OPÉRATEURS / VILLAGES
INSERT INTO village_operateur VALUES (1,6),(1,7),(2,6),(3,7);

-- COMPTEURS DE CONTRAT (dernier_yyy = dernier numéro émis)
-- V001 (Anono) = AO093 émis dans le seed (voir patrimoine) — compteur à 93
-- V002 (Akouai-Santai) = AS001 émis — compteur à 1, prochain AS002
-- V003 (Anonkouakouté) = AK012 émis — compteur à 12, prochain AK013
INSERT INTO compteur_contrat (village_id, dernier_yyy) VALUES (1,93),(2,1),(3,12);

-- PATRIMOINE
INSERT INTO patrimoine (identifiant, village_id, statut, zone, lot_numero, ilot_numero,
    superficie, titre_propriete, grande_famille, proprietaire_nom, proprietaire_prenoms,
    proprietaire_naissance, proprietaire_lieu_naiss, proprietaire_piece,
    proprietaire_tel, proprietaire_mobile,
    dotation, loyer_numeraire, nature, souhait, operateur_saisie_id) VALUES
('V001-GUBE-AO091A',1,'Terrain nu','Zone A','Lot 91','Ilot 12',600,'TF-12345/CCD','Famille KOUASSI','KOUASSI','Bernard','1955-07-08','Anono','C9988776655','+225 27 22 47 80 00','+225 07 08 12 34 56',5000000,150000,'Bail emphytéotique','Maisons Basses',6),
('V001-GUBE-AO092A',1,'Maisons Basses','Zone B','Lot 14','Ilot 03',850,'TF-12378/CCD','Famille KOUAME','KOUAME','Daniel','1960-03-12','Anono','C9988770011','+225 27 22 47 80 22','+225 07 33 44 55 66',6500000,180000,'Bail emphytéotique','Maisons Basses',6),
('V001-GUBE-AO093A',1,'Maisons à Etages','Zone A','Lot 22','Ilot 05',720,'TF-12399/CCD','Famille N''DRI','N''DRI','Sylvain','1958-11-25','Anono','C9988770022','+225 27 22 47 80 33','+225 07 44 55 66 77',7500000,220000,'Bail emphytéotique','Maisons à Etages',7),
('V002-GUBE-AS001A',2,'Terrain nu','Zone Lac','Lot 02','Ilot 01',1200,'TF-20001/BG','Famille N''GUESSAN','N''GUESSAN','Adou','1962-02-19','Akouai-Santai','C8877665544','+225 27 22 47 80 11','+225 05 06 78 90 12',8000000,200000,'Bail emphytéotique','Mixte',6),
('V003-GUBE-AK012A',3,'Maisons Basses','Zone Sud','Lot 12','Ilot 02',600,'TF-30025/AK','Famille YAO','YAO','Konan','1959-08-04','Anonkouakouté','C8877665577','+225 27 22 47 80 99','+225 01 02 34 56 78',5500000,160000,'Bail emphytéotique','Maisons Basses',7);

-- AYANTS-DROITS PROPRIÉTAIRE
INSERT INTO ayant_droit_proprietaire (patrimoine_id, nom_prenoms, date_naissance) VALUES
(1,'KOUASSI Marie / 1985-06-12','1985-06-12'),
(1,'KOUASSI Pascal / 1988-09-30','1988-09-30'),
(1,'KOUASSI Christelle / 1992-04-18','1992-04-18'),
(2,'KOUAME Alphonse / 1990-01-22','1990-01-22'),
(2,'KOUAME Sophie / 1994-07-15','1994-07-15');

-- CONTRATS DE BAIL
INSERT INTO contrat_bail (identifiant, village_id, patrimoine_id, statut,
    zone, lot_numero, ilot_numero, superficie, titre_propriete,
    bailleur_nom, bailleur_prenoms, bailleur_naissance, bailleur_lieu_naiss,
    bailleur_piece, bailleur_tel, bailleur_mobile,
    preneur_nom, preneur_prenoms, preneur_naissance, preneur_lieu_naiss,
    preneur_piece, preneur_tel, preneur_mobile,
    type_construction, objet_construction,
    nb_studios, nb_2pieces, nb_3pieces, nb_4pieces, nb_magasins_simples,
    duree_construction_mois, duree_exploitation_mois,
    date_debut_bail, date_fin_bail,
    operateur_saisie_id, statut_workflow) VALUES
('V001-GUBE-AO091A',1,1,'Terrain nu','Zone A','Lot 91','Ilot 12',600,'TF-12345/CCD',
 'KOUASSI','Bernard','1955-07-08','Anono','C9988776655','+225 27 22 47 80 00','+225 07 08 12 34 56',
 'KOUAME','Jean-Pierre','1982-05-14','Yamoussoukro','C0012345678','+225 27 22 44 55 66','+225 07 88 99 11 22',
 'Maisons Basses','Habitation/Commerce',15,5,2,1,3,5,216,'2026-01-15','2044-01-15',6,'actif'),
('V001-GUBE-AO092A',1,2,'Maisons Basses','Zone B','Lot 14','Ilot 03',850,'TF-12378/CCD',
 'KOUAME','Daniel','1960-03-12','Anono','C9988770011','+225 27 22 47 80 22','+225 07 33 44 55 66',
 'TRAORE','Mariam','1990-11-02','Bouaké','C0023456789','+225 27 20 33 44 55','+225 05 66 77 88 99',
 'Maisons à Etages','Habitation',8,4,3,0,0,6,216,'2025-09-10','2043-09-10',6,'actif'),
('V002-GUBE-AS001A',2,4,'Terrain nu','Zone Lac','Lot 02','Ilot 01',1200,'TF-20001/BG',
 'N''GUESSAN','Adou','1962-02-19','Akouai-Santai','C8877665544','+225 27 22 47 80 11','+225 05 06 78 90 12',
 'DIABATE','Mamadou','1978-03-22','Korhogo','19P234567','+225 27 21 55 66 77','+225 01 23 45 67 89',
 'Maisons Basses/Etages','Habitation/Commerce',20,8,4,2,5,7,216,'2026-03-01','2044-03-01',6,'actif'),
('V003-GUBE-AK012A',3,5,'Maisons Basses','Zone Sud','Lot 12','Ilot 02',600,'TF-30025/AK',
 'YAO','Konan','1959-08-04','Anonkouakouté','C8877665577','+225 27 22 47 80 99','+225 01 02 34 56 78',
 'KOUAME','Jean-Pierre','1982-05-14','Yamoussoukro','C0012345678','+225 27 22 44 55 66','+225 07 88 99 11 22',
 'Maisons Basses','Habitation',10,3,2,0,2,5,216,'2025-12-20','2043-12-20',7,'actif');

-- APPARTEMENTS
INSERT INTO appartement (patrimoine_id, numero, type_appt, superficie, loyer_mensuel, statut) VALUES
(1,'A1','Studio',24,75000,'occupe'),
(1,'A2','Studio',24,75000,'occupe'),
(1,'A3','Studio',24,75000,'libre'),
(1,'B1','2 Pièces',45,125000,'occupe'),
(1,'B2','2 Pièces',45,125000,'occupe'),
(2,'C1','3 Pièces',75,180000,'occupe'),
(2,'C2','3 Pièces',75,180000,'libre'),
(2,'M1','Magasin',30,200000,'occupe');

-- LOCATAIRES
INSERT INTO locataire (appartement_id, nom, prenoms, cni, date_naissance, lieu_naissance,
    telephone, mobile, loyer, numero_recu, operateur_saisie_id) VALUES
(1,'KOFFI','Stéphane','C1010101010','1991-04-22','Abidjan','+225 27 22 33 44 55','+225 07 11 22 33 44',75000,'REC-2026-00001',7),
(2,'YAO','Christelle','C1020202020','1989-08-15','Yamoussoukro','+225 27 22 33 55 66','+225 05 22 33 44 55',75000,'REC-2026-00002',7),
(4,'SORO','Ibrahim','C1030303030','1985-11-08','Korhogo','+225 27 22 33 66 77','+225 01 33 44 55 66',125000,'REC-2026-00003',7),
(5,'DIALLO','Aïcha','C1040404040','1993-02-28','Touba','+225 27 22 33 77 88','+225 07 44 55 66 77',125000,'REC-2026-00004',7),
(6,'BAMBA','Souleymane','C1050505050','1987-06-12','Bouaké','+225 27 22 33 88 99','+225 05 55 66 77 88',180000,'REC-2026-00005',6),
(8,'COULIBALY','Awa','C1060606060','1990-10-04','San-Pédro','+225 27 22 33 99 00','+225 01 66 77 88 99',200000,'REC-2026-00006',6);

-- PROJETS D'INVESTISSEMENT
INSERT INTO projet_investissement (nom, type_bail, description, nature_projet, ville, commune,
    village_id, superficie_m2, montant_total, montant_collecte, part_sociale,
    duree_execution_jours, nombre_studios, nombre_chambres, periode_exploitation_ans,
    taux_rentabilite, statut, date_ouverture, date_cloture) VALUES
('BINGERVILLE ANADER','Bail Emphytéotique','Situé en plein cœur de Bingerville, le site en Bail emphytéotique de 600 m² offre toutes les commodités d''un investissement rentable à court terme.','Construction de maisons basses','Abidjan','Bingerville',2,600,150000000,87500000,2500000,150,15,10,18,12.0,'en_collecte','2026-03-15','2026-08-15'),
('ANONO RESIDENCE','Bail Emphytéotique','Programme de construction de logements R+2 sur terrain villageois Anono. 12 studios et 8 appartements 2 pièces.','Construction Maisons à Etages','Abidjan','Cocody',1,850,220000000,165000000,2500000,180,12,8,18,13.5,'en_collecte','2026-02-01','2026-08-01'),
('ANONKOUAKOUTE LOTS','Bail à Construction','Co-financement court de 5 lots viabilisés à Anonkouakouté pour mise en valeur rapide.','Viabilisation et lotissement','Abidjan','Cocody',3,3000,45000000,45000000,1000000,15,0,0,2,15.0,'finance','2026-04-10','2026-04-25'),
('COCODY 2 PLATEAUX','Acquisition en Pleine Propriété','Acquisition groupée d''un immeuble R+3 aux 2 Plateaux Vallons.','Acquisition immeuble existant','Abidjan','Cocody',NULL,1200,650000000,210000000,5000000,90,0,16,99,9.5,'en_collecte','2026-05-01','2026-08-01');

-- SOUSCRIPTIONS
INSERT INTO souscription (investisseur_id, projet_id, montant, date_souscription, statut, moyen_paiement, reference_paiement) VALUES
(1,1,7500000,'2026-03-20','confirmee','Orange Money','OM-2026-003-87654'),
(2,1,5000000,'2026-03-22','confirmee','Virement','VIR-2026-0089'),
(3,1,2500000,'2026-04-02','confirmee','MTN Money','MM-2026-004-22134'),
(1,2,5000000,'2026-02-12','confirmee','Wave','WAV-2026-0245'),
(2,4,10000000,'2026-05-15','payee','Virement','VIR-2026-0123'),
(3,3,1000000,'2026-04-15','confirmee','Orange Money','OM-2026-004-99887');

-- SIGNATURES OTP (exemples)
INSERT INTO signature_otp (utilisateur_id, document_type, document_id, document_hash,
    otp_hash, otp_destinataire, horodatage_emission, horodatage_validation,
    statut, tentatives, adresse_ip) VALUES
(1,'bulletin_souscription',1,'a4e1b87d2cf09e3b2f9a73e8c9d3b8f6e2a1c4d5b6e7f8a9c0d1e2f3a4b5c6d7','HASH_OTP_ANON','+225 07 ** ** ** 22','2026-03-20 14:32:11','2026-03-20 14:33:45','valide',1,'196.46.215.34'),
(2,'contrat_bail',2,'b5f2c98e3df1a4b3a08b84f9d0c4c9e7f3b2d5e6c7f8a9b0c1d2e3f4a5b6c7e8','HASH_OTP_ANON','+225 05 ** ** ** 99','2025-09-10 10:15:22','2025-09-10 10:16:48','valide',1,'196.46.215.78');

-- SITES LITIGIEUX
INSERT INTO site_litigieux (titre_foncier, acd, lotissement, livre_foncier,
    commune, nature_litige, juridiction, statut, description) VALUES
('TF-99001','ACD-2018-345','Lotissement Bingerville Sud','LF-12-345','Bingerville','Litige successoral','TPI Abidjan','Pendant','Conflit entre héritiers réservataires sur 2,5 ha'),
('TF-99022','ACD-2019-089','Lotissement Anono Extension','LF-14-002','Cocody','Double cession','Cour d''Appel Abidjan','Pendant','Terrain vendu deux fois — pourvoi en appel'),
('TF-99055','ACD-2020-554','Lotissement Yopougon Niangon','LF-08-115','Yopougon','Occupation illicite','TPI Abidjan','Décision rendue','Décision rendue, exécution en cours');

-- RAPPORTS DE VÉRIFICATION
INSERT INTO rapport_verification (utilisateur_id, reference, type_service,
    titre_foncier, acd, lotissement, resultat) VALUES
(1,'EREG-2026-000123','etat_foncier','TF-12345','ACD-2018-100','Anono Extension','Foncier libre, aucune inscription d''hypothèque'),
(2,'EREG-2026-000124','etat_foncier','TF-20001','ACD-2019-200','Akouai-Santai','Foncier libre, aucune inscription d''hypothèque');

-- QUITTANCES (3 derniers mois)
INSERT INTO quittance (locataire_id, mois_paye, montant, moyen_paiement, numero_recu, date_paiement, statut) VALUES
(1,'2026-04',75000,'Orange Money','Q-2026-04-001','2026-04-03','paye'),
(1,'2026-05',75000,'Orange Money','Q-2026-05-001','2026-05-04','paye'),
(2,'2026-04',75000,'Wave','Q-2026-04-002','2026-04-02','paye'),
(2,'2026-05',75000,'Wave','Q-2026-05-002','2026-05-05','paye'),
(3,'2026-04',125000,'MTN Money','Q-2026-04-003','2026-04-05','paye'),
(3,'2026-05',125000,'MTN Money','Q-2026-05-003','2026-05-02','paye'),
(4,'2026-05',125000,'Espèces','Q-2026-05-004','2026-05-08','paye'),
(5,'2026-05',180000,'Virement','Q-2026-05-005','2026-05-04','paye');

-- NOTIFICATIONS
INSERT INTO notification (utilisateur_id, canal, sujet, message, lu) VALUES
(1,'in_app','Souscription confirmée','Votre souscription au projet BINGERVILLE ANADER (7 500 000 FCFA) est confirmée.',1),
(1,'email','Nouvel acompte distribué','Un acompte de 95 000 FCFA a été crédité sur votre RIB.',0),
(2,'in_app','Nouvelle opportunité','Le projet ANONO RESIDENCE est ouvert à la souscription.',0),
(4,'sms','Loyer perçu','Loyer d''avril 2026 de 75 000 FCFA réglé par STÉPHANE KOFFI.',1);
