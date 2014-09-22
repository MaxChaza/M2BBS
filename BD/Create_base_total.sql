



drop table Joue cascade constraints; 
drop table Matche cascade constraints; 
drop table Match cascade constraints; 
drop table Typecomp cascade constraints; 
drop table Joueur cascade constraints; 
drop table Equipe cascade constraints; 


create table Equipe 
( idEq number(2) CONSTRAINT pk_equipe1 PRIMARY KEY, 
club Varchar(30)); 


create table Joueur 
(idjoueur number(3) CONSTRAINT pk_joueur PRIMARY KEY, 
Nomjoueur Varchar(20), 
estvalide Varchar(1) CONSTRAINT ck_estvalide CHECK (estvalide in 
('o','n')), 
idEq Number(2) CONSTRAINT fk_joueur REFERENCES Equipe(ideq)); 

create table typeComp 
(idcomp varchar(2) CONSTRAINT pk_typecomp PRIMARY KEY, 
NomComp Varchar(30));

create table Match 
(idmatch number CONSTRAINT pk_match PRIMARY KEY, 
dateM DATE DEFAULT sysdate, 
idEqLoc number(2) CONSTRAINT fk_Match1 REFERENCES Equipe(idEq), 
idEqVis number(2) CONSTRAINT fk_Match2 REFERENCES Equipe(idEq), 
score1 number, 
score2 number, 
idComp Varchar(2) CONSTRAINT fk_Match3 REFERENCES TypeComp(idcomp)); 
--ou alter table Match 
-- ADD CONSTRAINT fk_match FOREIGN KEY (idcomp) REFERENCES TypeComp(idcomp) ;

create table Joue 
(idjoueur number(3) CONSTRAINT fk_Joue_Joueur REFERENCES 
Joueur(idjoueur) ON DELETE CASCADE, 
idMatch number CONSTRAINT fk_Joue_Match REFERENCES Match(idmatch), 
pointsmarques number, 
tempsjeu number CHECK (tempsjeu between 0 and 120), 
numero number, 
CONSTRAINT pk_Joue PRIMARY KEY (idjoueur, idmatch)); 

-- affichage de la structure des tables 
desc Joueur; 
desc Equipe; 
desc typeComp; 
desc Match; 
desc Joue; 


insert into Equipe values (1,'Stade français'); 
insert into Equipe values (2,'Stade toulousain'); 
insert into equipe values (3,'USAP'); 
insert into Equipe values (4,'SU Agen LG'); 
insert into Equipe values (5,'Biarritz Olympique');

insert into Joueur values (11,'Martin','o',1); 
insert into Joueur values (12,'Dominici','o',1); 
insert into Joueur values (13,'Skrela','n',1); 
insert into Joueur values (21,'fritz','o',2); 
insert into Joueur values (22,'Michalak','o',2); 
insert into Joueur values (23,'Elissalde','o',2); 
insert into Joueur values (41,'Califano','o',4); 
insert into Joueur values (42,'Gelez','o',4); 
insert into Joueur values (51,'Yachvilli','o',5); 
insert into Joueur values (52,'Betsen','o',5);


insert into TypeComp values ('cf','Championnat de France'); 
insert into TypeComp values ('po','Play - off'); 
insert into TypeComp values ('cl','Coupe de la ligue'); 
insert into TypeComp values ('ma','Match amical');
insert into Match values (1,'12/01/2006',1,2,12,24,'cf'); 
insert into Match values (2,'19/01/2006',2,5,32,22,'cf'); 
insert into Match values (3,'12/02/2006',5,4,20,10,'cf'); 
insert into Match values (4,'10/03/2006',2,4,45,3,'po');
insert into Joue values (11,1,12,80,6); 
insert into Joue values (21,1,10,60,12); 
insert into Joue values (23,1,14,80,9); 
insert into Joue values (51,3,20,80,9); 
insert into Joue values (41,3,5,60,3); 
insert into Joue values (42,3,5,80,10); 
insert into Joue values (23,2,20,60,9); 
insert into Joue values (22,2,12,80,10); 
insert into Joue values (51,2,22,50,9); 
insert into Joue values (21,4,15,80,12); 
insert into Joue values (22,4,15,60,10); 
insert into Joue values (41,4,3,80,10); 
insert into Joue values (23,4,15,30,22); 
commit;

-- Q1

select* from Joueur;

-- Q2

select nomjoueur, idEq from Joueur;

--Q3

select DISTINCT idEq from Joueur;

--Q4 

select* from Joueur where idEq = 2;

--Q5

select dateM, score1, score2 from Match 
where (idEqLoc =1 and idEqVis = 2) or (idEqLoc= 2 and idEqVis =1);

--Q6

select idEq, idjoueur, nomJoueur from Joueur
order by idEq ASC;

--Q7 

select idEq, idJoueur, nomJoueur from Joueur
order by idEq ASC, nomJoueur DESC

--Q8

Select idjoueur, idmatch from Joue
where pointsmarques between 15 and 50;

--Q9

Select idJoueur, nomJoueur from Joueur 
where idEq = 1 or idEq = 2;

--Q10

Select idJoueur, nomJoueur from Joueur 
where ((idEq = 1 or idEq = 2) and (estvalide = 'o'));


-- Q1

select* from Joueur;

-- Q2

select nomjoueur, idEq from Joueur;

--Q3

select DISTINCT idEq from Joueur;

--Q4 

select* from Joueur where idEq = 2;

--Q5

select dateM, score1, score2 from Match 
where (idEqLoc =1 and idEqVis = 2) or (idEqLoc= 2 and idEqVis =1);

--Q6

select idEq, idjoueur, nomJoueur from Joueur
order by idEq ASC;

--Q7 

select idEq, idJoueur, nomJoueur from Joueur
order by idEq ASC, nomJoueur DESC

--Q8

Select idjoueur, idmatch from Joue
where pointsmarques between 15 and 50;

--Q9

Select idJoueur, nomJoueur from Joueur 
where idEq = 1 or idEq = 2;

--Q10

Select idJoueur, nomJoueur from Joueur 
where ((idEq = 1 or idEq = 2) and (estvalide = 'o'));

--Q11

Select idjoueur, idmatch, pointsmarques from Joue 
where (tempsJeu = 80 or tempsJeu > 80) ;

--Q12 

Select nomjoueur from Joueur
where nomjoueur like '__r%';

--Q13

select idmatch, dateM, idEq, idEqLoc, idEqVis, score1+score2 as cumul from Match;

--Q14

select count(*) from Equipe;

--Q15

select avg(score1+score2) from Match;

-- moyenne des points marqués par joueur ayant marqué par match 

select idmatch, avg(pointsmarques) from Joue;
 
--Q16 

select sum(pointsmarques), count(idmatch), avg(pointsmarques) from Joue 
where idjoueur = 11;

--Q17

select idjoueur, sum(pointsmarques), count(idmatch), avg(pointsmarques) from Joue
group by idjoueur
order by avg(pointsmarques) DESC;

--Q18

select idjoueur, sum(pointsmarques), count(idmatch), avg(pointsmarques) from Joue
group by idjoueur
having count(idmatch) > 2;

--Q19 

select idEq from Joueur
where estvalide = 'o'
group by idEq 
having count(estvalide) >= 3;


--Exercice 2 

--Q20
--a

select club from Equipe
union 
select nomjoueur from Joueur;

--b

select club from Equipe
union 
select nomjoueur from Joueur
where Equipe.idEq = Joueur.idEq;


--Exercice 3
--Q1 

--jointures
select nomjoueur from Joueur
where Joueur.idEq in (select Equipe.idEq from Equipe where Equipe.club = 'Stade toulousain');

--req imbriquées 
select nomjoueur from Joueur, Equipe where Joueur.idEq = Equipe.idEq and Equipe.club = 'Stade toulousain';

--Q2
--jointures
select nomjoueur from Joueur
where  idjoueur in (select Joue.idJoueur from Joue  where idmatch in (select Match.idmatch from Match where dateM = '19-Jan-06'));

--Req imbriquées 
select nomjoueur from Joueur, Match, Joue 
where Joueur.idjoueur = Joue.idjoueur and Joue.idMatch = Match.idmatch and dateM = '19-jan-06';
 


--Q3
select idjoueur, nomjoueur, club from Joueur, Equipe 
where Joueur.idEq = Equipe.idEq and Equipe.club like '%Stade%'
order by club;

--Q4
select nomjoueur from Joueur, Equipe, typeComp, Match, Joue

where Joueur.idEq = Equipe.idEq
and typeComp.idcomp = Match.idcomp
and Joueur.idJoueur = Joue.idjoueur
and Match.idmatch = Joue.idmatch

and Equipe.club = 'Stade toulousain'
and nomcomp = 'Play - off';

--Q5
select nomjoueur from Joueur 
where idEq in (select ideq from Joueur where nomJoueur = 'Michalak') and nomjoueur != 'Michalak'; 

-- imbriquées
select J2.nomjoueur from Joueur J1, Joueur J2
where J1.ideq = J2.ideq 
and J1.nomjoueur = 'Michalak' 
and J2.nomjoueur != 'Michalak';

--Q6

Select nomjoueur, sum(Joue.pointsmarques) , avg(Joue.pointsmarques) from Joueur , Joue
where Joueur.idjoueur = Joue.idjoueur
group by Joueur.nomjoueur
having sum(Joue.pointsmarques) > avg(Joue.pointsmarques)

--
Select nomjoueur, sum(Joue.pointsmarques) , avg(Joue.pointsmarques),sum(Joue.pointsmarques)/count(Joueur.nomjoueur) from Joueur , Joue
where Joueur.idjoueur = Joue.idjoueur
group by Joueur.nomjoueur
having sum(Joue.pointsmarques) > sum(Joue.pointsmarques)/count(Joueur.nomjoueur);

--
Select nomjoueur, sum(pointsmarques)
from Joueur, Joue
where (Joueur.idjoueur = joue.idjoueur)
group by nomjoueur
having sum(pointsmarques) > (select avg(pointsmarques) from Joue);

--
Select nomjoueur, sum(pointsmarques)
from Joueur, Joue
where (Joueur.idjoueur = joue.idjoueur)
group by nomjoueur
having sum(pointsmarques) > sum(pointsmarques)/count(nomjoueur);


--Q7

select idjoueur, nomjoueur from Joueur
where idjoueur in (select max(pointsmarques) from Joue);

--Q8

select nomcomp from typeComp , Match
where (typeComp.idcomp = Match.idComp)
and (Match.dateM like '%SEP%')
group by nomcomp
having count(idmatch) >=2;

--Q9

select club from Equipe, Match
where Match.dateM = '12/09/06' and Equipe.idEq = idEqLoc
union
select club from Equipe, Match
where Match.dateM = '12/09/06' and Equipe.idEq = idEqVis;

--Q10

select club from Equipe, Match
where Match.dateM like '%AOUT%' and Equipe.idEq = idEqLoc
INTERSECT
select club from Equipe, Match
where Match.dateM like '%AOUT%' and Equipe.idEq = idEqVis;

--Q11

select DISTINCT(nomJoueur)
from Joueur, Joue
where Joueur.idjoueur not in (select idjoueur from Joue where pointsmarques > 0);

-- ou tous les joueurs MINUS les joueurs ayant marqué

--Q12 

select idmatch from Match
where score1+score2 > (select score1+score2 from Match where dateM = '10-Mars-06');

--Q13

select idmatch, count(idjoueur)
from Joue 
where pointsmarques > 0
 group by idmatch
 having count(idjoueur) = (select max(count(idjoueur)) from Joue 
 where Joue.pointsmarques >0
 Group by idmatch);

--Q14
select nomjoueur from Joue, Joueur
where Joue.idjoueur = Joueur.idJoueur
and pointsmarques > 0 and idmatch = 1
intersect
select nomjoueur from Joue, Joueur
where Joue.idjoueur = Joueur.idJoueur
and pointsmarques > 0 and idMatch = 2;

-- ou 
select nomjoueur
from Joueur J, Joue J01, Joue J02
where J.idJoueur = J01.idjoueur and J01.idmatch = 1 and J01.pointsmarques > 0
and J.idjoueur = J02.idjoueur and J02.idmatche = 2 and J02.pointsmarques >0;

--Q15
select nomjoueur from joueur
where joueur.ideq = 2 and idjoueur not in (select idjoueur from joue where joue.pointsmarques > 0 
 and joue.idmatch = 1);


-- ou utiliser Minus



-- TP3 

-- Q1
create or replace view Grosmatch as 
select * from Match 
where score1+score2>50;

select * from Grosmatch;

select * from cat;

--Q2
insert into Match values (5, '15/05/2006', 2, 1, 50, 20, 'cf');
commit;

select * from Match ;
select * from Grosmatch;

--Q3
delete from Grosmatch
where idMatch = 5;

select * from Match;
select * from Grosmatch;


--Q4
create or replace view JoueurEq1(idjoueur, nomjoueur ) as select * from Joueur where idEq = 1;
insert into Joueur  values ( 50, 'Jean', 'o',1);
select * from JoueurEq1;


insert into Joueureq1  values ( 30, 'Jean');
select * from JoueurEq1;

--visible dans la table mais pas dans la vue.

--Q5-1
create or replace view vmonotable as
select idjoueur,nomjoueur
from joueur
where estvalide='o'
update vmonotable set nomjoueur='MICHALAK' where nomjoueur='Michalak';
--MAJ possible monotable

--Q5-2
create or replace view vmultitable as
select nomjoueur, club
from joueur,equipe
where joueur.ideq=equipe.ideq
--MAJ impossible multitable

--Q5-3
create or replace view nbrjoueur (ideq,nbjoueur) as
select ideq,count(idjoueur)
from joueur
group by ideq;
--Maj imposs car vue contenant fonction d'agregation

--Q6

--joueur appartenant à plusieurs equipes =>
create table joueureq(
idjoueur number(3) constraint FK1_joueureq references joueur(idjoueur),
ideq number(2) constraint FK2_joueureq references equipe(ideq),
constraint PK_joueureq primary key (idjoueur,ideq));

insert into joueureq select idjoueur,ideq from joueur;
update joueur set ideq=NULL;
Alter table joueur drop column ideq

create or replace view vmultitable as
select nomjoueur,club
from joueur, joueureq,equipe
where joueur,idjoueur=joueureq.idjoueur
and joueur.ideq=equipe.ideq;


--TP4

--Q0
alter table Joueur
add NbMatch Number(2)*

--Q1
-- pour que le programme soit reconnu :
set serveroutput on;

accept vnj prompt 'Saisir le nom du joueur :';
-- vnj = variable dans laquelle l'entrée va etre mise

declare
	vequipe Joueur.IdEq%TYPE;
	vJoueur Joueur.idJoueur%TYPE;
	vnbre_eq number;
	vnbre_m number;
	
begin
	select idEq, idJoueur into vequipe, vjoueur
	from Joueur
	where nomjoueur='&vnj';
	dbms_output.put_line('l''equipe du joueur ' ||'&vnj'||' est  : '||vequipe);
	
	select  count(idJoueur)-1 into vnbre_eq
	from Joueur
	where idEq=vequipe;
	dbms_output.put_line('Nombre de joueurs dans l''équipe : '||vnbre_eq);

	select count(*) into vnbre_m
	from Joue
	where idjoueur=vjoueur;
	
	update Joueur set Nbmatch=vnbre_m where nomJoueur='&vnj';
end;
-- Si le nom n'existe pas il ne trouve pas de ligne : une exception NO_DATA_FOUND est générée 

--Q2

set serveroutput on;

accept vmatch prompt 'Entrer le numero du match : ';
declare
	vclub1 Equipe.club%TYPE;
	vclub2 Equipe.club%TYPE;

begin 
	select club into vclub1
	from Equipe, Match
	where idmatch=&vmatch and idEqLoc=Equipe.idEq;
	select club into vclub2
	from Equipe, Match
	where idmatch=&vmatch and idEqVis=Equipe.idEq;
	dbms_output.put_line('les equipes ayant joué au match '||&vmatch|| 'sont le '||vclub1||' et le '||vclub2);
end;
/

--Q3

CREATE OR REPLACE PROCEDURE ADD_MATCH(dateMatch Match.dateM%TYPE, locaux Match.ideqloc%TYPE, visiteur Match.ideqvis%TYPE, compet Match.idcomp%TYPE) IS
	CURSOR joueurEqu IS SELECT * FROM Joueur WHERE (idEq = visiteur OR idEq = locaux) AND est='o';
	id Match.idMatch%TYPE;	
BEGIN
	SELECT COUNT(idMatch)+1 INTO id FROM Match;
	
	INSERT INTO Match (idMatch, dateM, ideqloc, ideqvis, idcomp) VALUES (id, dateMatch, locaux, visiteur, compet);
	
	FOR joueurEqu_ligne IN joueurEqu LOOP
		INSERT INTO Joue (idMatch, idJoueur) VALUES (id, joueurEqu_ligne.idJoueur);
	END LOOP;
END;
/
show errors

--Q4

CREATE OR REPLACE PROCEDURE ADD_MATCH(dateMatch Match.dateM%TYPE, locaux Match.ideqloc%TYPE, visiteur Match.ideqvis%TYPE, compet Match.idcomp%TYPE) IS
	CURSOR joueurEqu IS SELECT idjoueur FROM Joueur WHERE idEq = visiteur OR idEq = locaux;
	id Match.idMatch%TYPE;	
BEGIN
	SELECT COUNT(idMatch)+1 INTO id FROM Match;
	
	INSERT INTO Match (idMatch, dateM, ideqloc, ideqvis, idcomp) VALUES (id, dateMatch, locaux, visiteur, compet);
	
	FOR joueurEqu_ligne IN joueurEqu LOOP
		INSERT INTO Joue (idMatch, idJoueur) VALUES (id, joueurEqu_ligne.idJoueur);
	END LOOP;
EXCEPTION
	
END;
/
show errors

SET serveroutput on;
execute ADD_MATCH('01/02/2009',1,2,'cf');
