ALTER TABLE nom_table
ADD nom_colonne type_donnees

SET SERVEROUTPUT ON;

ACCEPT param PROMPT 'Entrer un nom de joueur :';

DECLARE
	vequipe Equipe.club%TYPE;
	vnbJoueurs NUMBER;
BEGIN
	SELECT club INTO vequipe FROM Equipe e 
	INNER JOIN Joueur j ON e.idEq = j.idEq
	WHERE nomJoueur='&param';
	
	SELECT COUNT(idJoueur)-1 INTO vnbJoueurs FROM Joueur j 
	INNER JOIN Equipe e ON e.idEq = j.idEq
	WHERE club=vequipe;
	
	DBMS_OUTPUT.PUT_LINE('L''équipe du joueur '|&param|' est '||'vequipe'||' et compte '||'vnbJoueurs '||' joueurs');
	 
END;
/
