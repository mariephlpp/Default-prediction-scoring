/**********************************
* SCORING PROJECT - M2 D3S AND SE
*
* Alexandra AMANI, Colombe BEQUART, 
* Marie PHILIPPE & Claire SERRAZ
**********************************/ 

/****************************************************/
/*                   CONTENT                        */
/*												    */
/* INITIALISATION								    */
/* PART 1: GENERAL INFORMATION ABOUT THE DATASET    */ 
/* PART 2: SELECTION OF THE QUALITATIVE VARIABLES   */ 
/* 		2.1: UNIVARIATE ANALYSIS					*/
/* 		2.2: BIVARIATE ANALYSIS						*/
/* PART 3: SELECTION OF THE QUANTITATIVE VARIABLES  */ 
/* 		3.1: UNIVARIATE ANALYSIS					*/
/* 		3.2: BIVARIATE ANALYSIS						*/
/*		3.3: CREATION OF MODALITIES (DISCRETIZATION)*/
/* PART 4 : VARIABLES ENGENEERING                   */ 
/* 		4.1: GROUPING MODALITIES 					*/
/* 		4.2: QUANTITATIVE VARIABLE DISCRETIZATION   */
/* 		4.3 : CROSSING RELATED VARIABLES            */
/* PART 5: MODELS                                   */ 
/* 		5.1: SPLIT INTO TRAIN AND TEST SETS         */
/* 		5.2: MODELS                                 */
/* 			5.2.1: FIRST MODEL: ALL THE VARIABLES   */
/* 			5.2.2: MODALITIES MODIFICATION          */
/* 			5.2.3: SECOND MODEL: ALL THE NEW        */
/*				   VARIABLES                        */
/* 			5.2.4: THIRD MODEL: STEPWISE MODEL      */
/* 			5.2.5: FOURTH MODEL: BEST MODEL         */
/* 			5.2.6: EVALUATION ON THE TEST           */
/* 			5.2.7: MODEL ON MORAL CUSTOMERS         */
/* PART 6: SCORE                                    */ 
/* 		6.1: WEIGHTS                                */
/* 		6.2: SCORE                                  */
/****************************************************/
/****************************************************/
/****************************************************/

/******************/
/* INITIALISATION */ 
/******************/

* Creation of the library; 
libname Scoring '/home/u49982298/Scoring';

/* proc export data=Scoring.table
outfile = '/home/u49982298/Scoring/base_export.xlsx'
dbms = xlsx;
run;

proc import datafile='/home/u49982298/Scoring/base_export.xlsx' 
DBMS=xlsx 
OUT=Scoring.table replace;
run; */ 

/****************************************************/
/****************************************************/
/****************************************************/
/* PART 1: GENERAL INFORMATION ABOUT THE DATASET    */ 
/****************************************************/

* List of the variables;
proc contents data=Scoring.table; run;

* Frequency of the interest variable; 
proc freq data=Scoring.table ;
tables top_def_12m_90j; run;

/****************************************************/
/****************************************************/
/****************************************************/
/****************************************************/
/****************************************************/
/****************************************************/
/* PART 2: SELECTION OF THE QUALITATIVE VARIABLES   */ 
/****************************************************/

/****************************************************/
/* 		2.1: UNIVARIATE ANALYSIS					*/
/****************************************************/

* Macro to define all the qualitative variables; 
%let var_quali =
		CSP
		sit_familiale
		sit_matrimonial 
		statut_juridique 
		statut_eco 
		top_compte_joint
		type_compte
		top_pret_infine 
		top_pret_relais 
		top_Gar_Autre 
		top_Gar_Cnp
		top_Gar_Hyp
		top_Gar_Crelog
		top_credit
		top_DAV
		top_fac_caisse
		topEpargne
		topTitrePEA
		topCreditImmo
		topCred
		topAssurVIE
		topAssuIARD
		topGestionPTF
		topAutre
		topService
		topFacilite
		topDecNonAut
		topDecAuto;

* Frequency tables;
proc freq data=Scoring.table;
tables &var_quali;
run;

* Keeping only physical persons being individuals;
data Scoring.table2;
set Scoring.table;
where statut_juridique="Personne physique" & statut_eco="Particulier";
run;

proc contents data=Scoring.table2; run;

* Frequency tables on the new table;
proc freq data=Scoring.table2;
tables &var_quali;
run;

* Macro to define the qualitative variables kept 
after the univariate analysis; 
%let var_quali_kept_uni =
		CSP
		sit_familiale
		top_compte_joint
		type_compte
		top_Gar_Cnp 
		top_credit
		topTitrePEA
		topCreditImmo
		topAssurVIE
		topAssuIARD
		topGestionPTF
		topFacilite;

/****************************************************/
/* 		2.2: BIVARIATE ANALYSIS      				*/
/****************************************************/

* Create new table keeping only the qualitative
variables choosen so far;
data Scoring.table_biv_quali;
set Scoring.table2;
keep &var_quali_kept_uni top_def_12m_90j matricule;
run;

* Isolate output;
ods output chisq=sortie1_quali;

* Variables are crossed with the variable of interest;
proc freq data=Scoring.table_biv_quali;
tables (&var_quali_kept_uni) * top_def_12m_90j /chisq;
run;

* We keep only the V de Cramer statistics;
data quali_cramer;
set sortie1_quali;
where statistic = "V de Cramer";
ABS_V_CRAMER = ABS(ROUND(Value, 0.00001));
Variable = scan(table,2," ");
keep Variable Value ABS_V_CRAMER;
run;

* Table in descing order of the V de Cramer;
proc sort data=quali_cramer;
by descending ABS_V_CRAMER;
run;

* Macro to define the qualitative variables kept 
after the bivariate analysis; 
%let var_quali_kept_biv =
		topFacilite
		CSP
		topAssuIARD
		type_compte
		sit_familiale
		top_Gar_Cnp 
		top_compte_joint
		topAssurVIE;

* Variables are crossed between them;
proc freq data=Scoring.table_biv_quali;
tables (&var_quali_kept_biv) * (&var_quali_kept_biv) /chisq;
run;	
		
* Macro to define the qualitative variables kept ; 
%let var_quali_kept =
		topFacilite
		CSP
		topAssuIARD
		type_compte
		sit_familiale
		top_Gar_Cnp 
		topAssurVIE;	
		
		
		
/****************************************************/
/****************************************************/
/****************************************************/
/****************************************************/
/****************************************************/
/****************************************************/
/* PART 3: SELECTION OF THE QUANTITATIVE VARIABLES  */ 
/****************************************************/

/****************************************************/
/* 		3.1: UNIVARIATE ANALYSIS					*/
/****************************************************/

* Macro to define all the quantitative variables; 
%let var_quanti=
		age
		anc_cli_bqe
		capital_restant_du
		montant_impaye
		montant_garantie
		montant_ori_pret
		montant_ori_pret_max
		mtn_imp_6m_min
		mtn_imp_6m_max
		mtn_imp_6m_mean
		anciennete_pret
		solde_cpte_courant
		solde_cpte_courant_min
		montant_aut
		montant_aut_max
		montant_aut_min
		solde_6m_min
		solde_6m_max
		solde_6m_mean
		max_debit
		max_credit
		sum_debit
		sum_credit
		nb_debit
		nb_credit
		sum_debit_6m_min
		sum_debit_6m_max
		sum_debit_6m_mean
		sum_credit_6m_min
		sum_credit_6m_max
		sum_credit_6m_mean
		nb_debit_6m_min
		nb_debit_6m_max
		nb_debit_6m_mean
		nb_credit_6m_min
		nb_credit_6m_max
		nb_credit_6m_mean
		mtn_avoirs
		mtn_engage
		mtn_liqui
		mtn_assu
		mtn_cptecourant
		mtn_cptecourant_min
		mtn_investm
		mtn_epargne
		sld_avoirs_6m_min
		sld_avoirs_6m_max
		sld_avoirs_6m_mean
		sld_engage_6m_min
		sld_engage_6m_max
		sld_engage_6m_mean
		sld_liqu_6m_min
		sld_liqu_6m_max
		sld_liqu_6m_mean
		sld_assu_6m_min
		sld_assu_6m_max
		sld_assu_6m_mean
		sld_courant_6m_min
		sld_courant_6m_max
		sld_courant_6m_mean
		sld_invest_6m_min
		sld_invest_6m_max
		sld_invest_6m_mean
		sld_epargne_6m_min
		sld_epargne_6m_max
		sld_epargne_6m_mean
		sum_C_201704_201610
		sum_D_201704_201610
		sum_DC_201704_201610;

* Summary statistics of the quantitative variables;
proc means data=Scoring.table2 ;
var &var_quanti;
run;

**************** AGE ****************;

* Frequency table of the age; 
proc freq data=Scoring.table2 ;
tables age;
run;

* Delete rows where the age is missing, higher than 109 
or smaller than 2;
data Scoring.table3;
set Scoring.table2;
if cmiss(of age) or age > 109 or age <= 2 then delete;
run;

*************************************;

* Univariate analysis; 
proc univariate data=Scoring.table3 ;
var &var_quanti;
run;

proc sgplot data=Scoring.table3;
  histogram montant_garantie;
  density montant_garantie;
run;

proc sgplot data=Scoring.table3;
  histogram capital_restant_du;
  density capital_restant_du;
run;

* Macro to define all the quantitative variables 
kept after the univariate analysis; 
%let var_quanti_kept_uni=
		age
		anc_cli_bqe
		solde_cpte_courant
		solde_cpte_courant_min
		solde_6m_min
		solde_6m_max
		solde_6m_mean
		max_debit
		max_credit
		sum_debit
		sum_credit
		nb_debit
		nb_credit
		sum_debit_6m_min
		sum_debit_6m_max
		sum_debit_6m_mean
		sum_credit_6m_min
		sum_credit_6m_max
		sum_credit_6m_mean
		nb_debit_6m_min
		nb_debit_6m_max
		nb_debit_6m_mean
		nb_credit_6m_min
		nb_credit_6m_max
		nb_credit_6m_mean
		mtn_avoirs
		mtn_liqui
		mtn_cptecourant
		mtn_cptecourant_min
		sld_avoirs_6m_min
		sld_avoirs_6m_max
		sld_avoirs_6m_mean
		sld_liqu_6m_min
		sld_liqu_6m_max
		sld_liqu_6m_mean
		sld_courant_6m_min
		sld_courant_6m_max
		sld_courant_6m_mean
		sum_C_201704_201610
		sum_D_201704_201610
		sum_DC_201704_201610;

/****************************************************/
/* 		3.2: BIVARIATE ANALYSIS					*/
/****************************************************/

* Correlation tables with the variable of interest;
proc corr data=Scoring.table3 best=16;
var &var_quanti_kept_uni top_def_12m_90j;
run;

* Correlation tables;
proc corr data=Scoring.table3 ;
var nb_credit nb_credit_6m_min nb_credit_6m_max nb_credit_6m_mean;
run;

* Correlation tables;
proc corr data=Scoring.table3 ;
var nb_debit nb_debit_6m_min nb_debit_6m_max nb_debit_6m_mean;
run;

* Correlation tables;
proc corr data=Scoring.table3 ;
var sld_avoirs_6m_mean sld_avoirs_6m_min;
run;

* Correlation tables;
proc corr data=Scoring.table3 ;
var mtn_cptecourant sld_courant_6m_mean mtn_cptecourant_min;
run;

* Macro to define all the quantitative variables 
kept; 
%let var_quanti_kept=
		age
		anc_cli_bqe
		nb_debit
		nb_credit
		sld_liqu_6m_mean
		sld_avoirs_6m_mean
		mtn_cptecourant;

* Check correlation between the variables kept;		
proc corr data=Scoring.table3 noprob;
var &var_quanti_kept;
run;		

**************** NA *****************;

* Summary statistics to see if there are missing values;
proc means data=Scoring.table3 ;
var &var_quanti_kept;
run;

* Delete missing values;
data Scoring.table4;
set Scoring.table3;
if cmiss(of anc_cli_bqe) then delete;
run;




/****************************************************/
/****************************************************/
/****************************************************/
/****************************************************/
/****************************************************/
/****************************************************/
/* PART 4 : VARIABLES ENGENEERING                */ 
/****************************************************/

/****************************************************/
/* 		4.1: GROUPING MODALITIES 					*/
/****************************************************/

* Looking at the qualitative variables modalities;
proc freq data= scoring.table4;
tables (&var_quali_kept) * top_def_12m_90j;
run; 

* Keep only certain variables;
data Scoring.tablegroup;
set Scoring.table4;
keep &var_quali_kept &var_quanti_kept top_def_12m_90j matricule;
run;

* Grouping modalities; 
data Scoring.tablegroup; 
set Scoring.tablegroup;

	* CSP;
	if CSP in ("Agriculteurs","Artisans, commercants, chef entreprise","Autre","Ouvriers") then CSP2="1. Ouvriers agriculteurs"; 
	else if CSP in ("Sans activite","Employes","Non renseigne") then CSP2= "3. Autres";
	else if CSP in ("Cadre, profession superieures","Professions intermediaires") then CSP2= "2. Cadres";
	else CSP2="4. Retraites";
	
	* Familly;
	if sit_familiale in ("Célibataire","Divorcé(e)","Séparé(e)") then sit_familiale2="1. Celibataire seul divorce"; 
	else if sit_familiale in ("Non renseigné","Veuf(ve)","Pacs") then sit_familiale2="2. Autres";
	else sit_familiale2="3. Marie";
	
	* Insurances;
	if topAssurVIE=0 then topAssurVIE2="2. sans"; else topAssurVIE2="1. avec";
	if topAssuIARD=0 then topAssuIARD2="2. sans"; else topAssuIARD2="1. avec";
	if top_Gar_Cnp=0 then top_Gar_Cnp2="2. sans"; else top_Gar_Cnp2="1. avec"; 
	if topFacilite=0 then topFacilite2="2. sans"; else topFacilite2="1. avec"; 
	
	* Bank account;
	if type_compte = "Compte individuel uniquement" then type_compte2="1. Compte individuel uniquement"; 
	else if type_compte ="Compte joint et individuel" then type_compte2="2. Compte joint et individuel";
	else type_compte2="3. Compte joint uniquement";
	
run;

*Contingency tables of new variables;
proc freq data= scoring.tablegroup;
tables (CSP2 sit_familiale2) * top_def_12m_90j;
run;

/****************************************************/
/* 		4.2: QUANTITATIVE VARIABLE DISCRETIZATION   */
/****************************************************/

%INCLUDE "/home/u49982298/Scoring/discret.sas" ;

* Creation of a macro to reduce the size of the code ;
%macro decoup(variable, donnee); 
	%decody2(data=&donnee,
             critere=top_def_12m_90j,
             var=&variable,
             freq_min=0.05,
             autodec=1,
             typecrit=bin,Title='decoup variable');
%mend ;

* Finding the right modalities grouping;
%decoup(age, Scoring.tablegroup); 
%decoup(anc_cli_bqe, Scoring.tablegroup); 
%decoup(nb_debit, Scoring.tablegroup); 
%decoup(nb_credit, Scoring.tablegroup); 
%decoup(sld_liqu_6m_mean, Scoring.tablegroup); 
%decoup(sld_avoirs_6m_mean, Scoring.tablegroup);
%decoup(mtn_cptecourant, Scoring.tablegroup); 

* Creating the new modalities;
data Scoring.tablegroup;
set Scoring.tablegroup;
	if age <= 63 then age2 = "1. inf 63"; 
	else if  age >63 and age <= 83 then age2 = "2. btw 63 and 83";
	else age2 = "3. sup 83";
	
	if anc_cli_bqe<=22 then anc_cli_bqe2= "1. inf 22"; else anc_cli_bqe2="2. sup 22";
	
	if nb_debit<=0 then nb_debit2= "1. inf 0"; else nb_debit2="2. sup 0";
	
	if nb_credit<=0 then nb_credit2= "1. inf 0"; else nb_credit2="2. sup 0";
	
	if sld_liqu_6m_mean<=72.389 then sld_liqu_6m_mean2= "1. inf 72.3"; else sld_liqu_6m_mean2="2. sup 72.3";
	
	if sld_avoirs_6m_mean<=107.673 then sld_avoirs_6m_mean2 ="1. inf 107.6"; 
	else sld_avoirs_6m_mean2 = "2. sup 107.6";
	
	if mtn_cptecourant<=-0.09 then mtn_cptecourant2 ="1. inf -0.09"; 
	else mtn_cptecourant2 = "2. sup -0.09";
	
run;

* Macro with the variables kept so far;
%let var_mod=
		age2
		anc_cli_bqe2
		nb_debit2
		nb_credit2
		sld_liqu_6m_mean2
		sld_avoirs_6m_mean2
		mtn_cptecourant2
		
		type_compte2
		topAssurVIE2
		topAssuIARD2
		top_Gar_Cnp2
		topFacilite2
		sit_familiale2
		CSP2
;

/****************************************************/
/* 		4.3 : CROSSING RELATED VARIABLES            */
/****************************************************/

* Find variable that should be crossed with Cramer's V Statistics;
* Isolate output;
ods output chisq=sortie1_cross;

* Variables are crossed with the variable of interest;
proc freq data=Scoring.tablegroup;
tables (&var_mod) * (&var_mod) /chisq;
run;

* We keep only the V de Cramer statistics;
data cross_cramer;
set sortie1_cross;
where statistic = "V de Cramer";
ABS_V_CRAMER = ABS(ROUND(Value, 0.00001));
Variable = scan(table,2," ");
keep Variable Value ABS_V_CRAMER;
run;

* Table in descing order of the V de Cramer;
proc sort data=cross_cramer;
by descending ABS_V_CRAMER;
run;

* Crossing of the variables;
data Scoring.tablegroup; 
set Scoring.tablegroup;
	cred_deb = (nb_credit2||nb_debit2);
	avoir_liq = (sld_avoirs_6m_mean2||sld_liqu_6m_mean2);
	age_csp = (CSP2||age2);
	cred_topfac = (nb_credit2||topFacilite2);
	deb_topfac = (nb_debit2||topFacilite2);
	age_anc =  (age2||anc_cli_bqe2);
	assu_vie_iard = (topAssurVIE2||topAssuIARD2);
	famil_compte = (type_compte2||sit_familiale2);
	liq_comptecour = (sld_liqu_6m_mean2||mtn_cptecourant2);
run;

* Macro to define all crossed variables; 
%let var_cross=
		cred_deb
		avoir_liq
		age_csp
		cred_topfac
		deb_topfac
		age_anc
		assu_vie_iard
		famil_compte
		liq_comptecour
;

* Contingency table of the crossed variables;
proc freq data= Scoring.tablegroup;
tables (&var_cross) * top_def_12m_90j;
run; 

* Grouping the modalities; 
data Scoring.tablegroup; 
set Scoring.tablegroup;
	
	* avoir_liq2;
	if avoir_liq="2. sup 107.62. sup 72.3" 
	then avoir_liq2="1. avoir sup 107 liq sup 72.3";
	else avoir_liq2 = '2. autres avoir liq';

run;

	
* Macro to define all crossed variables ; 
%let var_cross2=
		avoir_liq2
		anc_cli_bqe2
		mtn_cptecourant2
		type_compte2
		topAssurVIE2
		topAssuIARD2
		top_Gar_Cnp2
		topFacilite2
		sit_familiale2
		cred_deb
		age2
		CSP2
;

* Contingency table;
proc freq data= Scoring.tablegroup;
tables (&var_cross2) * top_def_12m_90j;
run; 

*Dependence of the variables crossed between them;
* Isolate output;
ods output chisq=sortie2_cross;

* Variables are crossed with the variable of interest;
proc freq data=Scoring.tablegroup;
tables (&var_cross2) * (&var_cross2) /chisq;
run;

* We keep only the V de Cramer statistics;
data cross_cramer2;
set sortie2_cross;
where statistic = "V de Cramer";
ABS_V_CRAMER = ABS(ROUND(Value, 0.00001));
Variable = scan(table,2," ");
keep Variable Value ABS_V_CRAMER;
run;

* Table in descing order of the V de Cramer;
proc sort data=cross_cramer2;
by descending ABS_V_CRAMER;
run;

*Dependence of the variables and the target variable;
* Isolate output;
ods output chisq=sortie3_cross;

* Variables are crossed with the variable of interest;
proc freq data=Scoring.tablegroup;
tables (&var_cross2) * top_def_12m_90j /chisq;
run;

* We keep only the V de Cramer statistics;
data cross_cramer3;
set sortie3_cross;
where statistic = "V de Cramer";
ABS_V_CRAMER = ABS(ROUND(Value, 0.00001));
Variable = scan(table,2," ");
keep Variable Value ABS_V_CRAMER;
run;

* Table in descing order of the V de Cramer;
proc sort data=cross_cramer3;
by descending ABS_V_CRAMER;
run;

* Macro variables kept for the models;
%let var_model0=
		avoir_liq2
		anc_cli_bqe2
		mtn_cptecourant2
		type_compte2
		topAssurVIE2
		topAssuIARD2
		top_Gar_Cnp2
		topFacilite2
		sit_familiale2
		cred_deb
		age2
		CSP2
;



/****************************************************/
/****************************************************/
/****************************************************/
/****************************************************/
/****************************************************/
/****************************************************/
/* PART 5: MODELS                                   */ 
/****************************************************/

/****************************************************/
/* 		5.1: SPLIT INTO TRAIN AND TEST SETS         */
/****************************************************/

* 01 - Train set;
proc sort data = Scoring.tablegroup;
by top_def_12m_90j;
run;

proc surveyselect data = Scoring.tablegroup method = srs seed = 1234 samprate = 70 out = Scoring.table_train;
				  strata top_def_12m_90j; 
				  title "Data splitting";
run;

* 02 - Test set;
proc sql;
create table Scoring.table_test as select *
								   from Scoring.tablegroup
								   where (matricule not in (select matricule
								   							from Scoring.table_train));
quit; 

/* 03 - Test balancedness */
proc freq data=Scoring.table_train ;
tables top_def_12m_90j;
run;

proc freq data=Scoring.table_test ;
tables top_def_12m_90j;
run;

proc freq data=Scoring.table_train ;
tables (&var_model0) * top_def_12m_90j;
run;

proc freq data=Scoring.table_test ;
tables (&var_model0) * top_def_12m_90j;
run;

/****************************************************/
/* 		5.2: MODELS                                 */
/****************************************************/

/****************************************************/
/* 			5.2.1: FIRST MODEL: ALL THE VARIABLES   */
/****************************************************/

* Macro to define the variables in the model; 
%let var_model0=
		cred_deb /* (ref="1. inf 01. inf 0") */
		avoir_liq2 /* (ref="2. autres avoir liq") */
		age2 /* (ref="1. inf 63") */
		anc_cli_bqe2 /* (ref="1. inf 22") */
		mtn_cptecourant2 /* (ref="1. inf -0.09") */
		type_compte2 /* (ref="2. Compte joint et individuel") */
		topAssurVIE2 /* (ref="2. sans") */
		topAssuIARD2 /* (ref="2. sans") */
		top_Gar_Cnp2 /* (ref="2. sans") */
		topFacilite2 /* (ref="2. sans") */
		sit_familiale2 /* (ref="1. Celibataire seul divorce") */
		CSP2 /* (ref="1. Ouvriers agriculteurs") */
;

* Contingency table;
proc freq data=Scoring.table_train ;
tables (&var_model0) * top_def_12m_90j;
run;

*Model with all the variables on the train;
proc logistic data = Scoring.table_train outest=GR__coeff;
			  class cred_deb  (ref="1. inf 01. inf 0") 
					avoir_liq2  (ref="2. autres avoir liq") 
		
					age2  (ref="1. inf 63") 
					anc_cli_bqe2  (ref="1. inf 22") 
					mtn_cptecourant2  (ref="1. inf -0.09") 
		
					type_compte2  (ref="2. Compte joint et individuel")
					topAssurVIE2  (ref="2. sans") 
					topAssuIARD2  (ref="2. sans") 
					top_Gar_Cnp2  (ref="2. sans") 
					topFacilite2  (ref="2. sans") 
					sit_familiale2 (ref="1. Celibataire seul divorce")
					CSP2  (ref="1. Ouvriers agriculteurs") ;
							
			  model top_def_12m_90j (Event = "0") = cred_deb avoir_liq2 
			  age2 anc_cli_bqe2 mtn_cptecourant2 type_compte2 topAssurVIE2 
			  topAssuIARD2 top_Gar_Cnp2 topFacilite2 sit_familiale2
			  CSP2 / 
			  link= logit outroc = roc1;
run;

/****************************************************/
/* 			5.2.2: MODALITIES MODIFICATION          */
/****************************************************/

* Grouping the modalities; 
data Scoring.tablegroup; 
set Scoring.tablegroup;
	
	* cred_deb2;
	if cred_deb="2. sup 02. sup 0" then cred_deb2="1. cred deb sup 0";
	else cred_deb2="2. autres";
	
	* age3;
	if age2="3. sup 83" then age3="1. sup 83";
	else age3="2. inf 83";
	
	* CSP3;
	if CSP2="4. Retraites" then CSP3 = "1. Retraites";
	else CSP3 = "2. Autres";
	
run;

* 01 - Train set;
proc sort data = Scoring.tablegroup;
by top_def_12m_90j;
run;

proc surveyselect data = Scoring.tablegroup method = srs seed = 1234 samprate = 70 out = Scoring.table_train;
				  strata top_def_12m_90j; /* découpage stratifié par la variable cible le défaut */
				  title "Data splitting";
run;

* 02 - Test set;
proc sql;
create table Scoring.table_test as select *
								   from Scoring.tablegroup
								   where (matricule not in (select matricule
								   							from Scoring.table_train));
quit; 

* Macro to define the variables in the model; 
%let var_model=
		cred_deb2 /* (ref="2. autres") */
		avoir_liq2 /* (ref="2. autres avoir liq") */
		
		age3 /* (ref="2. inf 83") */
		anc_cli_bqe2 /* (ref="1. inf 22") */
		mtn_cptecourant2 /* (ref="1. inf -0.09") */
		
		type_compte2 /* (ref="2. Compte joint et individuel") */
		topAssurVIE2 /* (ref="2. sans") */
		topAssuIARD2 /* (ref="2. sans") */
		top_Gar_Cnp2 /* (ref="2. sans") */
		topFacilite2 /* (ref="2. sans") */
		sit_familiale2 /* (ref="1. Celibataire seul divorce") */
		CSP3 /* (ref="2. Autres") */
;

*Dependence of the variables crossed between them;
* Isolate output;
ods output chisq=sortie2_cross;

* Variables are crossed with the variable of interest;
proc freq data=Scoring.tablegroup;
tables (&var_model) * (&var_model) /chisq;
run;

* We keep only the V de Cramer statistics;
data cross_cramer2;
set sortie2_cross;
where statistic = "V de Cramer";
ABS_V_CRAMER = ABS(ROUND(Value, 0.00001));
Variable = scan(table,2," ");
keep Variable Value ABS_V_CRAMER;
run;

* Table in descing order of the V de Cramer;
proc sort data=cross_cramer2;
by descending ABS_V_CRAMER;
run;


*Dependence of the variables and the target variable;
* Isolate output;
ods output chisq=sortie3_cross;

* Variables are crossed with the variable of interest;
proc freq data=Scoring.tablegroup;
tables (&var_model) * top_def_12m_90j /chisq;
run;

* We keep only the V de Cramer statistics;
data cross_cramer3;
set sortie3_cross;
where statistic = "V de Cramer";
ABS_V_CRAMER = ABS(ROUND(Value, 0.00001));
Variable = scan(table,2," ");
keep Variable Value ABS_V_CRAMER;
run;

* Table in descing order of the V de Cramer;
proc sort data=cross_cramer3;
by descending ABS_V_CRAMER;
run;

/****************************************************/
/* 			5.2.3: SECOND MODEL:  					*/
/*				   ALL THE NEW VARIAABLEs           */
/****************************************************/

*Model with all the new variables on the train;
proc logistic data = Scoring.table_train outest=GR__coeff;
			  class cred_deb2  (ref="2. autres") 
					avoir_liq2  (ref="2. autres avoir liq") 
					age3  (ref="2. inf 83") 
					anc_cli_bqe2  (ref="1. inf 22") 
					mtn_cptecourant2  (ref="1. inf -0.09") 
					type_compte2  (ref="2. Compte joint et individuel")
					topAssurVIE2  (ref="2. sans") 
					topAssuIARD2  (ref="2. sans") 
					top_Gar_Cnp2  (ref="2. sans") 
					topFacilite2  (ref="2. sans") 
					sit_familiale2 (ref="1. Celibataire seul divorce")
					CSP3  (ref="2. Autres") ;
							
			  model top_def_12m_90j (Event = "0") = cred_deb2 avoir_liq2 
			  age3 anc_cli_bqe2 mtn_cptecourant2 type_compte2 topAssurVIE2 
			  topAssuIARD2 top_Gar_Cnp2 topFacilite2 sit_familiale2
			  CSP3 / 
			  link= logit outroc = roc1;
run;

/****************************************************/
/* 			5.2.4: THIRD MODEL: STEPWISE MODEL      */
/****************************************************/

*Stepwise model;
proc logistic data = Scoring.table_train outest=GR__coeff;
			  class cred_deb2  (ref="2. autres") 
					avoir_liq2  (ref="2. autres avoir liq") 
		
					age3  (ref="2. inf 83") 
					anc_cli_bqe2  (ref="1. inf 22") 
					mtn_cptecourant2  (ref="1. inf -0.09") 
		
					type_compte2  (ref="2. Compte joint et individuel")
					topAssurVIE2  (ref="2. sans") 
					topAssuIARD2  (ref="2. sans") 
					top_Gar_Cnp2  (ref="2. sans") 
					topFacilite2  (ref="2. sans") 
					sit_familiale2 (ref="1. Celibataire seul divorce")
					CSP3  (ref="2. Autres") ;
							
			  model top_def_12m_90j (Event = "0") = cred_deb2 avoir_liq2 
			  age3 anc_cli_bqe2 mtn_cptecourant2 type_compte2 topAssurVIE2 
			  topAssuIARD2 top_Gar_Cnp2 topFacilite2 sit_familiale2
			  CSP3 / 
			  link= logit selection = stepwise outroc = roc1;
run;

/****************************************************/
/* 			5.2.5: FOURTH MODEL: BEST MODEL         */
/****************************************************/

*Model with some of the variables on the train;
proc logistic data = Scoring.table_train outest=GR__coeff;
			  class cred_deb2  (ref="2. autres") 
					avoir_liq2  (ref="2. autres avoir liq") 
		
					age3  (ref="2. inf 83") 
					anc_cli_bqe2  (ref="1. inf 22") 
					mtn_cptecourant2  (ref="1. inf -0.09") 
		
					type_compte2  (ref="2. Compte joint et individuel")
					topAssuIARD2  (ref="2. sans") 
					top_Gar_Cnp2  (ref="2. sans") 
					topFacilite2  (ref="2. sans") 
					CSP3  (ref="2. Autres") ;
							
			  model top_def_12m_90j (Event = "0") = cred_deb2 avoir_liq2 
			  age3 anc_cli_bqe2 mtn_cptecourant2 type_compte2
			  topAssuIARD2 top_Gar_Cnp2 topFacilite2
			  CSP3 / 
			  link= logit outroc = roc1;
run;

/****************************************************/
/* 			5.2.6: EVALUATION ON THE TEST           */
/****************************************************/

* Drop default from test;
data Scoring.table_test2;
set Scoring.table_test;
drop top_def_12m_90j;
run;

* Append to predicted data set;
data Scoring.table_newpred;
set Scoring.table_train Scoring.table_test2;
run;

*Model;
proc logistic data = Scoring.table_newpred outest=GR__coeff;
			  class cred_deb2  (ref="2. autres") 
					avoir_liq2  (ref="2. autres avoir liq") 
					age3  (ref="2. inf 83") 
					anc_cli_bqe2  (ref="1. inf 22") 
					mtn_cptecourant2  (ref="1. inf -0.09") 
					type_compte2  (ref="2. Compte joint et individuel")
					topAssuIARD2  (ref="2. sans") 
					top_Gar_Cnp2  (ref="2. sans") 
					topFacilite2  (ref="2. sans") 
					CSP3  (ref="2. Autres") ;
							
			  model top_def_12m_90j (Event = "0") = cred_deb2 avoir_liq2 
			  age3 anc_cli_bqe2 mtn_cptecourant2 type_compte2
			  topAssuIARD2 top_Gar_Cnp2 topFacilite2
			  CSP3 / 
			  link= logit outroc = roc2;
			  score data= Scoring.table_test2 out=Scoring.estimates2;
run;

* Merge predictions and true value;
data Scoring.estimates2;
Merge Scoring.table_test Scoring.estimates2;
run;

* Accuracy;
data Scoring.estimates2;
set Scoring.estimates2;
if top_def_12m_90j = I_top_def_12m_90j then T=1; else T=0;
run;

proc univariate data=Scoring.estimates2;
    var T;
run;

* Confusion matrix;
proc freq data=Scoring.estimates2;
    tables  top_def_12m_90j*I_top_def_12m_90j;
run;

* Create ROC curve;
proc logistic data=Scoring.estimates2;
   model top_def_12m_90j(event='0') = P_0 / nofit;
   roc pred=P_0;
   ods select ROCcurve;
run;


/****************************************************/
/* 			5.2.7: MODEL ON MORAL CUSTOMERS         */
/****************************************************/

* Keeping only physical persons being individuals;
data Scoring.table_pro;
set Scoring.table;
where statut_juridique="Personne morale";
run;

* New dataset;
data Scoring.table_pro;
set Scoring.table_pro;
keep &var_quali_kept &var_quanti_kept top_def_12m_90j matricule;
run;

* Group modalities;
data Scoring.table_pro; 
set Scoring.table_pro;

	* CSP;
	if CSP in ("Agriculteurs","Artisans, commercants, chef entreprise","Autre","Ouvriers") then CSP2="1. Ouvriers agriculteurs"; 
	else if CSP in ("Sans activite","Employes","Non renseigne") then CSP2= "3. Autres";
	else if CSP in ("Cadre, profession superieures","Professions intermediaires") then CSP2= "2. Cadres";
	else CSP2="4. Retraites";
	
	* Family;
	if sit_familiale in ("Célibataire","Divorcé(e)","Séparé(e)") then sit_familiale2="1. Celibataire seul divorce"; 
	else if sit_familiale in ("Non renseigné","Veuf(ve)","Pacs") then sit_familiale2="2. Autres";
	else sit_familiale2="3. Marie";
	
	* Insurances;
	if topAssurVIE=0 then topAssurVIE2="2. sans"; else topAssurVIE2="1. avec";
	if topAssuIARD=0 then topAssuIARD2="2. sans"; else topAssuIARD2="1. avec";
	if top_Gar_Cnp=0 then top_Gar_Cnp2="2. sans"; else top_Gar_Cnp2="1. avec"; 
	if topFacilite=0 then topFacilite2="2. sans"; else topFacilite2="1. avec"; 
	
	* Bank account;
	if type_compte = "Compte individuel uniquement" then type_compte2="1. Compte individuel uniquement"; 
	else if type_compte ="Compte joint et individuel" then type_compte2="2. Compte joint et individuel";
	else type_compte2="3. Compte joint uniquement";
	
run;

* Create classes;
data Scoring.table_pro;
set Scoring.table_pro;
	if age <= 63 then age2 = "1. inf 63"; 
	else if  age >63 and age <= 83 then age2 = "2. btw 63 and 83";
	else age2 = "3. sup 83";
	
	if anc_cli_bqe<=22 then anc_cli_bqe2= "1. inf 22"; else anc_cli_bqe2="2. sup 22";
	
	if nb_debit<=0 then nb_debit2= "1. inf 0"; else nb_debit2="2. sup 0";
	
	if nb_credit<=0 then nb_credit2= "1. inf 0"; else nb_credit2="2. sup 0";
	
	if sld_liqu_6m_mean<=72.389 then sld_liqu_6m_mean2= "1. inf 72.3"; else sld_liqu_6m_mean2="2. sup 72.3";
	
	if sld_avoirs_6m_mean<=107.673 then sld_avoirs_6m_mean2 ="1. inf 107.6"; 
	else sld_avoirs_6m_mean2 = "2. sup 107.6";
	
	if mtn_cptecourant<=-0.09 then mtn_cptecourant2 ="1. inf -0.09"; 
	else mtn_cptecourant2 = "2. sup -0.09";
	
run;

* Crossing variables;
data Scoring.table_pro; 
set Scoring.table_pro;
	cred_deb = (nb_credit2||nb_debit2);
	avoir_liq = (sld_avoirs_6m_mean2||sld_liqu_6m_mean2);
	age_csp = (CSP2||age2);
	cred_topfac = (nb_credit2||topFacilite2);
	deb_topfac = (nb_debit2||topFacilite2);
	age_anc =  (age2||anc_cli_bqe2);
	assu_vie_iard = (topAssurVIE2||topAssuIARD2);
	famil_compte = (type_compte2||sit_familiale2);
	liq_comptecour = (sld_liqu_6m_mean2||mtn_cptecourant2);
run;

* Grouping modalities; 
data Scoring.table_pro; 
set Scoring.table_pro;
	
	* cred_deb2;
	if cred_deb="2. sup 02. sup 0" then cred_deb2="1. cred deb sup 0";
	else cred_deb2="2. autres";
	
	* avoir_liq2;
	if avoir_liq="2. sup 107.62. sup 72.3" 
	then avoir_liq2="1. avoir sup 107 liq sup 72.3";
	else avoir_liq2 = '2. autres avoir liq';
	
	* age3;
	if age2="3. sup 83" then age3="1. sup 83";
	else age3="2. inf 83";
	
	* CSP3;
	if CSP2="4. Retraites" then CSP3 = "1. Retraites";
	else CSP3 = "2. Autres";
	
run;

/* 01 - Train set */

proc sort data = Scoring.table_pro;
by top_def_12m_90j;
run;


proc surveyselect data = Scoring.table_pro method = srs seed = 1234 samprate = 70 out = Scoring.table_train_pro;
				  strata top_def_12m_90j;
				  title "Data splitting";
run;

/* 02 - Test set */
proc sql;
create table Scoring.table_test_pro as select *
								   from Scoring.table_pro
								   where (matricule not in (select matricule
								   							from Scoring.table_train));
quit; 

* Contingency table;
proc freq data=Scoring.table_train_pro ;
tables (&var_model) * top_def_12m_90j;
run;

*Model with some of the variables on the train;
proc logistic data = Scoring.table_train_pro outest=GR__coeff;
			  class cred_deb2  (ref="2. autres") 
					avoir_liq2  (ref="2. autres avoir liq") 
					age3  (ref="2. inf 83") 
					anc_cli_bqe2  (ref="1. inf 22") 
					mtn_cptecourant2  (ref="1. inf -0.09") 
					topAssuIARD2  (ref="2. sans") 
					top_Gar_Cnp2  (ref="1. avec") 
					CSP3  (ref="1. Retraites") ;
							
			  model top_def_12m_90j (Event = "0") = cred_deb2 avoir_liq2 
			  age3 anc_cli_bqe2 mtn_cptecourant2 
			  topAssuIARD2 top_Gar_Cnp2 
			  CSP3 / 
			  link= logit outroc = roc1;
run;


/****************************************************/
/****************************************************/
/****************************************************/
/****************************************************/
/****************************************************/
/****************************************************/
/* PART 6: SCORE                                    */ 
/****************************************************/

/****************************************************/
/* 		6.1: WEIGHTS                                */                           */
/****************************************************/

* Computing the weights;
PROC TRANSPOSE DATA=GR__coeff OUT=data_beta;
RUN;

data data_beta;
    set data_beta;
    if _NAME_ in ("Intercept","_LNLIKE_") then delete;
run;

* Get the sum;
proc univariate data=work.data_beta;
    var top_def_12m_90j;
run;

* Data with the weights;
data data_beta;
set data_beta;
	weights = top_def_12m_90j/4.80461144;
run;

* Adding the weights in the train set;
data train_predict ;
set scoring.table_train;

	if cred_deb2 = "1. cred deb sup 0" then weight_cred_deb = 0.0820485625; 
	else weight_cred_deb = 0 ;
	
	if avoir_liq2 ="1. avoir sup 107 liq sup 72.3" then weight_avoir_liq2 = 0.1425561853 ; 
	else weight_avoir_liq2 = 0 ;
	
	if age3 ="1. sup 83" then weight_age3 = 0.0911739745 ; 
	else weight_age3 = 0 ;
	
	if anc_cli_bqe2 = "1. sup 83" then weight_anc_cli_bqe2 = 0.0420898486; 
	else weight_anc_cli_bqe2 = 0 ;
	
	if mtn_cptecourant2 = "2. sup -0.09" then weight_mtn_cptecourant2 = 0.2468173218; 
	else weight_mtn_cptecourant2 = 0 ;
	
	if type_compte2 = "1. Compte individuel uniquement" then weight_type_compte2 = 0.0598045025 ; 
	else if type_compte2 = "3. Compte joint uniquement" then weight_type_compte2 = 0.0775361207;
	else weight_type_compte2 = 0 ;
	
	if topAssuIARD2 = "1. avec" then weight_topAssuIARD2 = 0.0316415921; 
	else weight_topAssuIARD2 = 0 ;
	
	if top_Gar_Cnp2 = "1. avec"  then weight_top_Gar_Cnp2 = 0.0690096082; 
	else weight_top_Gar_Cnp2 = 0 ;
	
	if topFacilite2 = "1. avec" then weight_topFacilite2 = 0.1053469106; 
	else weight_topFacilite2 = 0 ;
	
	if CSP3 = "1. Retraites" then weight_CSP3 = 0.051975374 ; 
	else weight_CSP3 = 0 ;
run;

* Adding the weights in the test set ;
data test_predict ;
set scoring.table_test;

	if cred_deb2 = "1. cred deb sup 0" then weight_cred_deb = 0.0820485625; 
	else weight_cred_deb = 0 ;
	
	if avoir_liq2 ="1. avoir sup 107 liq sup 72.3" then weight_avoir_liq2 = 0.1425561853 ; 
	else weight_avoir_liq2 = 0 ;
	
	if age3 ="1. sup 83" then weight_age3 = 0.0911739745 ; 
	else weight_age3 = 0 ;
	
	if anc_cli_bqe2 = "1. sup 83" then weight_anc_cli_bqe2 = 0.0420898486; 
	else weight_anc_cli_bqe2 = 0 ;
	
	if mtn_cptecourant2 = "2. sup -0.09" then weight_mtn_cptecourant2 = 0.2468173218; 
	else weight_mtn_cptecourant2 = 0 ;
	
	if type_compte2 = "1. Compte individuel uniquement" then weight_type_compte2 = 0.0598045025 ; 
	else if type_compte2 = "3. Compte joint uniquement" then weight_type_compte2 = 0.0775361207;
	else weight_type_compte2 = 0 ;
	
	if topAssuIARD2 = "1. avec" then weight_topAssuIARD2 = 0.0316415921; 
	else weight_topAssuIARD2 = 0 ;
	
	if top_Gar_Cnp2 = "1. avec"  then weight_top_Gar_Cnp2 = 0.0690096082; 
	else weight_top_Gar_Cnp2 = 0 ;
	
	if topFacilite2 = "1. avec" then weight_topFacilite2 = 0.1053469106; 
	else weight_topFacilite2 = 0 ;
	
	if CSP3 = "1. Retraites" then weight_CSP3 = 0.051975374 ; 
	else weight_CSP3 = 0 ;
run;

* Adding the weights in the full data set ;
data data_predict ;
set scoring.tablegroup;

	if cred_deb2 = "1. cred deb sup 0" then weight_cred_deb = 0.0820485625; 
	else weight_cred_deb = 0 ;
	
	if avoir_liq2 ="1. avoir sup 107 liq sup 72.3" then weight_avoir_liq2 = 0.1425561853 ; 
	else weight_avoir_liq2 = 0 ;
	
	if age3 ="1. sup 83" then weight_age3 = 0.0911739745 ; 
	else weight_age3 = 0 ;
	
	if anc_cli_bqe2 = "1. sup 83" then weight_anc_cli_bqe2 = 0.0420898486; 
	else weight_anc_cli_bqe2 = 0 ;
	
	if mtn_cptecourant2 = "2. sup -0.09" then weight_mtn_cptecourant2 = 0.2468173218; 
	else weight_mtn_cptecourant2 = 0 ;
	
	if type_compte2 = "1. Compte individuel uniquement" then weight_type_compte2 = 0.0598045025 ; 
	else if type_compte2 = "3. Compte joint uniquement" then weight_type_compte2 = 0.0775361207;
	else weight_type_compte2 = 0 ;
	
	if topAssuIARD2 = "1. avec" then weight_topAssuIARD2 = 0.0316415921; 
	else weight_topAssuIARD2 = 0 ;
	
	if top_Gar_Cnp2 = "1. avec"  then weight_top_Gar_Cnp2 = 0.0690096082; 
	else weight_top_Gar_Cnp2 = 0 ;
	
	if topFacilite2 = "1. avec" then weight_topFacilite2 = 0.1053469106; 
	else weight_topFacilite2 = 0 ;
	
	if CSP3 = "1. Retraites" then weight_CSP3 = 0.051975374 ; 
	else weight_CSP3 = 0 ;
run;


/****************************************************/
/* 		6.2: SCORE                                  */                      
/****************************************************/

* Get the predictions on train;
data score_train ;
set train_predict;
	prediction = sum(weight_cred_deb, weight_avoir_liq2,weight_age3,weight_anc_cli_bqe2, 
					weight_mtn_cptecourant2,weight_type_compte2,weight_topAssuIARD2, weight_top_Gar_Cnp2,
					weight_topFacilite2,weight_CSP3)*1000;
run;

* Get the predictions on test;
data score_test ;
set test_predict;
	prediction = sum(weight_cred_deb, weight_avoir_liq2,weight_age3,weight_anc_cli_bqe2, 
					weight_mtn_cptecourant2,weight_type_compte2,weight_topAssuIARD2, weight_top_Gar_Cnp2,
					weight_topFacilite2,weight_CSP3)*1000;
run;

* Get the predictions on the whole data;
data score_data ;
set data_predict;
	prediction = sum(weight_cred_deb, weight_avoir_liq2,weight_age3,weight_anc_cli_bqe2, 
					weight_mtn_cptecourant2,weight_type_compte2,weight_topAssuIARD2, weight_top_Gar_Cnp2,
					weight_topFacilite2,weight_CSP3)*1000;
run;

* Plot of the distribution of the score on the full data set;

* Change values;
data score_data;
set score_data;
if top_def_12m_90j = 1 then default = 'default_1';
else default = 'default_0';
run;

* Plot; 
proc univariate data = score_data;
	class default;
	var prediction;
	histogram prediction / normal overlay;
run;

* Variable cutting depending on the default;
proc sql;
create table note_defaut as 
select count(matricule) as Nb_client, 
		   mean(prediction) as mean_note
from score_train
where top_def_12m_90j = 1;
quit; 

proc sql;
create table note_sain as 
	select count(matricule) as Nb_client, 
		   mean(prediction) as mean_note
from score_train
where top_def_12m_90j = 0;
quit; 

%macro decoup_2(variable, donnee); 
	%decody2(data=&donnee,
             critere=top_def_12m_90j,
             var=&variable,
             freq_min=0.2,
             autodec=1,
             typecrit=bin,Title='decoup variable');
%mend ;

%decoup_2(prediction, score_data);












