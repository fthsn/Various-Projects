/*%put    %sysfunc(getoption(work));*/
  libname yan "/sastmp1/SAS_work9E3F0000071B_x108p-sas01";


proc template;
      edit Base.Corr.StackedMatrix;
         column (RowName RowLabel) (Matrix) * (Matrix2);
         edit matrix;
            cellstyle _val_  = -1.00 as {background=CXEEEEEE},
                      _val_ <= -0.65 as {background=green},
                      _val_ <= -0.50 as {background=cyan},
                      _val_ <=  0.50 as {background=CXEEEEEE},
                      _val_ <=  0.65 as {background=cyan},
                      _val_ <   1.00 as {background=green},
                      _val_  =  1.00 as {background=CXEEEEEE};
            end;
         end;
      run;





    ods listing close;
   proc corr data=yan.work_sales  noprob;
      ods select PearsonCorr;
      var
 
 sd350m60b  sd350m48b    sd700m60    sd700m48     

	    
;

   run;
   ods listing; ods html close;
 

   proc template;
      delete Base.Corr.StackedMatrix;
   run;
