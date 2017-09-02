+++
date = "2017-08-27"
title = "stcrprep - computational benefits"
summary = "stpm2"
tags = ["survival","software","Stata","competing risks"]
external_link = "" 
math = true
[header]
image = ""
caption = ""
+++

When using `stcrprep` there are some computational benefits when compared to using Stata's inbuilt `stcrreg`. One reason for this is that everytime you fit a model using `stcrreg` you the probability of censoring weights are calculated and the data must be expanded (in the background) when maximising the likelihood. When using `stcrprep` you only need to do this once. 

I have run some timings. If I fit a simple model to the embt1 data with risk score as the only covariate (2 dummy variables) then these are the timings no my current work laptop (Intel i5 - running Stata 15 MP2).

First I load and `stset` the data.

```stata
. use https://www.pclambert.net/data/ebmt1_stata.dta, clear

. stset time, failure(status==1) scale(365.25) id(patid) noshow

```

Now, `stcrreg` can be used

```stata
. timer clear

. timer on 1

. stcrreg i.score, compete(status==2) nolog noshow

Competing-risks regression                       No. of obs       =      1,977
                                                 No. of subjects  =      1,977
Failure event  : status == 1                     No. failed       =        456
Competing event: status == 2                     No. competing    =        685
                                                 No. censored     =        836

                                                 Wald chi2(2)     =       9.87
Log pseudolikelihood = -3333.3217                Prob > chi2      =     0.0072

                              (Std. Err. adjusted for 1,977 clusters in patid)
------------------------------------------------------------------------------
             |               Robust
          _t |        SHR   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
       score |
Medium risk  |   1.271221   .1554323     1.96   0.050     1.000333    1.615465
  High risk  |   1.769853   .3238535     3.12   0.002     1.236465    2.533337
------------------------------------------------------------------------------

. timer off 1

. timer list
   1:     15.35 /        1 =      15.3500

```

This takes 15.4 seconds to fit. 

I now reload and `stset` the data, but this time declaring both `status=1` and `status=2` as events.

```stata
. use https://www.pclambert.net/data/ebmt1_stata.dta, clear

. stset time, failure(status==1,2) scale(365.25) id(patid)

```

We can now run `stcrprep`.

```stata
. timer on 2

. stcrprep, events(status) keep(score) trans(1)   

. timer off 2

. timer list 2
   2:      4.39 /        1 =       4.3910

```



This takes  4.4 seconds to run. However, this only restructures the data and calculates the weights. To fit the model, we first generate the event indicator and  use `stset`.


```stata
. gen      event = status == failcode

. stset tstop [iw=weight_c], failure(event) enter(tstart) 

```

We use `stcox` to fit the model.

```stata
. timer on 3

. stcox i.score

         failure _d:  event
   analysis time _t:  tstop
  enter on or after:  time tstart
             weight:  [iweight=weight_c]

Iteration 0:   log likelihood = -3338.1244
Iteration 1:   log likelihood = -3333.4173
Iteration 2:   log likelihood = -3333.3113
Iteration 3:   log likelihood = -3333.3112
Refining estimates:
Iteration 0:   log likelihood = -3333.3112

Cox regression -- Breslow method for ties

No. of subjects =       72,880                  Number of obs    =      72,880
No. of failures =          456
Time at risk    =   6026.27434
                                                LR chi2(2)       =        9.63
Log likelihood  =   -3333.3112                  Prob > chi2      =      0.0081

------------------------------------------------------------------------------
          _t | Haz. Ratio   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
       score |
Medium risk  |   1.271235   .1593392     1.91   0.056     .9943389    1.625238
  High risk  |   1.769899   .3219273     3.14   0.002     1.239148     2.52798
------------------------------------------------------------------------------

. timer off 3

. timer list
   1:     15.35 /        1 =      15.3500
   2:      4.39 /        1 =       4.3910
   3:      1.09 /        1 =       1.0930

```

This takes  1.1 seconds to run giving a combined total of  5.5 seconds. What is important is that if we want to fit other models (including other covariates etc), then we do not need to run `stcrprep` again.

To assess the time on larger data I have expanded the data by 20 times and added a small random number to each time, so that there are no ties. I used the following code.

```stata
expand 20
replace time = time + runiform()*0.0001
replace patid = _n
```

This leads to 19,770 indviduals in the analysis. The fact that there are no ties is perhaps a little unrealistic in a dataset this size, but this is still a usefull assessment of computational speed. The same analysis as above on this larger dataset gave the following times.


|command|Time|
|---|---|
|`stcrreg`|2066.3 seconds|
|`stcrprep`|890.2 seconds|
|`stcox`|46.1 seconds|

I think this really highlights the benfits of restructuring the data and using `stcox` in terms of computational time. Unless there is need to recalculate the probability of censoring weights, there is no need to do this every time you fit a model. Thus, in this case an `stcrreg` model takes almost 35 minutes, whilst the same model using `stcox` after using `stcrprep`takes only 46 seconds.

It is worthwhile noting that Stata's implementation of Fine and Grays proportional subhazards model using `stcrreg` seems particularly slow. If I fit the model in R using `crr` the model fitted to the expanded data it only takes 370 seconds compared to 2066 in Stata. 

There are other benefits with using `stcox` to fit the subhazards model, mainly because we can now use many of the other commands and extensions associated with `stcox`. I will discuss these in other tutorials.


