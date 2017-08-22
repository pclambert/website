+++
date = "2017-08-06"
title = "stcrprep - non parametric cause-specific CIFs"
summary = "stpm2"
tags = ["survival","software","Stata","competing risks"]
external_link = "" 
math = true
[header]
image = ""
caption = ""
+++

I will use the same data set I use in the _Stata Journal_ [article](http://www.stata-journal.com/article.html?article=st0471). 
This comprises of 1977 patients from the European Blood and Marrow Transplantation (EBMT) registry who received an allogeneic bone
marrow transplantation. Time is measured in days from transplantation to either relapse
or death. There is only one covariate of interest, the EBMT risk score, which has been
categorized into 3 groups (low, medium and high risk). The data is available as part of
the mstate R package (de Wreede et al. 2011).

First I load the data,

```stata
. //use http://pclambert.net/ebmt1_stata.dta
. use "C:\website\static\data\ebmt1_stata", clear
(Written by R.              )

. stset time, failure(status==1,2) scale(365.25) id(patid)

                id:  patid
     failure event:  status == 1 2
obs. time interval:  (time[_n-1], time]
 exit on or before:  failure
    t for analysis:  time/365.25

------------------------------------------------------------------------------
      1,977  total observations
          0  exclusions
------------------------------------------------------------------------------
      1,977  observations remaining, representing
      1,977  subjects
      1,141  failures in single-failure-per-subject data
  3,796.057  total analysis time at risk and under observation
                                                at risk from t =         0
                                     earliest observed entry t =         0
                                          last observed exit t =  8.454483

```

Explain `stset`

```stata
. list patid status _t0 _t _d if patid==17, noobs

  +---------------------------------------+
  | patid   status   _t0          _t   _d |
  |---------------------------------------|
  |    17     died     0   2.2888433    1 |
  +---------------------------------------+

```

Explain this

I will now use `stcrprep` to restructure the data. This will....

```stata
. stcrprep, events(status) keep(score) trans(1 2) byg(score)

```

```stata
. format tstart %6.5f                                                                     

. format tstop %6.5f

. format weight_c %6.5f

. list failcode patid status tstart tstop weight_c weight_t status if patid==17, ///
>          sepby(failcode) noobs 

  +------------------------------------------------------------------------------+
  | failcode   patid   status    tstart     tstop   weight_c   weight_t   status |
  |------------------------------------------------------------------------------|
  |  relapse      17     died   0.00000   2.28884    1.00000          1     died |
  |  relapse      17     died   2.28884   2.31622    0.99000          1     died |
  |  relapse      17     died   2.31622   2.32717    0.98497          1     died |
  |  relapse      17     died   2.32717   2.36003    0.97992          1     died |
  |  relapse      17     died   2.36003   2.55441    0.91392          1     died |
  |  relapse      17     died   2.55441   2.65845    0.89843          1     died |
  |  relapse      17     died   2.65845   2.89938    0.85142          1     died |
  |  relapse      17     died   2.89938   3.02806    0.80937          1     died |
  |  relapse      17     died   3.02806   3.18960    0.76176          1     died |
  |  relapse      17     died   3.18960   3.26626    0.74578          1     died |
  |  relapse      17     died   3.26626   3.62765    0.63847          1     died |
  |  relapse      17     died   3.62765   3.89870    0.59519          1     died |
  |  relapse      17     died   3.89870   3.97536    0.57881          1     died |
  |  relapse      17     died   3.97536   4.10951    0.55124          1     died |
  |  relapse      17     died   4.10951   4.39425    0.51163          1     died |
  |  relapse      17     died   4.39425   4.50103    0.47714          1     died |
  |  relapse      17     died   4.50103   4.69815    0.45968          1     died |
  |  relapse      17     died   4.69815   5.08419    0.37101          1     died |
  |  relapse      17     died   5.08419   5.22656    0.32235          1     died |
  |  relapse      17     died   5.22656   5.33607    0.30995          1     died |
  |  relapse      17     died   5.33607   5.97673    0.22772          1     died |
  |  relapse      17     died   5.97673   6.27515    0.20170          1     died |
  |------------------------------------------------------------------------------|
  |     died      17     died   0.00000   2.28884    1.00000          1     died |
  +------------------------------------------------------------------------------+

```

Explain the expanded data

```stata
. gen event = status == failcode

. stset tstop [iw=weight_c], failure(event) enter(tstart) noshow                                          // stset using weights

     failure event:  event != 0 & event < .
obs. time interval:  (0, tstop]
 enter on or after:  time tstart
 exit on or before:  failure
            weight:  [iweight=weight_c]

------------------------------------------------------------------------------
     70,262  total observations
          0  exclusions
------------------------------------------------------------------------------
     70,262  observations remaining, representing
      1,141  failures in single-record/single-failure data
 13,820.402  total analysis time at risk and under observation
                                                at risk from t =         0
                                     earliest observed entry t =         0
                                          last observed exit t =  8.454483

```

We now estimate the cause-specific CIF for relapse.

```stata
. sts graph if failcode==1, by(score) failure ///
>         ytitle("Probability of Relapse") ///
>         xtitle("Years since transplanation") ///
>         ylabel(0(0.1)0.5, angle(h) format(%3.1f)) ///
>         legend(order(1 "Low Risk" 2 "Medium Risk" 3 "High Risk") ///
>         cols(1) ring(0) pos(5)) ///
>         scheme(sj) name(cif_relapse, replace)

```


![](/statasvg/stcrprep_cif1.svg)

```stata
. sts test score if failcode==1


Log-rank test for equality of survivor functions

            |   Events         Events
score       |  observed       expected
------------+-------------------------
Low risk    |        79          99.64
Medium risk |       328         324.33
High risk   |        49          32.04
------------+-------------------------
Total       |       456         456.00

                  chi2(2) =      13.37
                  Pr>chi2 =     0.0012

. sts list, at(1 5) failure by(failcode score)    

              Beg.                      Failure       Std.
    Time     Total     Fail             Function     Error     [95% Conf. Int.]
-------------------------------------------------------------------------------
relapse Low risk 
       1   348.001       38              0.0959    0.0148     0.0707    0.1295
       5   94.7875       36              0.2268    0.0250     0.1821    0.2805
relapse Medium risk 
       1   1125.93      225              0.1636    0.0100     0.1451    0.1843
       5   268.081      100              0.2594    0.0131     0.2347    0.2861
relapse High risk 
       1   116.387       39              0.2417    0.0338     0.1827    0.3156
       5         6       10              0.3306    0.0410     0.2574    0.4181
died Low risk 
       1   306.828       81              0.2032    0.0202     0.1669    0.2462
       5   94.9111       10              0.2368    0.0223     0.1964    0.2839
died Medium risk 
       1   915.771      441              0.3189    0.0126     0.2950    0.3442
       5   209.617       70              0.3829    0.0137     0.3566    0.4104
died High risk 
       1   84.7723       73              0.4494    0.0392     0.3764    0.5296
       5         6        7              0.5160    0.0452     0.4310    0.6071
-------------------------------------------------------------------------------
Note: Failure function is calculated over full data and evaluated at indicated
      times; it is not calculated from aggregates shown at left.

```

