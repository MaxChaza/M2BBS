--[Q1]
drop table Joue; 
drop table Match; 
drop table Typecomp ; 
drop table joueur; 
drop table Equipe ; 


create table Equipe 
( idEq number(2) CONSTRAINT pk_equipe PRIMARY KEY, 
club Varchar(30)); 
create table joueur 
(idjoueur number(3) CONSTRAINT pk_joueur PRIMARY KEY, 
Nomjoueur Varchar(20), 
estvalide Varchar(1) CONSTRAINT ck_estvalide CHECK (estvalide in 
('o','n',)), 
idEq Number(2) CONSTRAINT fk_joueur REFERENCES Equipe(ideq)); 

create table typeComp 
(idcomp varchar(2) CONSTRAINT pk_typecomp PRIMARY KEY, 
NomComp Varchar(30));

create table Match 
(idmatch number CONSTRAINT pk_match PRIMARY KEY, 
dateM date DEFAULT sysdate, 
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
idMatch number CONSTRAINT fk_Joue_Match REFERENCES Match(idmatch), pointsmarques number, 
tempsjeu number CONSTRAINT entreentre CHECK(tempsjeu between 0 and 120), 
numero number, 
CONSTRAINT pk_Joue PRIMARY KEY (idjoueur, idmatch)); 

-- affichage de la structure des tables 
desc Joueur; 
desc Equipe; 
desc typeComp; 
desc Match; 
desc joue; 

-- [Q2]
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

