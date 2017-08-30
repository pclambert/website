+++
date = "2017-08-06"
title = "Proportional hazards models in stpm2"
summary = "stpm2"
tags = ["stpm2","survival","software","Stata","proportional hazards"]
external_link = "" 
math = true
[header]
image = ""
caption = ""
+++

# Proportional hazards model

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

The `scale(365.25)` option converts the times recorded in days to years.

A standard Cox proportional hazards model can be defined as follows,

$$
h_i(t|\mathbf{x}\_i)=h_0(t)\exp\left(\mathbf{x}\_i\boldsymbol{\beta}\right)
$$

A key point about the Cox model is that we do not estimate the baseline hazard, $h\_0(t)$, as this cancels out in the partial likelihood, so we only estimate the relative effects, i.e. hazard ratios.
 
We can now fit a Cox model in Stata with `hormon` as the only covariate.

```stata
. stcox hormon, 

         failure _d:  censrec == 1
   analysis time _t:  rectime/365.24

Iteration 0:   log likelihood = -1788.1731
Iteration 1:   log likelihood =  -1783.774
Iteration 2:   log likelihood =  -1783.765
Iteration 3:   log likelihood =  -1783.765
Refining estimates:
Iteration 0:   log likelihood =  -1783.765

Cox regression -- Breslow method for ties

No. of subjects =          686                  Number of obs    =         686
No. of failures =          299
Time at risk    =  2112.035922
                                                LR chi2(1)       =        8.82
Log likelihood  =    -1783.765                  Prob > chi2      =      0.0030

------------------------------------------------------------------------------
          _t | Haz. Ratio   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
      hormon |   .6949616   .0869009    -2.91   0.004      .543905    .8879705
------------------------------------------------------------------------------

```

We will now fit a flexible parametric survival model. Here are model is on the log *cumulative* hazard scale, so our model is defined using uppercase H rather than lowercase h.

$$
H_i(t|\mathbf{x}\_i)=H_0(t)\exp\left(\mathbf{x}\_i\boldsymbol{\beta}\right)
$$

Do we have to worry about the switch from hazard function to cumulative hazard function? Well, the answer is "No" as if we have proportional hazards we also have proportional cumulative hazards.

In the flexible parametric survival model we estimate the baseline using restriced cubic splines. So we need additional parameters to estimate the baseline (the log cumulative hazard in this case).  The linear predictor is,

$$
\ln[H(t|\mathbf{x}\_i)] = \eta_i(t) = s\left(\ln(t)|\boldsymbol{\gamma}, \mathbf{k}\_{0}\right) + \mathbf{x}\_i \boldsymbol{\beta} 
$$

where $s\left(\ln(t)|\boldsymbol{\gamma}, \mathbf{k}_{0}\right)$ is a restriced cubic spline function of log(time).  

We now fit this model in Stata using `stpm2`.

```stata
. stpm2 hormon, df(3) scale(hazard) eform

Iteration 0:   log likelihood = -671.75275  
Iteration 1:   log likelihood = -670.39949  
Iteration 2:   log likelihood = -670.39239  
Iteration 3:   log likelihood = -670.39239  

Log likelihood = -670.39239                     Number of obs     =        686

------------------------------------------------------------------------------
             |     exp(b)   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
xb           |
      hormon |   .6966754   .0870015    -2.89   0.004     .5454206    .8898757
       _rcs1 |   4.931928   .6329089    12.43   0.000     3.835156    6.342354
       _rcs2 |   1.786812   .2092654     4.96   0.000     1.420329    2.247857
       _rcs3 |   .9519031     .03275    -1.43   0.152     .8898306    1.018306
       _cons |   .3032836   .0247012   -14.65   0.000     .2585366    .3557753
------------------------------------------------------------------------------
Note: Estimates are transformed only in the first equation.

```
I have used three options. The `df(3)` option requests there to be 3 restricted cubic spline parameters (4 knots). These are at the default knot locations, which are at evenly spaced centiles of the uncensored event times. The `scale()` option defines the link function and `scale(hazard)` asks for a log(-log) link function, i.e. our linear predictor is on the log cumulative hazard scale. The `eform` option means that the coefficients will be exponentiated.

The key point here is the similarity between the hazard ratios form the two models. This is nearly always the case. I will try to convince anyone who does not believe this in future posts.

A sensible question is, _if we get the same anwers, why not just fit a Cox model_?  Well, if all you want is a single hazard ratio and proportional hazards is a reasonable assumption then I agree with you. However, as I will show in other examples, there are many advantages of the parametric approach.

There are a number of issues that people may raise. This include how many knots to use and where to put the knots. I will cover these in future tutorials.



 

