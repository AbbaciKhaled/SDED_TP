/*
  Script TP 4
  Réalisé en binome par: BENSALAH Kawthar / ABBACI Khaled
  Numéro du Binome : 22
  Master 2 IL - Groupe 1
  USTHB 2019/2020
*/


/*Réponse 1*/

/*Activation des options autotrace et timing de oracle*/
set timing on;
set autotrace on explain;

/*Réponse 2*/
/*Changer le nom de la Wilaya numéro 31 à Oran*/
update Wilaya
   set NomWilaya = 'Oran'
 where CodeWilaya = 31;

/*Vider les buffers*/
alter system flush shared_pool;
alter system flush buffer_cache;

/*Exécution de la requête R1*/
select C.NumClient, C.NomClient
       from Client C, Compte CC, Agence A, Ville V, Wilaya W
      where C.NumClient = CC.PossedeClient
      and CC.est_domicileAg = A.NumAgence
      and A.SeTrouveVille = V.CodeVille
      and V.DependWilaya = W.CodeWilaya
      and W.NomWilaya = 'Oran';

/*Réponse 3*/
/*Examination du temps + plan d’exécution */

/*Réponse 4*/
/*Création de la vue matérialisée VM5*/
CREATE MATERIALIZED VIEW VM5
    BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND
    enable query rewrite
    AS select C.NumClient, C.NomClient
       from Client C, Compte CC, Agence A, Ville V, Wilaya W
      where C.NumClient = CC.PossedeClient
      and CC.est_domicileAg = A.NumAgence
      and A.SeTrouveVille = V.CodeVille
      and V.DependWilaya = W.CodeWilaya;

/*Réponse 5*/
/*Vider les buffers*/
alter system flush shared_pool;
alter system flush buffer_cache;

/*Réexécution de la requête R1*/
select C.NumClient, C.NomClient
       from Client C, Compte CC, Agence A, Ville V, Wilaya W
      where C.NumClient = CC.PossedeClient
      and CC.est_domicileAg = A.NumAgence
      and A.SeTrouveVille = V.CodeVille
      and V.DependWilaya = W.CodeWilaya
      and W.NomWilaya = 'Oran';

/*Examination du temps + plan d’exécution */

/*Réponse 6*/
/*Création de la vue matérialisée VM6*/
CREATE MATERIALIZED VIEW VM6
    BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND
    enable query rewrite
    AS select C.NumClient, C.NomClient
       from Client C, Compte CC, Agence A, Ville V, Wilaya W
      where C.NumClient = CC.PossedeClient
      and CC.est_domicileAg = A.NumAgence
      and A.SeTrouveVille = V.CodeVille
      and V.DependWilaya = W.CodeWilaya
      and W.NomWilaya = 'Oran';

/*Réponse 7*/
/*Vider les buffers*/
alter system flush shared_pool;
alter system flush buffer_cache;

/*Réexécution de la requête R1*/
select C.NumClient, C.NomClient
       from Client C, Compte CC, Agence A, Ville V, Wilaya W
      where C.NumClient = CC.PossedeClient
      and CC.est_domicileAg = A.NumAgence
      and A.SeTrouveVille = V.CodeVille
      and V.DependWilaya = W.CodeWilaya
      and W.NomWilaya = 'Oran';

/*Examination du temps + plan d’exécution */

/*Réponse 8*/
/*Vider les buffers*/
alter system flush shared_pool;
alter system flush buffer_cache;

/*Exécution de la requête R2 */
select B.CodeBanque, B.NomBanque, count(O.CodeOp) as NbOperations
  from Banque B, Compte C, Agence A, Operation O
 where (O.VersementCompte = C.NumCompte or O.RetraitCompte = C.NumCompte)
 and C.est_domicileAg = A.NumAgence
 and A.AppartientBanque = B.CodeBanque
 group by B.CodeBanque, B.NomBanque;

/*Réponse 9*/
/*Examination du temps + plan d’exécution */

/*Réponse 10*/
/*Création de la vue matérialisée VM7*/
 CREATE MATERIALIZED VIEW VM7
    BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND
    enable query rewrite
    AS select B.CodeBanque, B.NomBanque, count(O.CodeOp) as NbOperations
  from Banque B, Compte C, Agence A, Operation O
 where (O.VersementCompte = C.NumCompte or O.RetraitCompte = C.NumCompte)
 and C.est_domicileAg = A.NumAgence
 and A.AppartientBanque = B.CodeBanque
 group by B.CodeBanque, B.NomBanque;

/*Réponse 11*/
/*Vider les buffers*/
alter system flush shared_pool;
alter system flush buffer_cache;

/*Réexécution de la requête R2 */
select B.CodeBanque, B.NomBanque, count(O.CodeOp) as NbOperations
  from Banque B, Compte C, Agence A, Operation O
 where (O.VersementCompte = C.NumCompte or O.RetraitCompte = C.NumCompte)
 and C.est_domicileAg = A.NumAgence
 and A.AppartientBanque = B.CodeBanque
 group by B.CodeBanque, B.NomBanque;

 /*Examination du temps + plan d’exécution */

/*Réponse 12*/
/*Augmentation du nombre d'instance de la table Operation à 800000*/
DECLARE
d DATE;
heure char(5);
typeop char(1);
montant number;
cpt number;
I number;
begin
  for i in 610315..800000  loop
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

/*Rafraichissement de la vue VM7*/
execute DBMS_MVIEW.REFRESH('VM7');

/*Vider les buffers*/
alter system flush shared_pool;
alter system flush buffer_cache;

/*Réexécution de la requête R2 */
select B.CodeBanque, B.NomBanque, count(O.CodeOp) as NbOperations
  from Banque B, Compte C, Agence A, Operation O
 where (O.VersementCompte = C.NumCompte or O.RetraitCompte = C.NumCompte)
 and C.est_domicileAg = A.NumAgence
 and A.AppartientBanque = B.CodeBanque
 group by B.CodeBanque, B.NomBanque;

/*Examination du temps + plan d’exécution */

/*Suppression de la vue VM7*/
drop MATERIALIZED VIEW vm7;

/*Vider les buffers*/
alter system flush shared_pool;
alter system flush buffer_cache;

/*Réexécution de la requête R2 */
select B.CodeBanque, B.NomBanque, count(O.CodeOp) as NbOperations
  from Banque B, Compte C, Agence A, Operation O
 where (O.VersementCompte = C.NumCompte or O.RetraitCompte = C.NumCompte)
 and C.est_domicileAg = A.NumAgence
 and A.AppartientBanque = B.CodeBanque
 group by B.CodeBanque, B.NomBanque;

/*Examination du temps + plan d’exécution */


/*Réponse 12*/
/*Augmentation du nombre d'instance de la table Operation à 1000000*/
DECLARE
d DATE;
heure char(5);
typeop char(1);
montant number;
cpt number;
I number;
begin
  for i in 800001..1000000  loop
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

/*Vider les buffers*/
alter system flush shared_pool;
alter system flush buffer_cache;

/*Réexécution de la requête R2 */
select B.CodeBanque, B.NomBanque, count(O.CodeOp) as NbOperations
  from Banque B, Compte C, Agence A, Operation O
 where (O.VersementCompte = C.NumCompte or O.RetraitCompte = C.NumCompte)
 and C.est_domicileAg = A.NumAgence
 and A.AppartientBanque = B.CodeBanque
 group by B.CodeBanque, B.NomBanque;

/*Examination du temps + plan d’exécution */

/*Création de la vue VM7*/
 CREATE MATERIALIZED VIEW VM7
    BUILD IMMEDIATE REFRESH COMPLETE ON DEMAND
    enable query rewrite
    AS select B.CodeBanque, B.NomBanque, count(O.CodeOp) as NbOperations
  from Banque B, Compte C, Agence A, Operation O
 where (O.VersementCompte = C.NumCompte or O.RetraitCompte = C.NumCompte)
 and C.est_domicileAg = A.NumAgence
 and A.AppartientBanque = B.CodeBanque
 group by B.CodeBanque, B.NomBanque;

/*Vider les buffers*/
alter system flush shared_pool;
alter system flush buffer_cache;

/*Réexécution de la requête R2 */
select B.CodeBanque, B.NomBanque, count(O.CodeOp) as NbOperations
  from Banque B, Compte C, Agence A, Operation O
 where (O.VersementCompte = C.NumCompte or O.RetraitCompte = C.NumCompte)
 and C.est_domicileAg = A.NumAgence
 and A.AppartientBanque = B.CodeBanque
 group by B.CodeBanque, B.NomBanque;

/*Examination du temps + plan d’exécution */


/*Réponse 13*/
/*Tableau comparatif des temps d’exécution*/

/*Réponse 14*/
/*Conclusion*/
