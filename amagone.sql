/*
Modification depuis le distant
Je Fais un essai pour merger des branches

zizi

Là je suis sur branche1
-------------------------------------------
Le magasin AMAGONE vend des produits en dropshipping, où plusieurs vendeurs peuvent proposer des produits pré-existants, au prix qu'ils souhaitent et en renseignant leur stock disponible.
Chaque client peut passer commande d'une ou plusieurs offres ('propal'), en choisissant pour chacune un mode de livraison proposé parmis une liste.
Les produits peuvent être taggés, et appartiennent chacun à une des catégories.
A chaque commande est associé un ou plusieurs paiements.
-------------------------------------------
Rémi Perez / JC Kleinbourg
IPI LYON - 06/10/2023
Je modifie le main pour vous faire chier et oui
*/

-- Ajout d'une fonctionnalité :
CREATE DATEBASE amagone; -- création de la base

-- commandes sqlite3 pour l'affichage :
.header on
.mode column

-- Remise à zéro :
PRAGMA foreign_keys = OFF;

DROP TABLE IF EXISTS produit;
DROP TABLE IF EXISTS categorie;
DROP TABLE IF EXISTS tag;
DROP TABLE IF EXISTS tag_produit;
DROP TABLE IF EXISTS client;
DROP TABLE IF EXISTS propal_produit_vendeur;
DROP TABLE IF EXISTS vendeur;
DROP TABLE IF EXISTS livraison;
DROP TABLE IF EXISTS propal_produit_vendeur_livraison;
DROP TABLE IF EXISTS commande_propal_produit_vendeur;
DROP TABLE IF EXISTS commande;
DROP TABLE IF EXISTS paiement;

-- Réactivation de la vérification des clés étrangères
PRAGMA foreign_keys = ON;


-- STRUCTURE
------------

CREATE TABLE produit (
  id INTEGER PRIMARY KEY,
  nom TEXT UNIQUE NOT NULL,
  description TEXT NOT NULL,
  categorie_id INTEGER NOT NULL,
  FOREIGN KEY (categorie_id) REFERENCES categorie (id)
);

CREATE TABLE categorie (
  id INTEGER PRIMARY KEY,
  nom TEXT UNIQUE NOT NULL
);

CREATE TABLE tag (
  id INTEGER PRIMARY KEY,
  texte TEXT UNIQUE NOT NULL
);

-- table de jointure pour associer les tags aux produits par couples de clés uniques :
CREATE TABLE tag_produit (
  produit_id INTEGER,
  tag_id INTEGER,
  PRIMARY KEY (produit_id, tag_id),
  FOREIGN KEY (produit_id) REFERENCES produit (id),
  FOREIGN KEY (tag_id) REFERENCES tag (id)
);

CREATE TABLE client (
  id INTEGER PRIMARY KEY,
  email TEXT UNIQUE NOT NULL, -- email client unique
  nom TEXT NOT NULL,
  prenom TEXT NOT NULL,
  adresse TEXT NOT NULL,
  codepostal TEXT NOT NULL,
  ville TEXT NOT NULL,
  -- vérification de l'intégrité du code postal France/Corse :
  CHECK (
    (codepostal LIKE '_____' AND codepostal GLOB '[0-9][0-9][0-9][0-9][0-9]')
    OR (codepostal IN ('2A', '2B'))
  )
);
-- Création d'un index sur la colonne codepostal, car nous avons souvent des recherches à y effectuer :
CREATE INDEX idx_codepostal ON client (codepostal);

CREATE TABLE propal_produit_vendeur (
  id INTEGER PRIMARY KEY,
  produit_id INTEGER,
  vendeur_id INTEGER,
  prix REAL NOT NULL,
  stock INTEGER NOT NULL CHECK(stock >= 0),
  FOREIGN KEY (produit_id) REFERENCES produit (id),
  FOREIGN KEY (vendeur_id) REFERENCES vendeur (id),
  UNIQUE (produit_id, vendeur_id)
);

CREATE TABLE vendeur (
  id INTEGER PRIMARY KEY,
  nom TEXT UNIQUE NOT NULL -- nom vendeur unique
);

CREATE TABLE livraison (
  id INTEGER PRIMARY KEY,
  mode TEXT UNIQUE NOT NULL,
  prix REAL NOT NULL
);

-- A chaque propal peuvent être associés un ou plusieurs modes de livraison
-- toutes les entrées de couple propal / livraison sont renseignés dans cette table :
CREATE TABLE propal_produit_vendeur_livraison (
  id INTEGER PRIMARY KEY,
  propal_produit_vendeur_id INTEGER,
  livraison_id INTEGER,
  FOREIGN KEY (propal_produit_vendeur_id) REFERENCES propal_produit_vendeur (id),
  FOREIGN KEY (livraison_id) REFERENCES livraison (id)
);

CREATE TABLE commande_propal_produit_vendeur (
  id INTEGER PRIMARY KEY,
  commande_id INTEGER,
  quantite INTEGER NOT NULL,
  propal_produit_vendeur_livraison_id INTEGER,
  avis TEXT,
  note INTEGER,
  FOREIGN KEY (commande_id) REFERENCES commande (id),
  FOREIGN KEY (propal_produit_vendeur_livraison_id) REFERENCES propal_produit_vendeur_livraison (id)
);

CREATE TABLE commande (
  id INTEGER PRIMARY KEY,
  client_id INTEGER,
  date_commande DATE NOT NULL,
  FOREIGN KEY (client_id) REFERENCES client (id)
);

CREATE TABLE paiement (
  id INTEGER PRIMARY KEY,
  commande_id INTEGER,
  montant REAL NOT NULL,
  date_paiement DATE NOT NULL,
  FOREIGN KEY (commande_id) REFERENCES commande (id)
);


-- DONNES
---------

BEGIN TRANSACTION;

INSERT INTO client (email, nom, prenom, adresse, codepostal, ville)
VALUES
('dupont.john@gmail.com', 'Dupont', 'John', '123 Rue de la Poste', '75001', 'Paris'),
('s.Smith@gmail.com', 'Smith', 'Jane', '456 Avenue du Commerce', '69002', 'Lyon'),
('j.rob234@yahoo.com', 'Johnson', 'Robert', '789 Boulevard des Arts', '13008', 'Marseille'),
('emiliedu33@outloook.com', 'Brue', 'Emily', '1010 Rue de la Liberté', '2A', 'Ajaccio'),
('wiliP@gmail.com', 'Prieur', 'William', '567 Avenue de la République', '59000', 'Lille'),
('c_sarah@caramail.com', 'Croche', 'Sarah', '999 Rue de la Paix', '13008', 'Marseille'),
('roberttone@gmail.com', 'Tone', 'Robert', '435 Avenue des Lilas', '59000', 'Lille'),
('supermig@hotmail.com', 'Sanchez', 'Miguel', '643 Avenue du Vieux Port', '13008', 'Marseille');

INSERT INTO vendeur (nom)
VALUES
('GadgetWorld'),
('FashionFrenzy'),
('HomeBliss'),
('BeautyHub'),
('FoodieDelights'),
('SportsRUs'),
('Noobie');

INSERT INTO tag (texte)
VALUES
('Nouveauté'),
('Promotion'),
('Fait main'),
('Écologique'),
('Cadeau'),
('Chaussures'),
('Belles Chaussures'),
('Chaussures cool'),
('Voyage'),
('Collection d''été'),
('Bonne affaire'),
('Cuisine'),
('Technologie avancée'),
('Accessoire'),
('Bien-être'),
('Artisanat'),
('Luxe'),
('Végétarien');

INSERT INTO categorie (nom)
VALUES
('Electronique'),
('Vêtements'),
('Maison et Jardin'),
('Chaussures de sport'),
('Chaussures été'),
('Chaussures hiver'),
('Santé et Beauté'),
('Alimentation'),
('Sports et Loisirs'),
('Jouets et Jeux'),
('Automobile'),
('Livres et Médias'),
('Bébés et Enfants');

INSERT INTO produit (nom, description, categorie_id)
VALUES
('T-shirt Licorne Arc-en-ciel', 'Un t-shirt magique avec une licorne et un arc-en-ciel.', 2),
('Sac d''aventurier', 'Le sac parfait pour les explorateurs intrépides.', 9),
('Montre Étoilée Brillante', 'Une montre étincelante avec des étoiles pour femmes.', 1),
('Smartphone Galaxy X', 'Un téléphone intelligent avec un écran OLED de pointe.', 1),
('Bottes bleues et vertes', 'Une belle paire pour vos pieds.', 6),
('Livre de Recettes du Monde', 'Explorez la cuisine mondiale avec ce livre de recettes.', 12),
('Vélo Tout-Terrain Léopard', 'Un vélo tout-terrain pour les amateurs de sensations fortes.',9),
('Chaise de Bureau ConfortMax', 'La chaise parfaite pour le télétravail en tout confort.', 3),
('Couverts Élégance d''Argent', 'Des couverts en argent pour les occasions spéciales.', 3),
('Chouettes chaussures en plomb', 'Pour bien marcher après l''apero.', 4),
('Tongues américaines', 'Pour marcher léger.', 9),
('Jouets en Bois Éducatifs', 'Des jouets en bois pour apprendre en s''amusant.', 13);

INSERT INTO livraison (mode, prix)
VALUES
('gratuit', 0),
('classique', 5.00),
('express', 12.50);

INSERT INTO propal_produit_vendeur (produit_id, vendeur_id, prix, stock)
VALUES 
(1, 1, 10.99, 50),
(2, 2, 20.49, 30),
(3, 3, 15.99, 40),
(4, 4, 12.99, 25),
(5, 5, 18.79, 60),
(6, 6, 9.99, 70),
(7, 5, 14.29, 45),
(8, 3, 7.99, 55),
(9, 6, 16.99, 35),
(10, 2, 11.49, 20),
(11, 1, 13.99, 15),
(12, 2, 19.99, 50),
(1, 4, 8.49, 40),
(2, 6, 21.99, 25),
(3, 2, 17.49, 30),
(4, 5, 11.99, 55),
(5, 1, 15.99, 65),
(6, 5, 14.49, 70),
(7, 3, 9.99, 20),
(8, 2, 12.79, 45);

INSERT INTO commande (client_id, date_commande)
VALUES
(5, '2023-10-11'),
(1, '2023-10-12'),
(3, '2023-10-12'),
(6, '2023-10-14'),
(2, '2023-10-15'),
(4, '2023-10-16'),
(1, '2023-10-17'),
(5, '2023-10-18'),
(5, '2023-10-19'),
(6, '2023-10-20'),
(2, '2023-10-21'),
(4, '2023-10-22'),
(5, '2023-10-23'),
(5, '2023-10-24'),
(3, '2023-10-25'),
(4, '2023-10-25'),
(4, '2023-10-27'),
(5, '2023-10-28'),
(7, '2023-10-29'),
(8, '2023-10-29');

INSERT INTO tag_produit (produit_id, tag_id)
VALUES
(4, 12),
(4,1),
(4,17),
(6, 11), 
(5, 16),  
(7, 10), 
(8, 15), 
(9, 15), 
(10, 8), 
(11, 7), 
(12, 16), 
(1, 1), 
(2, 14),
(3, 14);

INSERT INTO propal_produit_vendeur_livraison (propal_produit_vendeur_id,livraison_id)
VALUES
(1,1),(1,2),
(2,3),
(3,1),(3,2),(3,3),
(4,1),(4,3),
(5,2),(5,3),
(6,1),(6,2),(6,3),
(7,1),(7,2),
(8,1),(8,2),(8,3),
(9,1),(9,2),(9,3),
(10,2),
(11,1),
(12,1),(12,2),(12,3),
(13,3),
(14,1),(14,2),
(15,2),
(16,1),(16,2),(16,3),
(17,2),
(18,1),(18,2),
(19,1),(19,3),
(20,2),(20,3);

INSERT INTO commande_propal_produit_vendeur (commande_id, quantite, propal_produit_vendeur_livraison_id, avis, note)
VALUES
(1, 5, 1, 'Livraison rapide!', 4),
(2, 2, 2, 'Bon rapport qualité-prix.', 3),
(3, 3, 3, NULL, 5),
(4, 1, 4, 'Excellent service!', 5),
(5, 4, 5, 'Livraison légèrement en retard.', 2),
(6, 2, 6, 'Très satisfait!', 4),
(7, 1, 7, NULL, 3),
(7, 2, 9, NULL, 2),
(7, 1, 10, NULL, 5),
(8, 3, 8, 'Service client réactif.', 4),
(9, 5, 9, 'Bonne expérience globale.', 4),
(10, 2, 10, 'Produit de qualité.', NULL),
(11, 4, 11, 'Livraison rapide et soignée.', 5),
(12, 1, 12, 'À recommander!', 4),
(13, 3, 13, 'Bon vendeur.', 3),
(14, 2, 14, 'Service impeccable.', 5),
(15, 1, 15, 'Rien à redire.', 4),
(16, 3, 16, 'Bien', 3),
(16, 2, 16, NULL, 5),
(17, 1, 17, 'Pas mal du tout pour un cadeau', 4),
(18, 1, 18, 'J''ai bien aimé ce produit', 3),
(19, 4, 19, NULL, NULL),
(20, 3, 19, NULL, 2);

INSERT INTO paiement (commande_id, montant, date_paiement)
VALUES
(1, 54.95, '2023-10-14'),
(2, 26.98, '2023-10-15'),
(3, 73.97, '2023-10-17'),
(4, 15.99, '2023-10-18'),
(5, 68.96, '2023-10-19'),
(6, 44.48, '2023-10-19'),
(7, 86.86, '2023-10-20'),
(8, 51.47, '2023-10-22'),
(9, 98.95, '2023-10-23'),
(10, 10, '2023-10-25'),
(10, 10, '2023-10-26'),
(10, 10, '2023-10-27'),
(10, 10, '2023-10-28'),
(10, 10, '2023-10-29'),
(11, 39.96, '2023-10-25'),
(12, 14.99, '2023-10-26'),
(13, 42.47, '2023-10-27'),
(14, 28.58, '2023-10-27'),
(15, 19.29, '2023-10-27'),
(16, 39.95, '2023-10-27'),
(17, 12.99, '2023-10-28'),
(19, 67.96, '2023-10-29'),
(20, 50.97, '2023-10-29');

COMMIT;


-- REQUETES
-----------

-- Code postaux clients et nombre de clients associés :
SELECT codepostal, COUNT(*) AS nombre_de_clients
FROM client
GROUP BY codepostal
ORDER BY codepostal;


-- Recherche de produits par mot clé sur leurs noms, catégories ou tags (ici chaussure) :
SELECT
  p.id AS produit_id,
  p.nom AS produit_nom,
	p.description AS produit_description,
	c.nom AS categorie_nom,
	t.texte AS tag_texte
FROM
  produit p
JOIN categorie c ON c.id = p.categorie_id
JOIN tag_produit tp ON p.id = tp.produit_id
JOIN tag t ON t.id = tp.tag_id
WHERE
(
  c.nom COLLATE NOCASE LIKE ('%chaussure%')
  OR p.nom COLLATE NOCASE LIKE ('%chaussure%')
  OR t.texte COLLATE NOCASE LIKE ('%chaussure%')
);


-- Classement des produits par quantitées vendues :
SELECT
  p.id AS produit_id,
  p.nom AS produit_nom,
  COALESCE(SUM(quantite), 0) AS quantite_vendue -- si qté NULL alors 0
FROM
  commande_propal_produit_vendeur cppv
JOIN propal_produit_vendeur_livraison ppvl ON cppv.propal_produit_vendeur_livraison_id = ppvl.id
JOIN propal_produit_vendeur ppv ON ppvl.propal_produit_vendeur_id = ppv.id
OUTER FULL JOIN
  produit p ON ppv.produit_id = p.id
GROUP BY p.id
ORDER BY quantite_vendue desc;


-- Moyenne des notes attribués à un produit par son id :
SELECT
  AVG(note)
FROM
  commande_propal_produit_vendeur cppv
JOIN propal_produit_vendeur_livraison ppvl ON cppv.propal_produit_vendeur_livraison_id = ppvl.id
JOIN propal_produit_vendeur ppv ON ppvl.propal_produit_vendeur_id = ppv.id
JOIN produit p ON ppv.produit_id = p.id
WHERE
  p.id = 1;


-- Produits dont la moyenne des notes est supérieure ou égale à 4 :
SELECT
  p.id AS produit_id,
  p.nom AS produit_nom,
  ROUND(AVG(note), 1) AS note_moyenne
FROM
  commande_propal_produit_vendeur cppv
JOIN propal_produit_vendeur_livraison ppvl ON cppv.propal_produit_vendeur_livraison_id = ppvl.id
JOIN propal_produit_vendeur ppv ON ppvl.propal_produit_vendeur_id = ppv.id
JOIN produit p ON ppv.produit_id = p.id
GROUP BY p.id
HAVING note_moyenne >= 4
ORDER BY note_moyenne desc;


-- Classement de tous les produits avec leurs prix moyen et notes moyennes si existante:
SELECT
  p.id AS produit_id,
  p.nom AS produit_nom,
  ROUND(AVG(ppv.prix), 2) AS prix_moyen,
  ROUND(AVG(note), 1) AS note_moyenne
FROM
  commande_propal_produit_vendeur cppv
JOIN propal_produit_vendeur_livraison ppvl ON cppv.propal_produit_vendeur_livraison_id = ppvl.id
OUTER FULL JOIN propal_produit_vendeur ppv ON ppvl.propal_produit_vendeur_id = ppv.id
OUTER FULL JOIN produit p ON ppv.produit_id = p.id
GROUP BY p.id
ORDER BY note_moyenne DESC;


-- Liste de tous les vendeurs par ordre alphabétique avec leur nombre de produits en vente et somme des stocks disponibles :
SELECT
  v.nom AS vendeur_nom,
  COUNT(ppv.id) AS nb_produits,
  SUM(ppv.stock) AS somme_stocks
FROM
  propal_produit_vendeur ppv
OUTER FULL JOIN vendeur v ON ppv.vendeur_id = v.id
GROUP BY v.id
ORDER BY v.nom;


-- Liste des commandes par date avec email des clients et montant à régler :
SELECT
  commande.id AS commande_id,
  c.email AS email_client,
  commande.date_commande AS commande_date,
  SUM(cppv.quantite * ppv.prix) AS montant,
  SUM(l.prix) AS livraison,
  SUM(cppv.quantite * ppv.prix) + SUM(l.prix) AS total
FROM
  commande_propal_produit_vendeur cppv
JOIN commande ON cppv.commande_id = commande.id
JOIN client c ON commande.client_id = c.id
JOIN propal_produit_vendeur_livraison ppvl ON cppv.propal_produit_vendeur_livraison_id = ppvl.id
JOIN livraison l ON ppvl.livraison_id = l.id
JOIN propal_produit_vendeur ppv ON ppvl.propal_produit_vendeur_id = ppv.id
GROUP BY commande.id
ORDER BY commande.date_commande DESC;


-- Liste des commandes avec total facturé / payé
/* Dans cet exemple :
- la commande n°10 à été payée en 5 fois mais pas complètement
- la commande n°18 n'a pas été payée
*/
SELECT
  commande.id AS commande_id,

  commande.date_commande AS commande_date,

  (SUM(cppv.quantite * ppv.prix) + SUM(l.prix)) /
  CASE
    WHEN (SELECT COUNT(*) FROM paiement WHERE paiement.commande_id = commande.id) = 0 THEN 1
    ELSE (SELECT COUNT(*) FROM paiement WHERE paiement.commande_id = commande.id)
  END AS total_facture,
  
  COALESCE(SUM(paiement.montant) /
    (SELECT COUNT(*) FROM commande_propal_produit_vendeur cppv WHERE cppv.commande_id = commande.id), 0)
  AS total_paye
FROM
  commande_propal_produit_vendeur cppv
JOIN commande ON cppv.commande_id = commande.id
JOIN client c ON commande.client_id = c.id
JOIN propal_produit_vendeur_livraison ppvl ON cppv.propal_produit_vendeur_livraison_id = ppvl.id
JOIN livraison l ON ppvl.livraison_id = l.id
JOIN propal_produit_vendeur ppv ON ppvl.propal_produit_vendeur_id = ppv.id
LEFT OUTER JOIN paiement ON paiement.commande_id = commande.id
GROUP BY commande.id
ORDER BY commande_id ASC;
