----------------------------------------
--   EXERCICE 2 : MONO MULTI TABLES   --
----------------------------------------

/*Question 1 : Etablir les ordres SQL piur la création des tables DEPARTEMENT et EMPLOYE.*/

CREATE TABLE EMPLOYE(
NoEmp number(4) CONSTRAINT pk_emp PRIMARY KEY,
NomEmp varchar(20),
Poste varchar(100), 
NoSup number(4) CONSTRAINT fk_emp REFERENCES EMPLOYE(NoEmp),
DateEmb Date,
Salaire number(6),
Commission number(6));

CREATE TABLE DEPARTEMENT(
NoDept number(4) CONSTRAINT pk_dept PRIMARY KEY,
NomDept varchar(100),
Lieu varchar(100),
Chef number(4) CONSTRAINT fk_dept REFERENCES EMPLOYE(NoEmp));

ALTER TABLE EMPLOYE
ADD NoDept CONSTRAINT fk_empdept REFERENCES DEPARTEMENT(NoDept);

/*Question 2 : Donner les noms et salaires des employés occupant le post d'ingénieur et gagnant entre 2000 et 4000 euros. Trier les noms d'employés par ordre croissant puis par salaire décroissant*/

SELECT NomEmp, Salaire
FROM EMPLOYE
WHERE Poste = 'Ingénieur'
AND Salaire BETWEEN 2000 AND 4000
ORDER BY NomEmp, Salaire DESC;

/*Réponse attendu : Delase, Florie*/

/*Question 3 : Donner le nombre d'employés*/

SELECT COUNT(*)
FROM EMPLOYE;

/*Réponse attendu : 10*/

/*Question 4 : Donners les salaires de Michel et Roux*/

SELECT Salaire, NomEmp
FROM EMPLOYE
WHERE NomEmp = 'Michel'
OR NomEmp = 'Roux';

/*Réponse attendu : 1500 et 1500*/

/*Question 5 : Donner le projet ayant le budget minimum */

SELECT NomProj
FROM PROJET
WHERE Budget = (
	SELECT min(budget) 
	FROM projet);
	
/*Réponse attendu : Gamma*/

/*Question 6 : Dpnner les employés gagant en salaire plus que n'importe quel employé du département 30*/

SELECT NomEmp
FROM EMPLOYE
WHERE Salaire > (
	SELECT MAX(Salaire)
	FROM EMPLOYE
	WHERE NoDept = 30);
	
/*Réponse attendu : Mark, Sara, Floreal, Florie et Nicolas*/
	
	
/*Question 7 : Donner la moyenne de salaire annuel par poste pour les postes occupés par plus de 2 personnes. */


SELECT AVG(Salaire*12) 
FROM EMPLOYE
GROUP BY Poste
HAVING COUNT(Poste)>2;

/*Réponse attendu : 18000 et 38004*/

/*Question 8 : Donner les noms d'employés qui travaillent uniquement sur le projet 1 */

SELECT NomEmp
FROM EMPLOYE
WHERE NoEmp in (
	SELECT NoEmp
	FROM TRAVAILLER
	WHERE NoProj =1)
MINUS 
SELECT NomEmp
FROM EMPLOYE
WHERE NoEmp in (
	SELECT NoEmp
	FROM TRAVAILLER
	WHERE NoProj !=1);
	
/*Réponse attendu : Florie*/

/*Question 9 : Donner les employés qui travaillent sur le maximum de projets*/

SELECT NomEmp
FROM EMPLOYE
WHERE NoEmp in (
	SELECT NoEmp
	FROM TRAVAILLER
	GROUP BY NoEmp
	HAVING COUNT(noProj) = (
		SELECT MAX(COUNT(NoProj))
		FROM TRAVAILLER
		GROUP BY NoEmp));
		
/*Réponse attendu : Mark*/

/*Question 10 : Quel est le projet qui a embauché le plus de personnes? */

SELECT NoProj
FROM TRAVAILLER
GROUP BY NoProj
HAVING COUNT(NoEmp) = (
	SELECT MAX(COUNT(NoEmp))
	FROM TRAVAILLER
	GROUP BY NoProj);
	
/*Réponse attendu : Projet 3 */
	
	
	
--------------------------------------------------	
-- Exercice 3 : Curseurs et procédures stockées --
--------------------------------------------------

set serveroutpur on;


CREATE OR REPLACE PROCEDURE addEmp(NomEmp_lu EMPLOYE.NomEmp%TYPE, Poste_lu EMPLOYE.Poste%TYPE, Salaire_lu EMPLOYE.Salaire%TYPE, Commission_lu EMPLOYE.Commission%TYPE, NomSup_lu EMPLOYE.NomEmp%TYPE, NomDept_lu DEPARTEMENT.NomDept%TYPE) IS
i number;
vnmDP DEPARTEMENT.NomDept%TYPE;
vPoste EMPLOYE.Poste%TYPE;
vNoSup EMPLOYE.NoEmp%TYPE;
vnmDept DEPARTEMENT.NoDept%TYPE;
vNmProj PROJET.NomProj%TYPE;
vDateEmb date;
vNumEmp number;
SupFinancesAlpha EXCEPTION;
BEGIN
/*Gestion du nomdept inconnu*/
i:=1;
SELECT NomDept INTO vnmDP
FROM DEPARTEMENT
WHERE NomDept = NomDept_lu;

/*Gestion du poste inconnu*/
i:=2;
SELECT DISTINCT Poste INTO vPoste 
FROM EMPLOYE
WHERE Poste = Poste_lu;

/*Gestion de l'erreur Finances -> Sup alpha*/
IF NomDept_lu = 'Finances' THEN
	FOR C_Excep IN (SELECT NomProj FROM PROJET WHERE NoProj IN (
						SELECT NoProj
						FROM TRAVAILLER
						WHERE NoEmp IN (
							SELECT NoEmp
							FROM EMPLOYE
							WHERE NomEmp = NomSup_lu))) LOOP
	
	IF C_Excep.NomProj = 'Alpha' THEN RAISE SupFinancesAlpha;
	END IF;
	END LOOP;
END IF;

/*Préparation de l'insertion dans Employé*/

/*NoEmp*/
SELECT (Max(NoEmp)+1) INTO vNumEmp
FROM EMPLOYE;
/*Date d'embauche*/
SELECT SYSDATE INTO vDateEmb
FROM DUAL;
/*NoSup*/
SELECT NoEmp INTO vNoSup
FROM EMPLOYE
WHERE NomEmp = NomSup_lu;

/*NoDept*/
SELECT NoDept INTO vnmDept
FROM DEPARTEMENT
WHERE NomDept = NomDept_lu;

/*Insertion dans EMPLOYE*/
INSERT INTO EMPLOYE VALUES (vNumEmp,NomEmp_lu,Poste_lu,vNoSup,vDateEmb,Salaire_lu, Commission_lu, vnmDept);

/*Question 2 : Afficher également les projets sur lesquels travaille le supérieur*/

dbms_output.put_line('Le supérieur du nouveau employé travaille sur les projets : ');

FOR C IN (SELECT NoProj FROM TRAVAILLER WHERE NoEmp = vNoSup) LOOP
	
	SELECT NomProj INTO vNmProj
	FROM PROJET
	WHERE NoProj = C.NoProj;
	
	dbms_output.put_line('- '||vNmProj||'.');

END LOOP;

EXCEPTION
WHEN NO_DATA_FOUND THEN 
	IF i=1 THEN dbms_output.put_line('Nom de département inconnu.');
	ELSIF i=2 THEN dbms_output.put_line('Nom de poste inconnu.');
	END IF;
WHEN SupFinancesAlpha THEN dbms_output.put_line('Le supérieur ne doit pas travailler sur le projet Alpha');


END;
/

show errors;





/*Tests de Vérification de la procédure*/


/*nom de departement inconnu*/
EXECUTE addEmp('Marine','Ingénieur',1500,0,'Nicolas','Glandouille');
/*poste inconnu*/
EXECUTE addEmp('Marine','Larbin',1500,0,'Nicolas','Finances');
/*sup ne doit pas bosser sur alpha*/
EXECUTE addEmp('Marine','Ingénieur',1500,0,'Mark','Finances');
/*Exemple qui marche*/
EXECUTE addEmp('Marine','Ingénieur',1500,0,'Nicolas','Finances');




