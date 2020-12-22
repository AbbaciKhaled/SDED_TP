/*
  Script TP 5
  Réalisé en binome par: BENSALAH Kawthar / ABBACI Khaled
  Numéro du Binome : 22
  Master 2 IL - Groupe 1
  USTHB 2019/2020
*/

/* Création des tablespaces */
CREATE TABLESPACE DefaultTBS2 
    DATAFILE 'C:\DefaultTBSFile2.dat' 
    SIZE 100M AUTOEXTEND ON ONLINE;

CREATE TEMPORARY TABLESPACE TempTBS2 
    TEMPFILE 'C:\TempTBSFile2.dat' 
    SIZE 100M AUTOEXTEND ON;

/* Création d'un compte Utilisateur 'Master' */
CREATE USER Master2 
    IDENTIFIED BY psw 
    DEFAULT TABLESPACE DefaultTBS2 
    TEMPORARY TABLESPACE TempTBS2;

/*Attribution de tous les privilèges à l'utilisateur 'Master' */
GRANT ALL PRIVILEGES TO Master2;

/*Se connecter en tant que Master2*/
disconnect;
connect Master2/psw

/*Création de la table DClient*/
CREATE TABLE DClient (
    NumClient Number(10) PRIMARY KEY,
    NomClient VARCHAR2(50),
    DNClient Date );

/*Création de la table DAgence*/
CREATE TABLE DAgence (
    NumAgence Number(10) PRIMARY KEY,
    NomAgence VARCHAR2(50),
    CodeBanque Number(10),
    NomBanque VARCHAR2(50),
    CodeVille Number(10),
    NomVille VARCHAR2(50),
    CodeWilaya Number(10),
    NomWilaya VARCHAR2(50)
);

/*Création de la table DTypeCompte*/
CREATE TABLE DTypeCompte (
    CodeType Number(1) PRIMARY KEY,
    LibType VARCHAR2(50)
);


/*Création de la table DTemps*/
CREATE TABLE DTemps (
    CodeTemps Number(10) PRIMARY KEY,
    Jour VARCHAR2(15),
    LibJour VARCHAR2(15),
    Mois VARCHAR2(15),
    LibMois VARCHAR2(15),
    Année VARCHAR2(15)
);

/*Création de la table FOperation*/
CREATE TABLE FOperation (
    NumClient Number(10),
    NumAgence Number(10),
    CodeTypeCompte Number(10),
    CodeTemps Number(10),
    NbOperationR Number(10),
    NbOperationV Number(10),
    MontantR number(10,2), 
    MontantV number(10,2),
    CONSTRAINT FK_O1 
        FOREIGN KEY (NumClient) 
        REFERENCES DClient(NumClient),
    CONSTRAINT FK_O2 
        FOREIGN KEY (NumAgence) 
        REFERENCES DAgence(NumAgence),
    CONSTRAINT FK_O3 
        FOREIGN KEY (CodeTypeCompte) 
        REFERENCES DTypeCompte(CodeType),
    CONSTRAINT FK_O4 
        FOREIGN KEY (CodeTemps) 
        REFERENCES DTemps(CodeTemps),
    CONSTRAINT PK_O 
        PRIMARY KEY (NumClient, NumAgence,CodeTypeCompte, CodeTemps)
);


/*Remplissage de la table DClient*/
begin
  for i in (SELECT NumClient, NomClient, DNClient 
                FROM Master.Client)
    loop
      insert into DClient
      values (i.NumClient, i.NomClient, i.DNClient);
    end loop;
commit;      
end;
/

/*Remplissage de la table DAgence*/
begin
  for i in (
    select a.NumAgence, a.NomAgence, b.CodeBanque, 
            b.NomBanque, v.CodeVille, v.NomVille, 
            w.CodeWilaya, w.NomWilaya
            from Master.Agence a, Master.Banque b, 
                 Master.Ville v, Master.Wilaya w
            where (a.AppartientBanque=b.CodeBanque) 
                and (a.SeTrouveVille=v.CodeVille) 
                and (v.DependWilaya=w.CodeWilaya)
    )
  loop
  insert into DAgence values 
    ( i.NumAgence, i.NomAgence, i.CodeBanque, i.NomBanque, i.CodeVille, 
        i.NomVille, i.CodeWilaya, i.NomWilaya); 
  end loop;
COMMIT;
end;
/


/*Remplissage de la table DTypeCompte*/
begin
  for i in (SELECT CodeType, LibType 
            FROM Master.Type_Compte)
    loop
      insert into DTypeCompte
      values (i.CodeType, i.LibType);
    end loop;
commit;      
end;
/

/*Création d'une séquence pour l’utiliser dans le remplissage de la table DTemps*/
CREATE SEQUENCE seq MINVALUE 1 MAXVALUE 1000000 START WITH 1 INCREMENT BY 1;

/*Remplissage de la table DTemps*/
begin
 for i in (SELECT distinct TO_CHAR(DateOp,'DD/MM/YYYY') as Jour, TO_CHAR(DateOp,'DAY') as LibJour, 
            TO_CHAR(DateOp,'MM/YYYY') as Mois, TO_CHAR(DateOp,'MONTH') as LibMois, 
            TO_CHAR(DateOp,'YYYY') as Année 
            FROM Master.Operation)
    loop
        insert into DTemps values (seq.NEXTVAL, i.Jour, i.LibJour, i.Mois, i.LibMois, i.Année);
    end loop;
commit;
end;
/


/*Remplissage de la table FOperation*/
begin
  for i in (
    SELECT C.PossedeClient, C.est_domicileAg, C.AppartientType_Compte, T.CodeTemps, 
    sum(decode(O.TypeOp,2,1,0)) as NbOperationR, 
    sum(decode(O.TypeOp,1,1,0)) as NbOperationV,
    sum(decode(O.TypeOp,2,O.Montant,0)) as MontantR, 
    sum(decode(O.TypeOp,1,O.Montant,0)) as MontantV 
        FROM Master.Compte C, DTemps T, Master.Operation O 
        WHERE (C.NumCompte = O.VersementCompte or C.NumCompte = O.RetraitCompte) and
            TO_CHAR(O.DateOp,'DD/MM/YYYY') = T.Jour
            GROUP BY C.PossedeClient, C.est_domicileAg, C.AppartientType_Compte, T.CodeTemps)  
    loop
        insert into FOperation values (i.PossedeClient, i.est_domicileAg, 
                                        i.AppartientType_Compte, i.CodeTemps, 
                                        i.NbOperationR, i.NbOperationV,
                                        i.MontantR, i.MontantV); 
  end loop;
COMMIT;
end;
/

