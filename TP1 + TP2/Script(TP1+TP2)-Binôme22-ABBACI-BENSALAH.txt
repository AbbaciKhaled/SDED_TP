/*
  Script TP 1 + TP 2
  Réalisé en binome par: BENSALAH Kawthar / ABBACI Khaled
  Numéro du Binome : 22
  Master 2 IL - Groupe 1
  USTHB 2019/2020
*/

/* suppression des tables si jamais elles existent déjà dans la base de données */

drop table operation;
drop table compte;
drop table type_compte;
drop table agence;
drop table banque;
drop table ville;
drop table wilaya;
drop table Client;


/**************************************************************TP1**************************************************************/

/* Réponse 1 */

/* Création des tablespaces */
CREATE TABLESPACE DefaultTBS 
    DATAFILE 'C:\DefaultTBSFile.dat' 
    SIZE 100M AUTOEXTEND ON ONLINE;

CREATE TEMPORARY TABLESPACE TempTBS 
    TEMPFILE 'C:\TempTBSFile.dat' 
    SIZE 100M AUTOEXTEND ON;

/* Création d'un compte Utilisateur 'Master' */
CREATE USER Master 
    IDENTIFIED BY psw 
    DEFAULT TABLESPACE DefaultTBS 
    TEMPORARY TABLESPACE TempTBS;

/*Attribution de tous les privilèges à l'utilisateur 'Master' */
GRANT ALL PRIVILEGES TO Master;

/* Se connecter en tant que l'utilisateur 'Master' */
Disconnect;
Connect Master/psw;

/* Réponse 3 */

/*Création de la table Client*/

CREATE TABLE Client (
NumClient Number(6) PRIMARY KEY,
NomClient VARCHAR2(50),
AdrClient VARCHAR2(100),
TelClient VARCHAR2(10),
DNClient DATE
);

/*Création de la table Wilaya*/

CREATE TABLE Wilaya (
CodeWilaya Number(6) PRIMARY KEY,
NomWilaya VARCHAR2(50)
);

/*Création de la table Ville*/

CREATE TABLE Ville (
CodeVille Number(6) PRIMARY KEY,
NomVille VARCHAR2(10),
DependWilaya Number(6), /*Clé étrangère de la table Wilaya*/
CONSTRAINT FK_Ville 
  FOREIGN KEY (DependWilaya) 
  REFERENCES Wilaya(CodeWilaya)
);

/*Création de la table Banque*/

CREATE TABLE Banque (
CodeBanque Number(6) PRIMARY KEY,
NomBanque VARCHAR2(50)
);

/*Création de la table Agence*/

CREATE TABLE Agence (
NumAgence Number(6) PRIMARY KEY,
NomAgence VARCHAR2(50),
TelAgence VARCHAR2(10),
AppartientBanque Number(6), /*Clé étrangère de la table Banque*/
SeTrouveVille Number(6), /*Clé étrangère de la table Ville*/
CONSTRAINT FK_Agence1 
  FOREIGN KEY (AppartientBanque) 
  REFERENCES Banque(CodeBanque),
CONSTRAINT FK_Agence2 
  FOREIGN KEY (SeTrouveVille) 
  REFERENCES Ville(CodeVille)
);

/*Création de la table Type_Compte*/

CREATE TABLE Type_Compte (
CodeType Number(1) PRIMARY KEY,
LibType VARCHAR2(50) 
  check(LibType IN ('Epargne','Courant')) /*L'attribut LibType prend la valeur 'Epargne' ou 'Courant'*/ 
);

/*Création de la table Compte*/

CREATE TABLE Compte (
NumCompte Number(6) PRIMARY KEY,
DateOuverture DATE,
PossedeClient Number(6), /*Clé étrangère de la table Client*/
est_domicileAg Number(6), /*Clé étrangère de la table Agence*/
AppartientType_Compte Number(6), /*Clé étrangère de la table Type_Compte*/
CONSTRAINT FK_Compte1 
  FOREIGN KEY (PossedeClient) 
  REFERENCES Client(NumClient),
CONSTRAINT FK_Compte2 
  FOREIGN KEY (est_domicileAg) 
  REFERENCES Agence(NumAgence),
CONSTRAINT FK_Compte3 
  FOREIGN KEY (AppartientType_Compte) 
  REFERENCES Type_Compte(CodeType)
);

/*Création de la table Operation*/

CREATE TABLE Operation (
CodeOp Number(6) PRIMARY KEY,
DateOp DATE,
HeurOp Varchar2(5),
TypeOp VARCHAR2(1) 
  check(TypeOp IN ('1','2')),
Montant number(10,2),
VersementCompte Number(6), /*Clé étrangère de la table Compte*/
RetraitCompte Number(6), /*Clé étrangère de la table Compte*/
CONSTRAINT FK_OP1 
  FOREIGN KEY (VersementCompte) 
  REFERENCES Compte(NumCompte),
CONSTRAINT FK_OP2 
  FOREIGN KEY (RetraitCompte) 
  REFERENCES Compte(NumCompte)
);


/**************************************************************TP2**************************************************************/

/*Le code PL/SQL pour remplir la table Client*/

DECLARE
nom char(10);
adr char(100);
tel char(10);
dn DATE;
I number;
begin
  for i in 1..100000  loop
    select dbms_random.string('U',8)
      into nom
      from dual;
    select dbms_random.string('U',30)
      into adr
      from dual;
    select dbms_random.string('U',10)
      into tel
      from dual;
    select TO_DATE(TRUNC(dbms_random.value(
      TO_CHAR(DATE'2015-01-01','J'),
      TO_CHAR(DATE'2018-12-31','J'))),'J')
      into dn
      from dual;
    insert into Client
    values (i,nom,adr,tel,dn);
  end loop
COMMIT;
end;
/

/*Le code PL/SQL pour remplir la table Wilaya*/

DECLARE
nom char(10);
I number;
begin
  for i in 1..48  loop
    select dbms_random.string('U',8)
      into nom
      from dual;
    insert into Wilaya
    values (i,nom);
  end loop
COMMIT;
end;
/

/*Le code PL/SQL pour remplir la table Ville*/

DECLARE
v char(10);
w number;
I number;
begin
  for i in 1..330 loop
    select dbms_random.string('U',8)
      into v
      from dual;
    select FLOOR(dbms_random.value(1,48.9))
      into w
      from dual;
    insert into Ville
    values (i,v,w);
  end loop
COMMIT;
end;
/

/*Le code PL/SQL pour remplir la table Banque*/

DECLARE
nom char(10);
I number;
begin
  for i in 1..10  loop
    select dbms_random.string('U',8)
      into nom
      from dual;
    insert into Banque
    values (i,nom);
  end loop
COMMIT;
end;
/

/*Le code PL/SQL pour remplir la table Agence*/

DECLARE
nom char(10);
tel char(10);
ab number;
stv number;
I number;
begin
  for i in 1..12300  loop
    select dbms_random.string('U',8)
      into nom
      from dual;
    select dbms_random.string('U',8)
      into tel
      from dual;
    select FLOOR(dbms_random.value(1,10.9))
      into ab
      from dual;
    select FLOOR(dbms_random.value(1,330.9))
      into stv
      from dual;
    insert into Agence
    values (i,nom,tel,ab,stv);
  end loop
COMMIT;
end;
/

/*Le code PL/SQL pour remplir la table Type_Compte*/

begin
    insert into Type_Compte
    values (1,'Epargne');
    insert into Type_Compte
    values (2,'Courant');
COMMIT;
end;
/

/*Le code PL/SQL pour remplir la table Compte*/

DECLARE
do DATE;
pc number;
eda number;
atc number;
I number;
begin
  for i in 1..200000  loop
    select TO_DATE(TRUNC(dbms_random.value( 
      TO_CHAR(DATE'2016-01-01','J'),  
      TO_CHAR(DATE'2018-12-31','J'))),'J')
      into do
      from dual;
    select FLOOR(dbms_random.value(1,100000.9))
      into pc
      from dual;
    select FLOOR(dbms_random.value(1,12300.9))
      into eda
      from dual;
    select FLOOR(dbms_random.value(1,2.9))
      into atc
      from dual;
    insert into Compte
    values (i,do,pc,eda,atc);
  end loop
COMMIT;
end;
/

/*Le code PL/SQL pour remplir la table Operation*/

DECLARE
d DATE;
heure char(5);
typeop char(1);
montant number;
cpt number;
I number;
begin
  for i in 1..610314  loop
    select TO_DATE(TRUNC(dbms_random.value(
      TO_CHAR(DATE'2015-01-01','J'),
      TO_CHAR(DATE'2018-12-31','J'))),'J')
      into d
      from dual;
    select trunc(dbms_random.value(5000,100000),2)
      into montant
      from dual;
    select dbms_random.string('U',5)
      into heure
      from dual;
    select FLOOR(dbms_random.value(1,2.9))
      into typeop
      from dual;    
    select FLOOR(dbms_random.value(1,200000))
      into cpt
      from dual;
    insert into Operation
    values (i,d,heure,typeop,montant,
      decode(typeop,1,cpt,null),
      decode(typeop,2,cpt,null));
  end loop
COMMIT;
end;
/



