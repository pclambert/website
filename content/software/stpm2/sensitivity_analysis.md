+++
date = "2017-08-06"
title = "Sensitivity analysis to number of knots (proporitonal hazards)"
summary = "stpm2"
tags = ["stpm2","survival","software","Stata","proportional hazards"]
external_link = "" 
math = true
[header]
image = ""
caption = ""
+++

# Sensitivity Analysis

We first load the example breast cancer data data using `webuse` and then use `stset` to declare the survival time and event indicator.

```stata
. webuse brcancer, clear
(German breast cancer data)

. stset rectime, f(censrec==1) scale(365.24)

     failure event:  censrec == 1
obs. time interval:  (0, rectime]
 exit on or before:  failure
    t for analysis:  time/365.24

------------------------------------------------------------------------------
        686  total observations
          0  exclusions
------------------------------------------------------------------------------
        686  observations remaining, representing
        299  failures in single-record/single-failure data
  2,112.036  total analysis time at risk and under observation
                                                at risk from t =         0
                                     earliest observed entry t =         0
                                          last observed exit t =  7.280145

```

```stata
. forvalues i = 1/6 {
  2.         quietly stpm2 hormon, df(`i') scale(hazard)
  3.         estimates store df`i'
  4. }

. estimates table df*, keep(hormon) b(%5.4f) se(%5.4f)

--------------------------------------------------------------------------
    Variable |   df1       df2       df3       df4       df5       df6    
-------------+------------------------------------------------------------
      hormon | -0.3932   -0.3590   -0.3614   -0.3641   -0.3645   -0.3647  
             |  0.1248    0.1248    0.1249    0.1249    0.1249    0.1249  
--------------------------------------------------------------------------
                                                              legend: b/se

```

