DROP table JOUE1;
DROP table REPRESENTATIONS;
DROP table PIECES;
DROP TABLE ACTEURS;
DROP TABLE AUTEURS;
DROP TABLE THEATRES;


CREATE TABLE THEATRES
(
  IDTHEATRE         NUMBER      CONSTRAINT PK_THEATRE PRIMARY KEY,
  NOMTHEATRE        VARCHAR2(50),
  ADRESSE           VARCHAR2(50),
  TEL               VARCHAR2(10),
  NBREPLACES        NUMBER
) ;

CREATE TABLE AUTEURS
(
  IDAUTEUR          NUMBER      CONSTRAINT PK_AUTEURS PRIMARY KEY,
  PRENOMAUTEUR      VARCHAR2(50),
  NOMAUTEUR         VARCHAR2(50),
  NAISSANCE         DATE,
  DECES             DATE,
  NATIONALITE       VARCHAR2(50)
) ;


CREATE TABLE ACTEURS
(
  IDACTEUR        NUMBER        CONSTRAINT PK_ACTEURS PRIMARY KEY,
  PRENOMACTEUR          VARCHAR2(50),
  NOMACTEUR       VARCHAR2(50),
  IDTHEATRE       NUMBER        CONSTRAINT FK_ACTEURS_THEATRE REFERENCES THEATRES(IDTHEATRE)
) ;
CREATE TABLE PIECES
	(idpiece number(2) CONSTRAINT pk_pieces PRIMARY KEY,
	 titre Varchar(40),
         type Varchar(20) CONSTRAINT ck_type CHECK (type in ('Comedie','Tragedie','Absurde','Autres')),
	 idtheatre number(2) CONSTRAINT fk_piece1 REFERENCES Theatres(idtheatre),
	 idauteur number(2) CONSTRAINT fk_piece2 REFERENCES auteurs(idauteur)
	);
	
CREATE TABLE REPRESENTATIONS
	(idrepresentation number(3) CONSTRAINT pk_representation PRIMARY KEY,
	 idpiece number(2) CONSTRAINT fk_representation REFERENCES pieces(idpiece),
	 date_a DATE DEFAULT sysdate,
	 placesrestantes number(3) Constraint ck_representations CHECK (placesrestantes>=0));

CREATE TABLE JOUE1
	(idacteur number(3) CONSTRAINT fk_Joue1_acteur REFERENCES
 	 Acteurs(idacteur) ON DELETE CASCADE,
	 idpiece number(3) CONSTRAINT fk_Joue1_piece REFERENCES Pieces(idpiece),
	 CONSTRAINT pk_Joue1 PRIMARY KEY (idacteur, idpiece));	


Insert into THEATRES values (1,'Centre culturel des minimes','6 rue du Caillou gris','0561971855',250);
Insert into THEATRES values (2,'Grenier théâtre','14 Impasse de Gramont','0561482100',400);
Insert into THEATRES values (3,'Le fil à plomb','30 rue de la chaîne','0562309977',600);
Insert into THEATRES values (4,'Théâtre de poche','10 rue d''el Alamein','0561482552',150);
Insert into THEATRES values (5,'Théâtre du Capitole','Place du Capitole','0561631313',800);
Insert into THEATRES values (6,'Théâtre Sorano','35 allées Jules Guesde','0534316787',180);



Insert into AUTEURS   values (1,'Francis','Azéma','25/12/1962',null,'Français');
Insert into AUTEURS   values (2,'Michel-Marc','Bouchard','26/05/1972',null,'Français');
Insert into AUTEURS   values (3,'Mohamed','Bounouara','21/04/1955',null,'Marocain');
Insert into AUTEURS   values (4,'René-Guy','Cadou','18/07/1935',null,'Français');
Insert into AUTEURS   values (5,'Bruno','Caprini','11/01/1963',null,'Français');
Insert into AUTEURS   values (6, null,'Compagnie Point d orgue','15/03/1966',null,'Français');
Insert into AUTEURS   values (7,null,'Compagnie Vox','26/04/1996',null,'Français');
Insert into AUTEURS   values (8,null,'Compagnie Zanni','28/03/1985',null,'Français');
Insert into AUTEURS   values (9,'René','De Obaldia','23/11/1946',null,'Français');
Insert into AUTEURS   values (10,'Ouahibe','Dibane','30/05/1946','16/09/1990','Français');
Insert into AUTEURS   values (11,'Gaetano','Donizetti','25/10/1948','31/12/1997','Italien');
Insert into AUTEURS   values (12,'Joël','Fauré','16/01/1958',null,'Français');
Insert into AUTEURS   values (13,'Amar','Guerfi','27/02/1940','26/06/1992','Algérien');
Insert into AUTEURS   values (14,'Jacob','Haggai','02/10/1959',null,'Polonais');
Insert into AUTEURS   values (15,'Francklin','Le Naour','16/08/1955',null,'Français');
Insert into AUTEURS   values (16,'Robert','Nicolas','18/03/1962',null,'Français');
Insert into AUTEURS   values (17,'Sergei','Prokofiev','17/01/1991','30/06/1953','Russe');
Insert into AUTEURS   values (18,'Jean-Paul','Raffit','16/09/1951',null,'Français');
Insert into AUTEURS   values (19,'Nathalie','Saraute','28/06/1956',null,'Français');
Insert into AUTEURS   values (20,'Ambroise','Thomas','16/05/1945','18/06/2000','Français');
Insert into AUTEURS   values (21,'Robert','Toma','18/03/1962',null,'Français');
Insert into AUTEURS   values (22,null,'Troupe Calliopé','15/10/1988',null,'Français');



Insert into ACTEURS values (1,'Jacques','Dauches',1);
Insert into ACTEURS values (2,'Françoise','De Ménis',5);
Insert into ACTEURS values (3,'Marc','Delcourt',1);
Insert into ACTEURS values (4,'Simone','Deloume',3);
Insert into ACTEURS values (5,'Max','Delpla',3);
Insert into ACTEURS values (6,'François','Delplat',3);
Insert into ACTEURS values (7,'Agnès Diras','Diras',2);
Insert into ACTEURS values (8,'André','Escala',3);
Insert into ACTEURS values (9,'Jean','Estras',2);
Insert into ACTEURS values (10,'Eric','Eychenne',5);
Insert into ACTEURS values (11,'Paul','Fabiani',2);
Insert into ACTEURS values (12,'Colette','Fantoni',6);
Insert into ACTEURS values (13,'Valérie','Féré',6);
Insert into ACTEURS values (14,'Valentine','Fontès',5);
Insert into ACTEURS values (15,'Georges','Fourti',4);
Insert into ACTEURS values (16,'Jean-Paul','Gariteau',5);
Insert into ACTEURS values (17,'Jean-Marc','Gassant',3);
Insert into ACTEURS values (18,'Benjamin','Helman',4);
Insert into ACTEURS values (19,'Florence','Pelegrin',2);
Insert into ACTEURS values (20,'Sylvie','Poeyau',5);
Insert into ACTEURS values (21,'Gérard','Riff',2);
Insert into ACTEURS values (22,'André','Sanezot',2);
Insert into ACTEURS values (23,'Adrien','Savie',5);
Insert into ACTEURS values (24,'Thierry','Tauloud',2);
Insert into ACTEURS values (25,'Sophie','Ulrie',6);


Insert into PIECES   values (1,'Continuez de vous taire','Autres',4,10);
Insert into PIECES   values (2,'Danse improvisée','Autres',  2,7);
Insert into PIECES   values (3,'Huit femmes','Comedie', 4,21);
Insert into PIECES   values (4,'Jeunes en scène','Autres',6,19);
Insert into PIECES   values (5,'Kass kass','Autres', 3,4);
Insert into PIECES   values (6,'La baby sitter','Comedie',4,9);
Insert into PIECES   values (7,'Le gueuloir de poche','Absurde',4,11);
Insert into PIECES   values (8,'L elisir d amore','Tragedie',5,11);
Insert into PIECES   values (9,'Les muses orphelines','Tragedie',6,2);
Insert into PIECES   values (10,'Les pages jaunes','Autres',4,5);
Insert into PIECES   values (11,'Mignon','Autres',5,20);
Insert into PIECES   values (12,'Miroir bons mots miroir', 'Comedie', 1,22);
Insert into PIECES   values (13,'Mistinguett','Autres',5,15);
Insert into PIECES   values (14,'Orbe','Tragedie',4,12);
Insert into PIECES   values (15,'Pierre et vincent','Autres',3,11);
Insert into PIECES   values (16,'Plateau découverte','Autres',3,4);
Insert into PIECES   values (17,'Ploum, ploum, tralala','Absurde',3,2);
Insert into PIECES   values (18,'Pour un oui ou pour un non','Autres',6,19);
Insert into PIECES   values (19,'Roméo et juliette','Tragedie',5,17);
Insert into PIECES   values (20,'Sur le chemin de notre mémoire','Tragedie', 2,4);
Insert into PIECES   values (21,'Tartuffe, peut-être','Comedie',  2,2);
Insert into PIECES   values (22,'Tout ça ne vaut pas l amour','Autres',  1,13);
Insert into PIECES   values (23,'Un après midi d operette','Autres',4,7);
Insert into PIECES   values (24,'Un casting pas comme les autres','Comedie',3,8);
Insert into PIECES   values (25,'Une orange sur un lapiaz','Autres',3,16);
Insert into PIECES   values (26,'Violon dingue','Absurde',3,3);



Insert into JOUE1    values (1,2);
Insert into JOUE1    values (1,3);
Insert into JOUE1    values (1,15);
Insert into JOUE1    values (2,3);
Insert into JOUE1    values (2,21);
Insert into JOUE1    values (3,12);
Insert into JOUE1    values (3,13);
Insert into JOUE1    values (3,17);
Insert into JOUE1    values (4,8);
Insert into JOUE1    values (4,24);
Insert into JOUE1    values (5,5);
Insert into JOUE1    values (5,25);
Insert into JOUE1    values (6,8);
Insert into JOUE1    values (7,21);
Insert into JOUE1    values (8,20);
Insert into JOUE1    values (9,9);
Insert into JOUE1    values (9,20);
Insert into JOUE1    values (9,22);
Insert into JOUE1    values (9,23);
Insert into JOUE1    values (10,22);
Insert into JOUE1    values (10,25);
Insert into JOUE1    values (11,20);
Insert into JOUE1    values (12,4);
Insert into JOUE1    values (12,7);
Insert into JOUE1    values (12,16);
Insert into JOUE1    values (12,26);
Insert into JOUE1    values (14,1);
Insert into JOUE1    values (15,1);
Insert into JOUE1    values (15,7);
Insert into JOUE1    values (15,16);
Insert into JOUE1    values (13,24);
Insert into JOUE1    values (16,10);
Insert into JOUE1    values (17,10);
Insert into JOUE1    values (18,2);
Insert into JOUE1    values (18,15);
Insert into JOUE1    values (19,6);
Insert into JOUE1    values (19,9);
Insert into JOUE1    values (19,11);
Insert into JOUE1    values (19,16);
Insert into JOUE1    values (20,11);
Insert into JOUE1    values (20,12);
Insert into JOUE1    values (20,14);
Insert into JOUE1    values (21,4);
Insert into JOUE1    values (21,6);
Insert into JOUE1    values (21,11);
Insert into JOUE1    values (21,12);
Insert into JOUE1    values (21,18);
Insert into JOUE1    values (21,26);
Insert into JOUE1    values (23,5);
Insert into JOUE1    values (23,17);
Insert into JOUE1    values (23,19);
Insert into JOUE1    values (24,4);
Insert into JOUE1    values (24,14);
Insert into JOUE1    values (24,19);
Insert into JOUE1    values (24,23);
Insert into JOUE1    values (25,16);


Insert into REPRESENTATIONS   values (1,1,'29/04/2001',52);
Insert into REPRESENTATIONS   values (2,2,'16/05/2001',2);
Insert into REPRESENTATIONS   values (3,2,'17/05/2001',5);
Insert into REPRESENTATIONS   values (4,2,'18/05/2001',10);
Insert into REPRESENTATIONS   values (5,2,'19/05/2001',52);
Insert into REPRESENTATIONS   values (6,2,'20/05/2001',0);
Insert into REPRESENTATIONS   values (7,2,'23/05/2001',0);
Insert into REPRESENTATIONS   values (8,2,'24/05/2001',4);
Insert into REPRESENTATIONS   values (9,2,'25/05/2001',5);
Insert into REPRESENTATIONS   values (10,2,'26/05/2001',1);
Insert into REPRESENTATIONS   values (11,2,'27/05/2001',0);
Insert into REPRESENTATIONS   values (12,3,'03/05/2001',45);
Insert into REPRESENTATIONS   values (13,3,'04/05/2001',87);
Insert into REPRESENTATIONS   values (14,3,'05/05/2001',65);
Insert into REPRESENTATIONS   values (15,3,'10/05/2001',87);
Insert into REPRESENTATIONS   values (16,3,'11/05/2001',12);
Insert into REPRESENTATIONS   values (17,3,'12/05/2001',58);
Insert into REPRESENTATIONS   values (18,4,'29/04/2001',124);
Insert into REPRESENTATIONS   values (19,5,'26/06/2001',7);
Insert into REPRESENTATIONS   values (20,5,'27/06/2001',8);
Insert into REPRESENTATIONS   values (21,6,'05/06/2001',78);
Insert into REPRESENTATIONS   values (22,6,'06/06/2001',87);
Insert into REPRESENTATIONS   values (23,6,'07/06/2001',52);
Insert into REPRESENTATIONS   values (24,6,'08/06/2001',28);
Insert into REPRESENTATIONS   values (25,6,'09/06/2001',95);
Insert into REPRESENTATIONS   values (26,6,'10/06/2001',31);
Insert into REPRESENTATIONS   values (27,7,'30/06/2001',88);
Insert into REPRESENTATIONS   values (28,8,'01/06/2001',203);
Insert into REPRESENTATIONS   values (29,8,'02/06/2001',152);
Insert into REPRESENTATIONS   values (30,8,'04/06/2001',250);
Insert into REPRESENTATIONS   values (31,8,'05/06/2001',200);
Insert into REPRESENTATIONS   values (32,8,'06/06/2001',201);
Insert into REPRESENTATIONS   values (33,8,'08/06/2001',308);
Insert into REPRESENTATIONS   values (34,8,'09/06/2001',406);
Insert into REPRESENTATIONS   values (35,8,'10/06/2001',203);
Insert into REPRESENTATIONS   values (36,9,'29/04/2001',35);
Insert into REPRESENTATIONS   values (37,10,'13/06/2001',42);
Insert into REPRESENTATIONS   values (38,10,'14/06/2001',10);
Insert into REPRESENTATIONS   values (39,10,'15/06/2001',45);
Insert into REPRESENTATIONS   values (40,10,'16/06/2001',87);
Insert into REPRESENTATIONS   values (41,10,'20/06/2001',52);
Insert into REPRESENTATIONS   values (42,10,'21/06/2001',39);
Insert into REPRESENTATIONS   values (43,10,'22/06/2001',92);
Insert into REPRESENTATIONS   values (44,10,'23/06/2001',87);
Insert into REPRESENTATIONS   values (45,11,'26/04/2001',56);
Insert into REPRESENTATIONS   values (46,11,'07/05/2001',28);
Insert into REPRESENTATIONS   values (47,12,'27/04/2001',12);
Insert into REPRESENTATIONS   values (48,13,'19/06/2001',58);
Insert into REPRESENTATIONS   values (49,13,'22/06/2001',78);
Insert into REPRESENTATIONS   values (50,13,'23/06/2001',99);
Insert into REPRESENTATIONS   values (51,13,'24/06/2001',52);
Insert into REPRESENTATIONS   values (52,14,'16/05/2001',0);
Insert into REPRESENTATIONS   values (53,14,'17/05/2001',0);
Insert into REPRESENTATIONS   values (54,14,'18/05/2001',0);
Insert into REPRESENTATIONS   values (55,14,'19/05/2001',8);
Insert into REPRESENTATIONS   values (56,14,'23/05/2001',1);
Insert into REPRESENTATIONS   values (57,14,'24/05/2001',3);
Insert into REPRESENTATIONS   values (58,14,'25/05/2001',8);
Insert into REPRESENTATIONS   values (59,14,'26/05/2001',5);
Insert into REPRESENTATIONS   values (60,14,'30/05/2001',3);
Insert into REPRESENTATIONS   values (61,14,'31/05/2001',7);
Insert into REPRESENTATIONS   values (62,14,'01/06/2001',9);
Insert into REPRESENTATIONS   values (63,14,'02/06/2001',12);
Insert into REPRESENTATIONS   values (64,15,'26/06/2001',156);
Insert into REPRESENTATIONS   values (65,15,'27/06/2001',78);
Insert into REPRESENTATIONS   values (66,16,'08/05/2001',85);
Insert into REPRESENTATIONS   values (67,17,'21/05/2001',7);
Insert into REPRESENTATIONS   values (68,17,'22/05/2001',1);
Insert into REPRESENTATIONS   values (69,17,'23/05/2001',85);
Insert into REPRESENTATIONS   values (70,17,'24/05/2001',2);
Insert into REPRESENTATIONS   values (71,17,'25/05/2001',34);
Insert into REPRESENTATIONS   values (72,17,'27/05/2001',8);
Insert into REPRESENTATIONS   values (73,18,'15/05/2001',12);
Insert into REPRESENTATIONS   values (74,18,'16/05/2001',54);
Insert into REPRESENTATIONS   values (75,18,'17/05/2001',47);
Insert into REPRESENTATIONS   values (76,18,'18/05/2001',58);
Insert into REPRESENTATIONS   values (77,18,'19/05/2001',50);
Insert into REPRESENTATIONS   values (78,18,'20/05/2001',80);
Insert into REPRESENTATIONS   values (79,18,'22/05/2001',78);
Insert into REPRESENTATIONS   values (80,18,'23/05/2001',68);
Insert into REPRESENTATIONS   values (81,18,'24/05/2001',45);
Insert into REPRESENTATIONS   values (82,18,'25/05/2001',64);
Insert into REPRESENTATIONS   values (83,18,'26/05/2001',64);
Insert into REPRESENTATIONS   values (84,18,'27/05/2001',67);
Insert into REPRESENTATIONS   values (85,19,'10/05/2001',0);
Insert into REPRESENTATIONS   values (86,19,'11/05/2001',0);
Insert into REPRESENTATIONS   values (87,19,'12/05/2001',5);
Insert into REPRESENTATIONS   values (88,19,'13/05/2001',2);
Insert into REPRESENTATIONS   values (89,20,'30/05/2001',42);
Insert into REPRESENTATIONS   values (90,20,'31/05/2001',25);
Insert into REPRESENTATIONS   values (91,20,'01/06/2001',78);
Insert into REPRESENTATIONS   values (92,20,'02/06/2001',57);
Insert into REPRESENTATIONS   values (93,20,'06/06/2001',57);
Insert into REPRESENTATIONS   values (94,20,'07/06/2001',7);
Insert into REPRESENTATIONS   values (95,20,'08/06/2001',85);
Insert into REPRESENTATIONS   values (96,20,'09/06/2001',25);
Insert into REPRESENTATIONS   values (97,21,'29/04/2001',120);
Insert into REPRESENTATIONS   values (98,21,'02/05/2001',103);
Insert into REPRESENTATIONS   values (99,21,'06/05/2001',145);
Insert into REPRESENTATIONS   values (100,21,'08/05/2001',163);
Insert into REPRESENTATIONS   values (101,21,'09/05/2001',135);
Insert into REPRESENTATIONS   values (102,21,'03/06/2001',140);
Insert into REPRESENTATIONS   values (103,21,'07/06/2001',204);
Insert into REPRESENTATIONS   values (104,21,'11/06/2001',120);
Insert into REPRESENTATIONS   values (105,21,'14/06/2001',175);
Insert into REPRESENTATIONS   values (106,21,'15/06/2001',20);
Insert into REPRESENTATIONS   values (107,21,'16/06/2001',53);
Insert into REPRESENTATIONS   values (108,22,'04/05/2001',3);
Insert into REPRESENTATIONS   values (109,22,'05/05/2001',7);
Insert into REPRESENTATIONS   values (110,22,'06/05/2001',78);
Insert into REPRESENTATIONS   values (111,22,'10/05/2001',7);
Insert into REPRESENTATIONS   values (112,22,'11/05/2001',2);
Insert into REPRESENTATIONS   values (113,22,'12/05/2001',8);
Insert into REPRESENTATIONS   values (114,22,'13/05/2001',88);
Insert into REPRESENTATIONS   values (115,23,'24/06/2001',5);
Insert into REPRESENTATIONS   values (116,24,'02/05/2001',457);
Insert into REPRESENTATIONS   values (117,25,'04/07/2001',512);
Insert into REPRESENTATIONS   values (118,25,'05/07/2001',256);
Insert into REPRESENTATIONS   values (119,25,'06/07/2001',128);
Insert into REPRESENTATIONS   values (120,25,'07/07/2001',64);
Insert into REPRESENTATIONS   values (121,25,'08/07/2001',31);
Insert into REPRESENTATIONS   values (122,26,'28/04/2001',580);
Insert into REPRESENTATIONS   values (123,26,'29/04/2001',541);
Insert into REPRESENTATIONS   values (124,26,'03/05/2001',456);
Insert into REPRESENTATIONS   values (125,26,'04/05/2001',123);
Insert into REPRESENTATIONS   values (126,26,'05/05/2001',74);
Insert into REPRESENTATIONS   values (127,26,'06/05/2001',367);

insert into PIECES values (27,'Zoom','Comedie',3,3);

insert into JOUE1 values (2,27);
insert into JOUE1 values (4,27);

insert into REPRESENTATIONS values (128,27,'29/05/2001',86);
insert into REPRESENTATIONS values (129,27,'30/05/2001',12);
insert into REPRESENTATIONS values (130,27,'31/05/2001',523);
insert into REPRESENTATIONS values (131,27,'01/06/2001',345);
insert into REPRESENTATIONS values (132,27,'04/06/2001',128);
commit;


[Q1] 
Ecrire une procédure stockée PL/SQL permettant d’effectuer l’ajout 
automatique d’une nouvelle pièce dans la base. Cette procédure insérera 
également automatiquement dans la table JOUE tous les acteurs pensionnaires
du théâtre comme acteurs de la pièce.

Données passées en paramètre de la procédure stockée : tous les champs de 
la table PIECES.

Tester cette procédure stockée :

CREATE OR REPLACE PROCEDURE ajout_piece(
		myId Pieces.idPiece%TYPE, 
		myTitre Pieces.titre%TYPE, 
		myType Pieces.type%TYPE, 
		myIdTheatre	Pieces.idTheatre%TYPE, 
		myIdAuteur Pieces.idAuteur%TYPE) IS
		
	CURSOR acteursTheatre IS SELECT idActeur FROM Acteurs WHERE idTheatre=myIdTheatre;

	unActeur Acteurs.idActeur%TYPE;
		
	BEGIN
		INSERT INTO Pieces(idPiece, titre, type, idTheatre, idAuteur) 
		VALUES(myId, myTitre, myType, myIdTheatre, myIdAuteur);
		
		dbms_output.put_line('insertion de la Pieces effectuée');
		
		FOR unActeur IN acteursTheatre LOOP
			INSERT INTO Joue1(idActeur, idPiece) 
			VALUES(unActeur.idActeur, myId);
			dbms_output.put_line('insertion dans Joue1');
		END LOOP;
	END;
	/
	show errors 

	-	Directement via un ordre execute.
	EXECUTE ajout_piece(69,'Arnaud pour les nuls','Comedie',2,10);
	
	-	au sein d’un bloc PL/SQL avec les variables lues précédemment via ACCEPT…PROMPT
	SET SERVEROUTPUT ON;
	
	ACCEPT myId PROMPT 'Entrer le numero de la pièce : ';
	ACCEPT myTitre PROMPT 'Entrer le titre de la pièce : ';
	ACCEPT myType PROMPT 'Entrer le type de la pièce : ';
	ACCEPT myIdTheatre PROMPT 'Entrer le numero du theatre de la pièce : ';
	ACCEPT myIdAuteur PROMPT 'Entrer le numero de l''auteur de la pièce : ';
		
	BEGIN
		ajout_piece(&myId,'&myTitre','&myType',&myIdTheatre,&myIdAuteur);
	END;
	/
	show errors 
	
	
	[Q2] 
Reprendre le programme précédent et ajouter tous les traitements d’erreurs 
possibles. Toutes les erreurs sont affichées avec DBMS_OUTPUT, avec un
message CLAIR pour l’utilisateur. 
	Exceptions possibles :
-	n° pièce déjà présent
-	identifiant théâtre inconnu
-	identifiant auteur inconnu
-	le ‘Grenier théâtre’ ne présente jamais de pièces de type ‘Tragédie’,
-	si la pièce est déjà donnée dans un autre théâtre (titre équivalent), 
le type de la pièce doit être le même.
Les trois premières exceptions seront traitées via des exceptions SQL 
prédéfinies et les 2 dernières sont des exceptions applicatives.

CREATE OR REPLACE PROCEDURE ajout_piece(
		myId Pieces.idPiece%TYPE, 
		myTitre Pieces.titre%TYPE, 
		myType Pieces.type%TYPE, 
		myIdTheatre	Pieces.idTheatre%TYPE, 
		myIdAuteur Pieces.idAuteur%TYPE) IS
		
	CURSOR acteursTheatre IS SELECT idActeur FROM Acteurs WHERE idTheatre=myIdTheatre;
	CURSOR typePiece IS SELECT type FROM Pieces WHERE titre=myTitre;

	unActeur Acteurs.idActeur%TYPE;
	unType Pieces.type%TYPE;
	
	i NUMBER;
	myNomTheatre Theatres.nomTheatre%TYPE; 
	
	excep_idAuteur  Pieces.idAuteur%TYPE;
	excep_idTheatre  Pieces.idTheatre%TYPE;
	
	grenierNoTragedie EXCEPTION;
	typeEquTitre EXCEPTION;
	
	BEGIN
	
		i:=1;
		SELECT idTheatre INTO excep_idTheatre FROM Theatres WHERE idTheatre = myIdTheatre;
		i:=2;
		SELECT idAuteur INTO excep_idAuteur FROM Auteurs WHERE idAuteur=myIdAuteur;
		
		SELECT nomTheatre INTO myNomTheatre FROM Theatres WHERE idTheatre=myIdTheatre ;
		IF myNomTheatre='Grenier théâtre' and myType='Tragedie' THEN
			RAISE grenierNoTragedie;
		END IF;
		
		FOR unType IN typePiece LOOP
			IF unType.type!=myType THEN
				RAISE typeEquTitre;
			END IF;
		END LOOP;
		
		INSERT INTO Pieces(idPiece, titre, type, idTheatre, idAuteur) 
		VALUES(myId, myTitre, myType, myIdTheatre, myIdAuteur);
		
		dbms_output.put_line('Insertion de la Pieces effectuée.');
		
		FOR unActeur IN acteursTheatre LOOP
			INSERT INTO Joue1(idActeur, idPiece) 
			VALUES(unActeur.idActeur, myId);
			dbms_output.put_line('insertion dans Joue1');
		END LOOP;
		
		EXCEPTION
		
			----------num du match deja present--------------
			WHEN dup_val_on_index THEN
			dbms_output.put_line('Pièce déjà présente.');
			
			---------------erreurs de type inconnue------------------------			
			WHEN no_data_found THEN
				IF i=1 THEN
					dbms_output.put_line('Identifiant théatre inconnue.');
				END IF;
				IF  i=2 THEN
					dbms_output.put_line(' Identifiant auteur inconnue.');
				END IF;
				
			--------------Le Grenier théâtre ne présente jamais de pièces de type Tragédie----------------		
			WHEN grenierNoTragedie THEN 			
				dbms_output.put_line('Le Grenier théâtre ne présente jamais de pièces de type Tragédie');
				
				
			--------------si la pièce est déjà donnée dans un autre théâtre (titre équivalent), --------------
			--------------le type de la pièce doit être le même.-------------
			WHEN typeEquTitre THEN dbms_output.put_line('Si la pièce est déjà donnée dans un autre théâtre (titre équivalent), 
le type de la pièce doit être le même.');
			--------------------------------------------------------------------------------------------------------------------

	END;
	/
	show errors 

	-	Directement via un ordre execute.
	EXECUTE ajout_piece(69,'Arnaud pour les nuls','Comedie',2,10);
	
	
	[Q3] Ecrire un bloc PL/SQL qui affiche pour un acteur donné (idacteur entré au 
	clavier par l’utilisateur) le nom et le prénom de l’acteur ainsi que les titres et 
	noms des auteurs  des pièces dans lesquels il joue.
	
Le bloc donnera également pour chacune des pièces le nombre d’autres acteurs qui y jouent.
Lors de l’affichage du nombre des autres acteurs qui jouent dans la pièce s’affiche 
également le nom du théâtre de ces acteurs (en utilisant un curseur de façon automatique).

	SET SERVEROUTPUT ON;
	
	
	CREATE OR REPLACE PROCEDURE acteurTravaux(myIdActeur Auteurs.idAuteur%TYPE) IS
		
	CURSOR piecesJouee IS 
		SELECT titre, nomAuteur,p.idPiece  FROM Pieces p
		INNER JOIN Joue1 j ON p.idPiece=j.idPiece
		INNER JOIN Auteurs au ON au.idAuteur=p.idAuteur
		WHERE idActeur = myIdActeur;
	
	myNomActeur Acteurs.nomActeur%TYPE; 
	myPrenomActeur Acteurs.prenomActeur%TYPE; 
	nbActeursPiece NUMBER;
	monNomActeur Acteurs.nomActeur%TYPE; 
	monPrenomActeur Acteurs.prenomActeur%TYPE; 
	monNomTheatre Theatres.nomTheatre%TYPE;
	myNomTheatre Theatres.nomTheatre%TYPE;
	
	excep_idActeur Acteurs.idActeur%TYPE;
	
	BEGIN
		SELECT idActeur INTO excep_idActeur FROM Acteurs WHERE idActeur = myIdActeur;
		
		SELECT nomActeur, prenomActeur, nomTheatre into myNomActeur, myPrenomActeur, myNomTheatre FROM Acteurs a
		INNER JOIN Theatres t ON t.idTheatre=a.idTheatre
		WHERE idActeur = myIdActeur;
		
		dbms_output.put_line('---------------------------------------------');
		dbms_output.put_line('---------------------------------------------');
		dbms_output.put_line('Cet acteur s''appelle '||myPrenomActeur||' '||myNomActeur||'. Il travail au théatre '||myNomTheatre||'.');
		dbms_output.put_line('---------------------------------------------');
		dbms_output.put_line('Il à joué dans les pièces suivantes : ');
			
		FOR unePiece IN piecesJouee LOOP
			dbms_output.put_line('---- '||unePiece.titre||' écrite par '||unePiece.nomAuteur||'.');
			SELECT COUNT(idActeur)-1 INTO nbActeursPiece FROM Joue1 
			WHERE idPiece=unePiece.idPiece;
			IF nbActeursPiece=0 THEN
				dbms_output.put_line('---- Il n''y a pas autres acteurs qui participent à cette pièce.');
			ELSE
				dbms_output.put_line('---- Il y a '||nbActeursPiece||' autres acteurs qui participent à cette pièce.');
				dbms_output.put_line('---- Les autres acteurs sont : ');
					
				FOR unActeur IN (SELECT idActeur FROM Joue1 WHERE idPiece = unePiece.idPiece AND IDActeur!=myIdActeur) LOOP
					SELECT nomActeur, prenomActeur, nomTheatre into monNomActeur, monPrenomActeur, monNomTheatre FROM Acteurs a
					INNER JOIN Theatres t ON t.idTheatre=a.idTheatre
					WHERE idActeur = unActeur.idActeur;
					
					dbms_output.put_line('-------- '||monPrenomActeur||' '||monNomActeur||' du théatre '||monNomTheatre||'.');
				END LOOP;
			END IF;
			dbms_output.put_line('---------------------------------------------');		
		END LOOP;
		dbms_output.put_line('---------------------------------------------');		
				
		
		EXCEPTION
			WHEN no_data_found THEN
				dbms_output.put_line('Identifiant d''acteur inconnue.');
	END;
	/
	show errors 

	SET SERVEROUTPUT ON;

	ACCEPT myIdActeur PROMPT 'Entrer le numero de l''Acteur : ';
	
	BEGIN
		acteurTravaux(&myIdActeur);
	END;
	/
	show errors 

	
	
