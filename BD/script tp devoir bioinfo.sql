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
		SELECT nomActeur, prenomActeur INTO myNomActeur, myPrenomActeur FROM Acteurs WHERE idActeur = myIdActeur;
		
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

	
	
