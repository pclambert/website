+++
date = "2017-08-06"
title = "Sensitivity analysis to number of knots (proportional hazards)"
summary = "stpm2"
tags = ["stpm2","survival","software","Stata","proportional hazards"]
external_link = "" 
math = true
[header]
image = ""
caption = ""
+++

# Sensitivity Analysis

We first load the example Rotterdam breast cancer data (rott2b.dta)  and then use `stset` to declare the survival time (relapse free survival) and event indicator. Follow-up is restricted to 5 years using the `exit()' option.

```stata
. use http://pclambert.netlify.com/data/rott2b, clear
(Rotterdam breast cancer data (augmented with cause of death))

. stset rf, f(rfi==1) scale(12) exit(time 60)

     failure event:  rfi == 1
obs. time interval:  (0, rf]
 exit on or before:  time 60
    t for analysis:  time/12

------------------------------------------------------------------------------
      2,982  total observations
          0  exclusions
------------------------------------------------------------------------------
      2,982  observations remaining, representing
      1,181  failures in single-record/single-failure data
 11,130.825  total analysis time at risk and under observation
                                                at risk from t =         0
                                     earliest observed entry t =         0
                                          last observed exit t =         5

```

I will use different degrees of freedom for the baseline. The easiest way to do this is in a loop. The following code fits between 1 and 6 df, predicts the baseline hazard and survival functions and stores each model (using `estimates store`).  I use `quietly` to suppress the output. I also generate a new time variable (`temptime`) for the predictions, rather than use the default of `_t`.

```stata
. range temptime 0 5 200
(2,782 missing values generated)

. forvalues i = 1/6 {
  2.         quietly stpm2 hormon, df(`i') scale(hazard) 
  3.         predict h0_df`i', hazard timevar(temptime) per(1000) zeros
  4.         predict s0_df`i', survival timevar(temptime) zeros
  5. }

```
We can now compare the results from fitting the 6 different models. 

```stata
. estimates table df*, keep(hormon) b(%6.5f) se(%6.5f) stats(AIC BIC) stfmt(%6.2f)

--------------------------------------------------------------------------
    Variable |   df1       df2       df3       df4       df5       df6    
-------------+------------------------------------------------------------
      hormon | 0.23312   0.22044   0.22038   0.22023   0.22020   0.22007  
             | 0.08642   0.08643   0.08643   0.08643   0.08643   0.08643  
-------------+------------------------------------------------------------
         AIC | 6362.72   6210.98   6212.43   6213.72   6213.75   6215.98  
         BIC | 6377.94   6231.28   6237.80   6244.17   6249.27   6256.57  
--------------------------------------------------------------------------
                                                              legend: b/se

```

The log hazard ratios are very similar between the different models, particularly from 2df and above (using 1 df is equivalent to fitting a Weibull model). The standard errors are also very similar.

The AIC and BIC can be used as an _informal_ guide (certainly not definitive) to the choice of model.  Both the AIC and BIC are lowest for the model with 2df.

One of the advantages of using parametric models is the simplicity in which we can predict hazard, survival and other useful functions. In the loop when the 6 different models were fitted the baseline hazard and survival functions were also obtained. We can now compare these by plotting them.

First, the baseline hazard functions. Note I used the `per(1000)` option when I predicted the hazard functions to give the rate per 1000 person years.

```stata
. twoway  (line h0_df* temptime), ///
>                 ytitle("hazard rate (per 1000 py)") ///
>                 xtitle("Years from surgery") ///
>                 ylabel(,format(%2.0f) angle(h)) ///
>                 legend(order(1 "1 df" 2 "2 df" 3 "3df" 4 "4df" 5 "5df" 6 "6df") ///
>                         ring(0) cols(1) pos(5))

```


The graph is shown below. The model with 1 df (equivalent to a Weibull model) stands out. The hazard function for the Weibull model is monotonic and so can't pick up the turning point. There is fairly good agreement between the other models. Remember that the AIC and BIC indicate that models with 3df or more are over fitting.

![](/statasvg/ph_sensitivity_hazard.svg)

Now, using similar code we can plot the six baseline survival functions. 

```stata
. twoway  (line s0_df* temptime), ///
>                 ytitle("Survival function - S(t)") ///
>                 xtitle("Years from surgery") ///
>                 ylabel(,format(%3.1f) angle(h)) ///
>                 legend(order(1 "1 df" 2 "2 df" 3 "3df" 4 "4df" 5 "5df" 6 "6df") ///
>                         ring(0) cols(1) pos(1))

```

This graph is shown below and again the model with 1 df stands out, which is not surprising given the hazard function. However, there is excellent agreement between the remaining 5 models. In general, one sees better agreement when comparing survival functions as it is a cumulative measure the small differences seen the hazard functions cancel out.

![](/statasvg/ph_sensitivity_survival.svg)

This has been a simple sensitivity analysis where I have assumed proportional hazards and only fitted a single covariate, but I hope that it shows how simple it is to try these things.

What I see as the key point here is that even when selecting a too complex model (as indicated by the AIC and BIC) it makes little difference to the hazard ratio or the estimated hazard and survival functions. Of course one could argue that this is a single data set, but see Rutherord _et al._ for a more detailed simulation study on the ability of these models to capture complex hazard functions.

### References

Rutherford M.J., Crowther M.J., Lambert, P.C. The use of restricted cubic splines to approximate complex hazard functions in the analysis of time-to-event data: a simulation study. _Journal of Statistical Computation and Simulation_ 2015;**4**:777–793




