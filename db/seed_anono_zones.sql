-- X-UPsarl — Seed Anono : 13 zones + 108 îlots. Village Anono = id 1.
INSERT INTO zone (village_id,numero,libelle,composition_ilots,nb_ilots,plan_page) VALUES
(1,1,'Zone 1','ilôts 1 à 7 - 9 à 12 - 20 - 69 à 70 - 76 à 77 Bis',17,1),
(1,2,'Zone 2','ilôts 29 à 30 - 33 à 34 - 65 Bis à 68',8,2),
(1,3,'Zone 3','ilôts 65 - 95 à 98 - 101 à 103',8,3),
(1,4,'Zone 4','ilôts 104 à 108',5,4),
(1,5,'Zone 5','ilôts 26 à 27 - 31 à 32 - 35 à 36 - 99 à 100',8,5),
(1,6,'Zone 6','ilôts 42 à 48 - 50 à 51 Bis',10,6),
(1,7,'Zone 7','ilôts 39 à 41 - 58 - 109 à 111 - 113 à 114 - 115 Bis à 116',11,7),
(1,8,'Zone 8','ilôts 108 Bis - 115 - 118 à 122',7,8),
(1,9,'Zone 9','ilôts 55 à 56 - 61 à 62 - 129 à 130',6,9),
(1,10,'Zone 10','ilôts 52 à 53 Bis - 137 à 143 - 492 Bis',11,10),
(1,11,'Zone 11','ilôts 54 - 63 - 134 à 136',5,11),
(1,12,'Zone 12','ilôts 127 à 128 - 131 à 133',5,12),
(1,13,'Zone 13','ilôts 59 à 60 - 117 - 123 à 126',7,13);
-- Zone 1
INSERT INTO ilot (zone_id,numero,libelle) VALUES
((SELECT id FROM zone WHERE village_id=1 AND numero=1),'1','Îlot 1'),
((SELECT id FROM zone WHERE village_id=1 AND numero=1),'2','Îlot 2'),
((SELECT id FROM zone WHERE village_id=1 AND numero=1),'3','Îlot 3'),
((SELECT id FROM zone WHERE village_id=1 AND numero=1),'4','Îlot 4'),
((SELECT id FROM zone WHERE village_id=1 AND numero=1),'5','Îlot 5'),
((SELECT id FROM zone WHERE village_id=1 AND numero=1),'6','Îlot 6'),
((SELECT id FROM zone WHERE village_id=1 AND numero=1),'7','Îlot 7'),
((SELECT id FROM zone WHERE village_id=1 AND numero=1),'9','Îlot 9'),
((SELECT id FROM zone WHERE village_id=1 AND numero=1),'10','Îlot 10'),
((SELECT id FROM zone WHERE village_id=1 AND numero=1),'11','Îlot 11'),
((SELECT id FROM zone WHERE village_id=1 AND numero=1),'12','Îlot 12'),
((SELECT id FROM zone WHERE village_id=1 AND numero=1),'20','Îlot 20'),
((SELECT id FROM zone WHERE village_id=1 AND numero=1),'69','Îlot 69'),
((SELECT id FROM zone WHERE village_id=1 AND numero=1),'70','Îlot 70'),
((SELECT id FROM zone WHERE village_id=1 AND numero=1),'76','Îlot 76'),
((SELECT id FROM zone WHERE village_id=1 AND numero=1),'77','Îlot 77'),
((SELECT id FROM zone WHERE village_id=1 AND numero=1),'77 Bis','Îlot 77 Bis');
-- Zone 2
INSERT INTO ilot (zone_id,numero,libelle) VALUES
((SELECT id FROM zone WHERE village_id=1 AND numero=2),'29','Îlot 29'),
((SELECT id FROM zone WHERE village_id=1 AND numero=2),'30','Îlot 30'),
((SELECT id FROM zone WHERE village_id=1 AND numero=2),'33','Îlot 33'),
((SELECT id FROM zone WHERE village_id=1 AND numero=2),'34','Îlot 34'),
((SELECT id FROM zone WHERE village_id=1 AND numero=2),'65 Bis','Îlot 65 Bis'),
((SELECT id FROM zone WHERE village_id=1 AND numero=2),'66','Îlot 66'),
((SELECT id FROM zone WHERE village_id=1 AND numero=2),'67','Îlot 67'),
((SELECT id FROM zone WHERE village_id=1 AND numero=2),'68','Îlot 68');
-- Zone 3
INSERT INTO ilot (zone_id,numero,libelle) VALUES
((SELECT id FROM zone WHERE village_id=1 AND numero=3),'65','Îlot 65'),
((SELECT id FROM zone WHERE village_id=1 AND numero=3),'95','Îlot 95'),
((SELECT id FROM zone WHERE village_id=1 AND numero=3),'96','Îlot 96'),
((SELECT id FROM zone WHERE village_id=1 AND numero=3),'97','Îlot 97'),
((SELECT id FROM zone WHERE village_id=1 AND numero=3),'98','Îlot 98'),
((SELECT id FROM zone WHERE village_id=1 AND numero=3),'101','Îlot 101'),
((SELECT id FROM zone WHERE village_id=1 AND numero=3),'102','Îlot 102'),
((SELECT id FROM zone WHERE village_id=1 AND numero=3),'103','Îlot 103');
-- Zone 4
INSERT INTO ilot (zone_id,numero,libelle) VALUES
((SELECT id FROM zone WHERE village_id=1 AND numero=4),'104','Îlot 104'),
((SELECT id FROM zone WHERE village_id=1 AND numero=4),'105','Îlot 105'),
((SELECT id FROM zone WHERE village_id=1 AND numero=4),'106','Îlot 106'),
((SELECT id FROM zone WHERE village_id=1 AND numero=4),'107','Îlot 107'),
((SELECT id FROM zone WHERE village_id=1 AND numero=4),'108','Îlot 108');
-- Zone 5
INSERT INTO ilot (zone_id,numero,libelle) VALUES
((SELECT id FROM zone WHERE village_id=1 AND numero=5),'26','Îlot 26'),
((SELECT id FROM zone WHERE village_id=1 AND numero=5),'27','Îlot 27'),
((SELECT id FROM zone WHERE village_id=1 AND numero=5),'31','Îlot 31'),
((SELECT id FROM zone WHERE village_id=1 AND numero=5),'32','Îlot 32'),
((SELECT id FROM zone WHERE village_id=1 AND numero=5),'35','Îlot 35'),
((SELECT id FROM zone WHERE village_id=1 AND numero=5),'36','Îlot 36'),
((SELECT id FROM zone WHERE village_id=1 AND numero=5),'99','Îlot 99'),
((SELECT id FROM zone WHERE village_id=1 AND numero=5),'100','Îlot 100');
-- Zone 6
INSERT INTO ilot (zone_id,numero,libelle) VALUES
((SELECT id FROM zone WHERE village_id=1 AND numero=6),'42','Îlot 42'),
((SELECT id FROM zone WHERE village_id=1 AND numero=6),'43','Îlot 43'),
((SELECT id FROM zone WHERE village_id=1 AND numero=6),'44','Îlot 44'),
((SELECT id FROM zone WHERE village_id=1 AND numero=6),'45','Îlot 45'),
((SELECT id FROM zone WHERE village_id=1 AND numero=6),'46','Îlot 46'),
((SELECT id FROM zone WHERE village_id=1 AND numero=6),'47','Îlot 47'),
((SELECT id FROM zone WHERE village_id=1 AND numero=6),'48','Îlot 48'),
((SELECT id FROM zone WHERE village_id=1 AND numero=6),'50','Îlot 50'),
((SELECT id FROM zone WHERE village_id=1 AND numero=6),'51','Îlot 51'),
((SELECT id FROM zone WHERE village_id=1 AND numero=6),'51 Bis','Îlot 51 Bis');
-- Zone 7
INSERT INTO ilot (zone_id,numero,libelle) VALUES
((SELECT id FROM zone WHERE village_id=1 AND numero=7),'39','Îlot 39'),
((SELECT id FROM zone WHERE village_id=1 AND numero=7),'40','Îlot 40'),
((SELECT id FROM zone WHERE village_id=1 AND numero=7),'41','Îlot 41'),
((SELECT id FROM zone WHERE village_id=1 AND numero=7),'58','Îlot 58'),
((SELECT id FROM zone WHERE village_id=1 AND numero=7),'109','Îlot 109'),
((SELECT id FROM zone WHERE village_id=1 AND numero=7),'110','Îlot 110'),
((SELECT id FROM zone WHERE village_id=1 AND numero=7),'111','Îlot 111'),
((SELECT id FROM zone WHERE village_id=1 AND numero=7),'113','Îlot 113'),
((SELECT id FROM zone WHERE village_id=1 AND numero=7),'114','Îlot 114'),
((SELECT id FROM zone WHERE village_id=1 AND numero=7),'115 Bis','Îlot 115 Bis'),
((SELECT id FROM zone WHERE village_id=1 AND numero=7),'116','Îlot 116');
-- Zone 8
INSERT INTO ilot (zone_id,numero,libelle) VALUES
((SELECT id FROM zone WHERE village_id=1 AND numero=8),'108 Bis','Îlot 108 Bis'),
((SELECT id FROM zone WHERE village_id=1 AND numero=8),'115','Îlot 115'),
((SELECT id FROM zone WHERE village_id=1 AND numero=8),'118','Îlot 118'),
((SELECT id FROM zone WHERE village_id=1 AND numero=8),'119','Îlot 119'),
((SELECT id FROM zone WHERE village_id=1 AND numero=8),'120','Îlot 120'),
((SELECT id FROM zone WHERE village_id=1 AND numero=8),'121','Îlot 121'),
((SELECT id FROM zone WHERE village_id=1 AND numero=8),'122','Îlot 122');
-- Zone 9
INSERT INTO ilot (zone_id,numero,libelle) VALUES
((SELECT id FROM zone WHERE village_id=1 AND numero=9),'55','Îlot 55'),
((SELECT id FROM zone WHERE village_id=1 AND numero=9),'56','Îlot 56'),
((SELECT id FROM zone WHERE village_id=1 AND numero=9),'61','Îlot 61'),
((SELECT id FROM zone WHERE village_id=1 AND numero=9),'62','Îlot 62'),
((SELECT id FROM zone WHERE village_id=1 AND numero=9),'129','Îlot 129'),
((SELECT id FROM zone WHERE village_id=1 AND numero=9),'130','Îlot 130');
-- Zone 10
INSERT INTO ilot (zone_id,numero,libelle) VALUES
((SELECT id FROM zone WHERE village_id=1 AND numero=10),'52','Îlot 52'),
((SELECT id FROM zone WHERE village_id=1 AND numero=10),'53','Îlot 53'),
((SELECT id FROM zone WHERE village_id=1 AND numero=10),'53 Bis','Îlot 53 Bis'),
((SELECT id FROM zone WHERE village_id=1 AND numero=10),'137','Îlot 137'),
((SELECT id FROM zone WHERE village_id=1 AND numero=10),'138','Îlot 138'),
((SELECT id FROM zone WHERE village_id=1 AND numero=10),'139','Îlot 139'),
((SELECT id FROM zone WHERE village_id=1 AND numero=10),'140','Îlot 140'),
((SELECT id FROM zone WHERE village_id=1 AND numero=10),'141','Îlot 141'),
((SELECT id FROM zone WHERE village_id=1 AND numero=10),'142','Îlot 142'),
((SELECT id FROM zone WHERE village_id=1 AND numero=10),'143','Îlot 143'),
((SELECT id FROM zone WHERE village_id=1 AND numero=10),'492 Bis','Îlot 492 Bis');
-- Zone 11
INSERT INTO ilot (zone_id,numero,libelle) VALUES
((SELECT id FROM zone WHERE village_id=1 AND numero=11),'54','Îlot 54'),
((SELECT id FROM zone WHERE village_id=1 AND numero=11),'63','Îlot 63'),
((SELECT id FROM zone WHERE village_id=1 AND numero=11),'134','Îlot 134'),
((SELECT id FROM zone WHERE village_id=1 AND numero=11),'135','Îlot 135'),
((SELECT id FROM zone WHERE village_id=1 AND numero=11),'136','Îlot 136');
-- Zone 12
INSERT INTO ilot (zone_id,numero,libelle) VALUES
((SELECT id FROM zone WHERE village_id=1 AND numero=12),'127','Îlot 127'),
((SELECT id FROM zone WHERE village_id=1 AND numero=12),'128','Îlot 128'),
((SELECT id FROM zone WHERE village_id=1 AND numero=12),'131','Îlot 131'),
((SELECT id FROM zone WHERE village_id=1 AND numero=12),'132','Îlot 132'),
((SELECT id FROM zone WHERE village_id=1 AND numero=12),'133','Îlot 133');
-- Zone 13
INSERT INTO ilot (zone_id,numero,libelle) VALUES
((SELECT id FROM zone WHERE village_id=1 AND numero=13),'59','Îlot 59'),
((SELECT id FROM zone WHERE village_id=1 AND numero=13),'60','Îlot 60'),
((SELECT id FROM zone WHERE village_id=1 AND numero=13),'117','Îlot 117'),
((SELECT id FROM zone WHERE village_id=1 AND numero=13),'123','Îlot 123'),
((SELECT id FROM zone WHERE village_id=1 AND numero=13),'124','Îlot 124'),
((SELECT id FROM zone WHERE village_id=1 AND numero=13),'125','Îlot 125'),
((SELECT id FROM zone WHERE village_id=1 AND numero=13),'126','Îlot 126');
UPDATE zone SET nb_ilots=(SELECT COUNT(*) FROM ilot WHERE ilot.zone_id=zone.id);
