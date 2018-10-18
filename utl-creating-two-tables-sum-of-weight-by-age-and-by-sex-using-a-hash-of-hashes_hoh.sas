Creating two tables sum of weight by age and by sex using a hash of hashes hoh

Solution by
Keintz, Mark
mkeintz@wharton.upenn.edu

github
https://tinyurl.com/y83oms9t
https://github.com/rogerjdeangelis/utl-creating-two-tables-sum-of-weight-by-age-and-by-sex-using-a-hash-of-hashes_hoh

This is a nice generic example that create multiple table with statistics by group.
Even if you are not a hash expert you can adapt this example.


INPUT
=====

/* sum weight by age and sex */

%let stat=weight;
%let vars=age sex;
%let nv=%sysfunc(countw(&vars));

 WORK.HAVE total obs=5     +                   RULES
                           | SUM WEIGHT BY AGE        SUM WEIGHT BY SEX
                           |
                           |          SUM_                    SUM_
   NAME    SEX AGE WEIGHT  | AGE    WEIGHT             SEX  WEIGHT
                           |
  Alfred    M   14   113   |  13    182  84+98          F    285 84+98+103
  Alice     F   13    84   |  14    319  113+103+103    M    216 103+113
  Barbara   F   13    98   |
  Carol     F   14   103   |
  Henry     M   14   103   |
                           +


EXAMPLE OUTPUT
--------------

 WORK.TAB_AGE total obs=2

          SUM_
  AGE    WEIGHT

   13      182
   14      319

 WORK.TAB_SEX total obs=2

          SUM_
  SEX    WEIGHT

   F       285
   M       216


PROCESS
=======

data _null_;
  set have end=end_of_have;

  length varname $32  sum_weight 8;
  if _n_=1 then do;
    declare hash stats;
    declare hash hoh ();
      hoh.definekey('i');
      hoh.definedata('varname','stats');
      hoh.definedone();
    /* Get the varname and Instantiate a STATS for each variable, */
    /* and add them as a dataitem in HOH                          */
    do i=1 to &nv;
      varname=scan("&vars",i);
      stats=_new_ hash(ordered:'a');
        stats.definekey(varname);
        stats.definedata(varname,'sum_weight');
        stats.definedone();
      hoh.add();
    end;
  end;

  /* Update each STATS object */
  do i=1 to &nv;
    hoh.find();
    rc=stats.find();
    if rc^=0 then sum_weight=weight;
    else sum_weight=sum_weight+weight;
    stats.replace();
  end;

  if end_of_have then do i=1 to &nv;
    hoh.find();
    stats.output(dataset:cats('tab_',varname));
  end;
run;

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;

%let stat=weight;
%let vars=age sex;
%let nv=%sysfunc(countw(&vars));

data have;
  set sashelp.class (keep=name sex age weight obs=5);
  weight=round(&stat);
run;


