



drop table Joue cascade constraints; 
drop table Matche cascade constraints; 
drop table Match cascade constraints; 
drop table Typecomp cascade constraints; 
drop table Joueur cascade constraints; 
drop table Equipe cascade constraints; 


create table Equipe 
( idEq number(2) CONSTRAINT pk_equipe PRIMARY KEY, 
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

accept vm prompt 'Entrer le numero du match : ';
declare
	vclub1 Equipe.club%TYPE;
	vclub2 Equipe.club%TYPE;

begin 
	select club into vclub1
	from Equipe, Match
	where idmatch=&vm and idEqLoc=Equipe.idEq;
	
	select club into vclub2
	from Equipe, Match
	where idmatch=&vm and idEqVis=Equipe.idEq;
	dbms_output.put_line('les equipes ayant joué au match '||&vm|| 'sont le '||vclub1||' et le '||vclub2);
end;
/


-- [Q3]

set serveroutput on;

create or replace procedure ajout_match(
	n_match_lu Match.idmatch%TYPE, 
	date_match_lue match.dateM%TYPE, 
	id_loc_lue Match.idEqLoc%TYPE, 
	id_vis_lue Match.idEqVis%TYPE, 
	comp_lue Match.idComp%TYPE) is
	
cursor c is select idjoueur from joueur where( (ideq= id_loc_lue or ideq= id_vis_lue) and estvalide='o');
 

begin
	insert into 
	Match(idmatch, dateM, idEqLoc, idEqVis, idComp) 
	values(n_match_lu, date_match_lue, id_loc_lue, id_vis_lue, comp_lue);
	
	dbms_output.put_line('insertion de match'||n_match_lu||'se deroulant le '||date_match_lue||'effectuée');
	
	for c_joueur in  c loop
		insert into
		joue(idjoueur,idmatch)
		values(c_joueur.idjoueur,n_match_lu);
	end loop;
	
end;
/
show errors 

set serveroutput on;
execute ajout_match(5,'01/02/2006',1,2,'cf');

--Q3.2
--creer procedure stockée nbrjoueur, cette proc a pour variables d'entrée le num d'une equipe(ideq), elle doit effectuer le nombre de joueur pour ce num d'equipe

set serveroutput on;

create or replace procedure nbrjoueur( ideqlu joueur.ideq%type) is

vnbre number;

begin
	select count(idjoueur) into vnbre
	from joueur
	where ideq=ideqlu;
	
	dbms_output.put_line('le nombre de joueur de l''equipe' ||ideqlu|| 'est' ||vnbre);
end;
/

execute nbrjoueur(1);



--Q3.3
--creer procedure stockée Nomj, qui affiche les noms des joueurs et les matchs auxquels ils ont participé d'une equipe passée en parametre d'entrée

set serveroutput on;

create or replace procedure nomj(club_lu equipe.club%type) is

cursor c is (select nomjoueur, idmatch
			from joueur,equipe,joue
			where((joueur.ideq=equipe.ideq) and (club=club_lu) and (joue.idjoueur=joueur.idjoueur)));

begin	
	for ligne in  c loop		
		dbms_output.put_line('le joueur'|| ligne.nomjoueur||'appartient au club' ||club_lu||' et a joué au match'||ligne.idmatch);
	end loop;
end;
/
show errors;

execute nomj('Stade toulousain');

--ou 

set serveroutput on;

create or replace procedure nomj(club_lu equipe.club%type) is

cursor c1 is (select nomjoueur
			from joueur,equipe
			where((joueur.ideq=equipe.ideq) and (club=club_lu)));

--voir curseur paramétré
cursor c2 is (

begin	
	for ligne in  c loop		
		dbms_output.put_line('le joueur'|| ligne.nomjoueur||'appartient au club' ||club_lu||);
	end loop;
--deuxieme for
	for ligne.nomjoueur in c2...
end;
/
show errors;

execute nomj('Stade toulousain');


--Q4



	set serveroutput on;

	create or replace procedure ajout_match(
		n_match_lu Match.idmatch%TYPE, 
		date_match_lue match.dateM%TYPE, 
		id_loc_lue Match.idEqLoc%TYPE, 
		id_vis_lue Match.idEqVis%TYPE, 
		comp_lue Match.idComp%TYPE) is
		
	cursor c is select idjoueur from joueur where( (ideq= id_loc_lue or ideq= id_vis_lue) and estvalide='o');

	i number;
	excep_loc_lue  equipe.ideq%TYPE;
	excep_vis_lue  equipe.ideq%TYPE;
	excep_comp_lue  typecomp.idcomp%TYPE;
	equ_dif exception;
	vnbre1 number;
	vnbre2 number;
	nbr_match_date_joue exception;
	date_match_saison exception;
	mm_terrain exception;
	nbre_fois number;
		
	begin
	
		---------------erreurs de type inconnue------------------------
		i:=1;
		select ideq into excep_loc_lue  From Equipe Where equipe.ideq = id_loc_lue;
		i:=2;
		select ideq into excep_vis_lue From Equipe Where equipe.ideq = id_vis_lue;
		i:=3;
		select idcomp into excep_comp_lue From typecomp  Where typecomp.idComp = comp_lue;
		
		--------------equipe visiteuse differente de equipe locale----------------
		if id_loc_lue= id_vis_lue then
			raise equ_dif;
		end if;
		
		--------------une equipe ne peut jouer 2 match le mm jour-------------
		select count(ideqloc) into vnbre1
		from match
		where dateM=date_match_lue and ideqloc=id_loc_lue;
		
		select count(ideqvis) into vnbre2
		from match
		where dateM=date_match_lue and ideqvis=id_vis_lue;
		
		if (vnbre1=1) or (vnbre2=1) then
			raise nbr_match_date_joue;
		end if;
	
		---------------------date du match doit etre comprise dans la saison(septembre=>juin)---------------------------------
		
		if to_char (date_match_lue,'MM') <09 and
			to_char (date_match_lue,'MM') >06 then
			raise date_match_saison;
		end if;
		
		---------------deux equipes ne peuvent pas se rencontrer sur le mm terrain durant la mm saison------------------------------------

		select count(dateM) into nbre_fois
		from match
		where ideqloc=id_loc_lue and ideqvis=id_vis_lue;
		
		if nbre_fois>1 then
			raise mm_terrain;
		end if;
		--------------------------------------------------------------------------------------
		
		insert into 
		Match(idmatch, dateM, idEqLoc, idEqVis, idComp) 
		values(n_match_lu, date_match_lue, id_loc_lue, id_vis_lue, comp_lue);
		
		dbms_output.put_line('insertion de match'||n_match_lu||'se deroulant le '||date_match_lue||'effectuée');
		
		for c_joueur in  c loop
			insert into
			joue(idjoueur,idmatch)
			values(c_joueur.idjoueur,n_match_lu);
		end loop;
		
		exception
		
		----------num du match deja present--------------
			when dup_val_on_index then
			dbms_output.put_line('Match deja present');
			
				---------------erreurs de type inconnue------------------------			
			when no_data_found then
				if i=1 then
					dbms_output.put_line('equipe locale inconue');
				end if;
				if  i=2 then
					dbms_output.put_line('equipe visiteuse inconue');
				end if;
				if  i=3 then
					dbms_output.put_line('Type de compétition inconue');				
				end if;
				--------------equipe visiteuse differente de equipe locale----------------		
			when equ_dif then 			
				dbms_output.put_line('l''equipe locale doit etre differente de l''equipe visiteuse ');
				
				
			--------------une equipe ne peut jouer 2 match le mm jour-------------
			when nbr_match_date_joue then dbms_output.put_line('Une equipe ne peut jouer plus d''un match par jour');
			
			---------------------date du match doit etre comprise dans la saison(septembre=>juin)---------------------------------

			when date_match_saison then dbms_output.put_line('Un match ne peut etre joué hors saison');
			
			---------------deux equipes ne peuvent pas se rencontrer sur le mm terrain durant la mm saison------------------------------------
			
			when mm_terrain then dbms_output.put_line('deux equipes ne peuvent pas se rencontrer sur le mm terrain durant la mm saison');
			--------------------------------------------------------------------------------------------------------------------
	end;
	/
	show errors 

	execute ajout_match(7,'12/03/2006',1,2,'cf');


	
--Tp5 les triggers----

--Q1
alter table Joueur
add NbMatch Number(2)*

--suppression-----
create or replace trigger suppr_match after delete on joue
for each row 
begin
	update joueur 
	set nbmatch= nbmatch-1
	where idjoueur =:old.idjoueur;
	dbms_output.put_line('nbre de match mis a jour pour ce joueur');
end;

--pour tester  la suppression --
delete from joue
where idmatch=4


--insertion----
create or replace trigger ajou_match after insert on joue
for each row 
begin 
	update joueur 
	set nbmatch= nbmatch+1
	where idjoueur =:new.idjoueur;
	dbms_output.put_line('nbre de match mis a jour pour ce joueur');
end;	
	
--pour tester l'insertion----
insert into joue values (22,4,849,80,10)


--Q2

create or replace trigger verif_dif before insert on match
for each row
begin
	if :new.ideqloc =:new.ideqvis
		then raise_application_error(-20001,'les equipes doivent etre différentes');
		else dbms_output.put_line('insertion effectuée')
	end if,
end;


--Q3

create or replace trigger veri_joueur_eq
before insert  on joue
for each row

declare 
	eqloc match.ideqloc%type
	eqvis match.ideqvis%type
	veq joueur.ideq%TYPE;

begin
	select ideqloc,ideqvis into eqloc, eqvis
	from match where idmatch=:new.idmatch;
	
	select ideq into veq
	from joueur
	where idjoueur=:new.idjoueur;
	
	if (veq!=eqloc) and (veq!=eqvis) then raise_application_error(-20001, 'le joueur inseré doit appartenir des 2 equipes appartenant au match')
		else dbms_output.put_line('enregistrement inséré')
	end if;
end;

--Q4   ecrire un trigger qui lors de l'insertion d'un couple idjoueur, idmatch renvoie le meilleur buteur actuel du championnat----

create or replace trigger best_but
after insert on joue

declare
	vidjoueur joue.idjoueur%type
	vsum number;

begin 
	select idjoueur, sum(pointsmarques) into vidjoueur,vsum
	from joue
	group by idjoueur having sum(pointmarques)>= (select max(sum(pointsmarques)) from joue group by idjoueur),
	dbms_output.put_line('eofnerflken')
end;
