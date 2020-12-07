 %let P_DATABASE=POTCSAS;

  libname cy "/sas_share_02/models/SummerCraft/CY15";
 /**********************************************************************************************/
 /*******************Read in last year model score file*****************************************/

 libname ly  "/sas_share_02/locker2/models/SummerCraft/CY14";

 data cat_scr_ly    ;
       %let _EFIERR_ = 0; /* set the ERROR detection macro variable */
      infile '/sas_share_02/locker2/models/SummerCraft/CY14/sas_cat_model_score_20140105.txt' delimiter = '|'
                MISSOVER DSD lrecl=32767 firstobs=2 ;
          informat primary_acct_key $30. ;
          informat model_id $8. ;
          informat f_score best32. ;
          informat f_rank best32. ;
          informat score_date mmddyy10. ;
          format primary_acct_key $30. ;
          format model_id $8. ;
          format f_score best12. ;
          format f_rank best12. ;
          format score_date mmddyy10. ;
       input
                   primary_acct_key $
                   model_id $
                   f_score
                   f_rank
                   score_date
       ;
       if _ERROR_ then call symputx('_EFIERR_',1);  /* set ERROR detection macro variable */
       run;
 /*NOTE: The data set WORK.CAT_SCR_LY has 10198623 observations and 5 variables.*/

  proc sort data=cat_scr_ly;by primary_acct_key;run;
  proc sort data=ly.bus_act;by primary_acct_key;run;

 data cat_scr_ly_bu;
 merge cat_scr_ly(in=a) ly.bus_act(in=b drop=model_id);
 by primary_acct_key;
 if a and b;
 run;
 /*NOTE: The data set WORK.CAT_SCR_LY_BU has 10198623 observations and 7 variables. */

 data cat_scr_ly_bu;
 set cat_scr_ly_bu;
 if active=1 then flag='ACT';
 else if active=0 then flag='INA';
 else flag='';
 run;

   proc means data=cat_scr_ly_bu;
    var f_score;
    class bus_unit flag f_rank;
    output out=work.means_ly_rank(where=(_TYPE_=7) rename=(_FREQ_=N_LY))
     mean=Avgscr_LY;
         run;

     data cy.means_ly_rank(drop=_TYPE_ N_LY);
     set means_ly_rank;
     run;

 /**********************************************************************************************/
  /*******************Read in current year model score file*****************************************/


 data cat_scr_cy;
 set cy.score_all;
 if 1<= f_rank <= 20 then flag='AFF';
 else if 21<= f_rank <= 30 then flag='INA';
 else if 31<= f_rank <= 50 then flag='ACT';
 else flag='';
 run;

 /*NOTE: Table WORK.CAT_SCR_CY created, with 10085681 rows and 6 columns.*/

  proc sql;
  create table cat_scr_cy_bu as
  select a.*,
         b.business_unit as bus_unit,
         b.active
   from cat_scr_cy a,cy.bus_act b
   where a.CONTACT_ACROSS_ADDR_KEY=b.contact_across_addr_key;
    quit;
/*NOTE: Table WORK.CAT_SCR_CY_BU created, with 9052987 rows and 8 columns.*/

   proc means data=cat_scr_ly_bu;
          var f_score;
          class bus_unit flag;
          output out=work.means_ly(drop=_TYPE_ rename=(_FREQ_=N_LY))
             mean=Avgscr_LY;
       run;

  data means_ly;set means_ly;where (bus_unit in (20,60,70))  and (flag in ('ACT','INA')) or (bus_unit in (20,60,70) and flag eq '');run;


   proc means data=cat_scr_cy_bu;
             var f_score;
             class bus_unit flag;
             output out=work.means_cy(drop=_TYPE_ rename=(_FREQ_=N_CY))
                mean=Avgscr_CY;
          run;

  data means_cy;set means_cy;where (bus_unit in (20,60,70))  and (flag in ('ACT','INA','AFF')) or (bus_unit in (20,60,70) and flag eq '');run;


  proc sort data=means_ly;by bus_unit flag;run;
  proc sort data=means_cy;by bus_unit flag;run;

  data means;
  merge means_ly(in=a) means_cy(in=b);
  by bus_unit flag;
  if a or b;
  ratio=Avgscr_LY/Avgscr_CY;
  run;

 /********************************************************************************
 **********Macro to calculate ratio for Affinity Buyers**************************/

 %macro aff_calc(bu=);

 proc sql noprint;
 select N_CY * ratio format 12.4 into: total_ACT
 from means
 where bus_unit=&bu and flag='ACT';
 quit;

 %put &total_ACT.;

 proc sql noprint;
  select N_CY * ratio format 12.4 into: total_INA
  from means
  where bus_unit=&bu and flag='INA';
  quit;

  %put &total_INA.;

   proc sql noprint;
    select N_CY * ratio format 12.4 into: total
    from means
    where bus_unit=&bu and flag='';
    quit;

    %put &total.;


   proc sql noprint;
       select N_CY into: N_AFF
       from means
       where bus_unit=&bu and flag='AFF';
       quit;

       %put &N_AFF.;


   data means;
    set means;
   if bus_unit=&bu and ratio=. then ratio=abs((&total.-(&total_ACT.+&total_INA.))/&N_AFF.);
   run;

 %mend aff_calc;

 %aff_calc(bu=20);
 %aff_calc(bu=60);
 %aff_calc(bu=70);


  proc sort data=cat_scr_cy_bu;by bus_unit flag;run;

  data cat_scr_cy_bu_mod;
  merge cat_scr_cy_bu(in=a) means(in=b keep=bus_unit flag ratio);
  by bus_unit flag;
  if a;
  f_score_mod=f_score * ratio;
  run;


  /**Compare means of final_score_mod with last year; they should be comparable**/
  proc means data=cat_scr_cy_bu_mod;
               var f_score_mod;
               class bus_unit flag ratio;
               output out=work.means_cy_mod(where=(_TYPE_ in (4,7)) rename=(_FREQ_=N_CY))
                  mean=Avgscr_CY_mod ratio;
            run;

/**Check avg scores- ACT score should be highest, then INA followed by AFF**/
/*************if not run the following steps*******************/

%macro mod(bu=,output=);

  proc sql noprint;
    select Avgscr_CY_mod, ratio format 12.10 into: ACT_scr, :ACT_ratio
    from means_cy_mod
    where bus_unit=&bu and flag='ACT';
    quit;
   %put &ACT_scr. &ACT_ratio.;

 proc sql noprint;
     select Avgscr_CY_mod, ratio format 12.10 into: INA_scr, :INA_ratio
     from means_cy_mod
     where bus_unit=&bu and flag='INA';
     quit;

  proc sql noprint;
       select Avgscr_CY_mod, ratio format 12.10 into: AFF_scr, :AFF_ratio
       from means_cy_mod
       where bus_unit=&bu and flag='AFF';
       quit;


   data &output;
   set means_cy_mod;
   if bus_unit=&bu;

   if flag='ACT' then do;
   ratio_new_ACT=&ACT_ratio.;
   end;

  else if flag='INA' then do;
  if &INA_scr. > &ACT_scr.  then ratio_new_INA=&ACT_ratio.;
  else ratio_new_INA=ratio;
   end;

  else if flag in ('AFF') then do;

   if &AFF_scr. > &INA_scr.  then ratio_new_AFF=&INA_ratio.;
   else ratio_new_AFF=ratio;
  end;

 ratio_new=max(ratio_new_ACT, ratio_new_INA,  ratio_new_AFF);
  run;

 data &output(keep=bus_unit flag ratio Avgscr_CY_mod ratio_new);
 set &output;
 run;


 %mend mod;


 %mod(bu=20,output=means_new_bu20);
 %mod(bu=60,output=means_new_bu60);
 %mod(bu=70,output=means_new_bu70);

 data means_adj;
 set means_new_bu20 means_new_bu60  means_new_bu70;
 run;

 proc sort data=cat_scr_cy_bu;by bus_unit flag;run;
 proc sort data=means_adj;by bus_unit flag;run;

   data cat_scr_cy_bu_adj;
   merge cat_scr_cy_bu(in=a) means_adj(in=b keep=bus_unit flag ratio_new);
   by bus_unit flag;
   if a;
   f_score_mod=f_score * ratio_new;
   run;


 /**Compare means of final_score_mod with last year; they should be comparable**/
   proc means data=cat_scr_cy_bu_adj;
                var f_score_mod;
                class bus_unit flag;
                output out=work.means_cy_adj(drop=_TYPE_ rename=(_FREQ_=N_CY))
                   mean=Avgscr_CY_mod ;
             run;

 proc sql;
 create table cat_scr_cy_final as
 select CONTACT_ACROSS_ADDR_KEY,
        ACCT_KEY,
        MODEL_ID,
        F_SCORE_MOD as FINAL_SCORE format 12.4,
        F_RANK as FINAL_RANK,
        SCORE_DATE
 from cat_scr_cy_bu_adj; /**check table name**/
 quit;

 /*check freq to make sure rank didn't change
 proc freq data=cat_scr_cy_final;tables final_rank;run;
 proc freq data=cat_scr_cy;tables f_rank;run;
 */

*****************Catalog model score load to POTCSAS**********************;
******Hardcode the date in the table name if needed******;

*%let today=%sysfunc(today(),YYMMDDn8.);

proc sql threads noprint;
      %connect_db(&P_DATABASE., bulkunload=y, libname=y, dbmstemp=y);

      exec
      (
        create table catalog_model_score_20150126
        (
                        CONTACT_ACROSS_ADDR_KEY bigint,
                        ACCT_KEY varchar(20), /*new field added*/
                        MODEL_ID varchar(25),
                        FINAL_SCORE  numeric(12,4),/*new decimal precision*/
                        FINAL_RANK byteint,
                        SCORE_DATE date

        ) distribute on (CONTACT_ACROSS_ADDR_KEY)
      ) by &P_DATABASE.;

      insert into &P_DATABASE..catalog_model_score_20150126(bulkload=yes
                   dbsastype=(CONTACT_ACROSS_ADDR_KEY='char(20)'))
      select *
      from work.cat_scr_cy_final ;/*include new table name*/
quit;
run;
