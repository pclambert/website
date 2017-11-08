+++
date = "2017-08-06"
title = "Standardized survival functions"
summary = "stpm2"
tags = ["stpm2","stpm2_standsurv","software","Stata","survival","proportional hazards"]
external_link = "" 
math = true
[header]
image = ""
caption = ""
+++

## Background

When we are performing data exploration on survival data we usually start with plotting Kaplan-Meier curves. In clinical trials 
with a survival outcome, one would nearly always expect to see a Kaplan-Meier curve plotted. They are incredibly easy to interpret.

In observational studies, we expect that there will be confounding and would usually adjust for these confounders in a Cox model. 
If you have read my other tutorials then you will know that I prefer fitting parametric models, but the choice is that not that important 
if all you want is an adjusted hazard ratio and that you are (i) happy with the proportional hazards assumption, (ii) believe 
you have included all relevant counfounders and (iii) made sensible modelling assumtptions (non-linear effect, interactions etc).

Given we are happy with the model, an adjusted hazard ratio is reported. This is fine, but hazard ratios are more difficult to interpret and
there are further problems when using hazard ratios as causal effects (Hernan 2010, Aaalen *et al.* 2015). Risks are much easier to interpret 
than rates and so quantifying the difference on the survival scale can be desirable. 

Some statistical software implements something called "adjusted" survival curves, but it is not always clear what this means. 
For example, in Stata `stcurve` gives survival curves where certain covariates can be given specific values, but those not specified are given as 
mean values. Thus it gives a prediction for an individual who happens to have the mean values of each covariate. This is a prediction for 
an individual and may not reflect the average in the population. A more appropriate way is to average over the survival curves. For example, 
if we have 1000 individuals in our study we can predict a survival curve for each individual and then take the average of these 1000 curves. 
This is essentially what `stpm2_standsurv` does. 

## Example

I use the Rotterdam breast cancer data and use all cause survival as the outcome. 
I restrict follow-up to 10 years after diagnosis using the `exit()` option. 

```stata
. use https://www.pclambert.net/data/rott2b, clear
(Rotterdam breast cancer data (augmented with cause of death))

. stset os, f(osi==1) scale(12) exit(time 120)

     failure event:  osi == 1
obs. time interval:  (0, os]
 exit on or before:  time 120
    t for analysis:  time/12

------------------------------------------------------------------------------
      2,982  total observations
          0  exclusions
------------------------------------------------------------------------------
      2,982  observations remaining, representing
      1,171  failures in single-record/single-failure data
 20,002.424  total analysis time at risk and under observation
                                                at risk from t =         0
                                     earliest observed entry t =         0
                                          last observed exit t =        10

```

The `scale(12)` option converts the times recorded in months to years.


I will explore differences between women who received hormonal treatment and those who did not. This is our exposure, but as this is 
observational study we know that any association we see may be due to confounding. But.. it is always good to start with a Kaplan-Meier plot

```stata
. sts graph, by(hormon) risktable ///
>         legend(order(1 "No hormonal treatment" 2 "Hormonal treatment") ring(0) cols(1) pos(1)) ///
>         ylabel(0(0.2)1,angle(h) format(%3.1f))

         failure _d:  osi == 1
   analysis time _t:  os/12
  exit on or before:  time 120

```


![](/statasvg/stpm2_standsurv_survival_km.svg)

This plot shows that those receiving hormal treatment had worse survival. If we fit a proportional hazards model with `hormon` as the 
only covariate we get the following, 

```stata
. stpm2 hormon, df(4) scale(hazard) eform nolog   

Log likelihood = -2930.4853                     Number of obs     =      2,982

------------------------------------------------------------------------------
             |     exp(b)   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
xb           |
      hormon |   1.540779   .1326967     5.02   0.000     1.301464    1.824099
       _rcs1 |    2.50398    .069006    33.31   0.000     2.372319    2.642949
       _rcs2 |   1.198509   .0330973     6.56   0.000     1.135364    1.265166
       _rcs3 |   1.018274   .0145595     1.27   0.205     .9901346    1.047214
       _rcs4 |   .9961938   .0067963    -0.56   0.576     .9829618    1.009604
       _cons |   .2935573   .0097629   -36.85   0.000     .2750327    .3133296
------------------------------------------------------------------------------
Note: Estimates are transformed only in the first equation.

```
The hazard ratio indicates that there is a 54% higher mortality rate in those receiving hormonal therapy. 

As this is an observational study we should not stop there and conclude that hormonal therapy is bad for you. We do not know 
who received the hormonal therapy. If those who did tended to be older and have more severe disease then we do not have a fair comparison.

In fact a simple tabulation shows this to be the case,

```stata
. tabstat age nodes, by(hormon)

Summary statistics: mean
  by categories of: hormon (Hormonal therapy)

  hormon |       age     nodes
---------+--------------------
      no |  54.09762  2.326523
     yes |  62.54867  5.719764
---------+--------------------
   Total |  55.05835  2.712274
------------------------------

```

Those who received the hormonal therapy tended to be older and have more lymph node involvment. Thus, even if hormonal treatment did not 
have any effect on survival, we would expect to see a difference in such a simplistic analysis due to the type of people who receieved the treatment.

So, we now adjust for some covariates. To simplify things, I will assume proportional hazards and include the covariates	 age, nodes and 
progesterone receptor. Previous analyses of this data have found that transformation of the nodes variable (exp(-0.12*nodes)) 
and the progesterone variable (log(pr + 1)) model the non-linear effects of these variables fairly well and so I will use these transformed
variables. The model is fitted below

```stata
. stpm2 hormon age enodes pr_1, scale(hazard) df(4) eform nolog

Log likelihood = -2668.4925                     Number of obs     =      2,982

------------------------------------------------------------------------------
             |     exp(b)   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
xb           |
      hormon |   .7906432   .0715077    -2.60   0.009       .66221    .9439854
         age |   1.013244   .0024119     5.53   0.000     1.008528    1.017983
      enodes |   .1132534   .0110135   -22.40   0.000     .0935998    .1370337
        pr_1 |   .9064855   .0119282    -7.46   0.000     .8834055    .9301685
       _rcs1 |   2.632579    .073494    34.67   0.000     2.492403    2.780638
       _rcs2 |   1.184191   .0329234     6.08   0.000     1.121389     1.25051
       _rcs3 |   1.020234   .0150787     1.36   0.175     .9911046     1.05022
       _rcs4 |    .996572   .0073038    -0.47   0.639     .9823591    1.010991
       _cons |   1.101826     .17688     0.60   0.546       .80439    1.509244
------------------------------------------------------------------------------
Note: Estimates are transformed only in the first equation.

```
Things have now changed, the adjusted hazard ratio for `hormon` is 0.79 (95% CI 0.66 to 0.94) indicating a benficial effect. There is strong confounding
here as we have gone from a significant harmful effect to a significant beneficial effect when adjusting for age, number of 
positive lymph nodes and progesterone receptor.

We could stop here, but would the fun be in that. Instead we will try to understand what this hazard ratio means in terms of survival.
First I will replicate what `stcurve` does and then obtain the standardized survival functions. 

The code below obtains the mean of the covariates `age`, `enodes` and `pr_1` and puts these into a macro which can then be passed to the
`at()` option of `stpm2`'s predict command when predicting survival. 

```stata
. foreach var in age enodes pr_1 {
  2.         summ `var', meanonly
  3.         local atopt `atopt' `var' `r(mean)'
  4. }

. range timevar 0 10 100
(2,882 missing values generated)

. predict s0_covave, at(hormon 0 `atopt') surv ci timevar(timevar)

. predict s1_covave, at(hormon 1 `atopt') surv ci timevar(timevar)

```

I will then plot these curves

```stata
. twoway  (line s0_covave timevar, sort) ///
>                 (line s1_covave timevar, sort) ///
>                 , legend(order(1 "No hormonal treatment" 2 "Hormonal treatment") ring(0) cols(1) pos(1)) ///
>                 ylabel(0(0.2)1,angle(h) format(%3.1f)) ///
>                 ytitle("S(t)") ///
>                 xtitle("Years from surgery")

```


![](/statasvg/stpm2_standsurv_survival_atmean.svg)

These are line for two "average" women (i.e. who had the average values of each covariate) with one receiving hormonal treatment and the other
not receiving it. We can see that for such women the difference is in the way we expect, given the hazard ratio, with those on hormonal treatment 
having better survival. If I had categorial covariates then interpretation is awkward. For example, if we modelled sex (not appropriate for this data)
then the prediction would be for someone who was part male and part female.

## Standardized survival curves

We want to calculate the expected survival under two counterfactuals. One where everyone has hormonal treatment and one where everybody does
not take it. See Sjölander 2016 for a nice description of these issue and implementation in an R package, `stdreg`. We also want contrasts 
of these standardized curves, for example a difference in standardized survival curves.

$$
E\left(S(t | X=1,Z\right) - E\left(S(t | X=0,Z\right)
$$

In the above, $X$ is the exposure of interest and $Z$ are the confounders. We are interested in the expectation over the distribution of $Z$, 
with the key point being this distrubution is forced to be the same for $X=0$ and $X=1$. If our model is sufficent for confounding control then
the above gives formula gives the average causal effect.

To estimate the difference in the standardized curves we need to generate the two standardized survival curves. In each of these we predict as many survival curves as there are observations
in the data set and then take the average of these curves. The only difference is that in one we make everyone be exposed (`hormon=1`) and in the 
other we make everybody be unexposed (`hormon=0`).

$$
\frac{1}{N}\sum\_{i=1}^{N}S(t|\mbox{hormon=1},\mbox{age}\_i,\mbox{enodes}\_i,\mbox{pr_1}\_i) - \frac{1}{N}\sum\_{i=1}^{N}S(t|\mbox{hormon=0},\mbox{age}\_i,\mbox{enodes}\_i,\mbox{pr\_1}_i)
$$

There are 2982 observation in the dataset (and in the model). Thus for each of the two standardized curves we need to predict 2982 survival curves 
and then take the average of these curves. We can make some computational efficiency savings by only estimating the survival curves a small number of
time points. This could be a single time point, e.g. the survival at 5 years, or over a range. We often want to plot survival curves and 
about 30-50 time points is usually sufficient for plotting purposes.

To do all this (and more) we use the `stpm2_standsurv` command. I will run the command and the explain the syntax.

```stata
. stpm2_standsurv, at1(hormon 0) at2(hormon 1) timevar(timevar) ci contrast(difference)

```

Each of the  `atn()` options creates a standardized survival curve. Here a covariate (or covariates) can be set to take specific values. 
Any covariates not specified keep their observed values. Thus we are just implementing the equation above. The `timevar()` option gives the 
name of the variable that gives the survival times in which to evaluate the survival function. I have already defined a variable `timevar`
above to be 50 rows ranging from 0 to 10. The `ci` option requests that confidence intervals be calculated. Standard errors are either obtained
using the delta-method or M-estimation. The default is the delta-method (for standardized survival). The `contrast()` option asks for a comparison
of the two survival curves with the `difference` argument asking to take differences in the standardized survival curves. By deafault `at1` is the reference,
i.e. the contrast will be `at2`-`at1`, but this can be changed using the `atref()` option.

The command will create the following variables, `_at1`, `_at2`, `_contrast2_1`. These are the default names, but can be changed using the `atvar()` and
`contrastvar()` options. As the `ci` option was specified there will be upper and lower bounds for the confidence interval (95% by deafult) 
for each estimate.

Below I list the standardized curves at 10 years, followed by their difference.

```stata
. list _at1* if timevar==10, noobs

  +-----------------------------------+
  |      _at1    _at1_lci    _at1_uci |
  |-----------------------------------|
  | .54380594   .50064092   .59069263 |
  +-----------------------------------+

. list _at2* if timevar==10, noobs

  +----------------------------------+
  |      _at2    _at2_lci   _at2_uci |
  |----------------------------------|
  | .60749077   .56414068    .654172 |
  +----------------------------------+

. list _contrast* if timevar==10, noobs ab(16)

  +----------------------------------------------------+
  | _contrast2_1   _contrast2_1_lci   _contrast2_1_uci |
  |----------------------------------------------------|
  |    .06368483          .06368483          .06368483 |
  +----------------------------------------------------+

```

Thus the average survival at 10 years when everyone is forced to be unexposed (not on hormonal treatment) is 0.54 and when
everyone is exposed it is 0.61. The difference is 0.064. We have actually evaluated each function at 50 time points and so we can plot the
estimates together with 95% confidence intervals.

```stata
. twoway  (rarea _at1_lci _at1_uci timevar, color(red%25)) ///
>                 (rarea _at2_lci _at2_uci timevar, color(blue%25)) ///
>                 (line _at1 timevar, sort lcolor(red)) ///
>                 (line _at2  timevar, sort lcolor(blue)) ///
>                 , legend(order(1 "No hormonal treatment" 2 "Hormonal treatment") ring(0) cols(1) pos(1)) ///
>                 ylabel(0.5(0.1)1,angle(h) format(%3.1f)) ///
>                 ytitle("S(t)") ///
>                 xtitle("Years from surgery")

```


![](/statasvg/stpm2_standsurv_survival_stand_hormmon.svg)

And now we can plot the difference in standardized curves together with a 95% confidence interval.

```stata
. twoway  (rarea _contrast2_1_lci _contrast2_1_uci timevar, color(red%25)) ///
>                 (line _contrast2_1 timevar, sort lcolor(red)) ///
>                 , legend(off) ///
>                 ylabel(,angle(h) format(%3.2f)) ///
>                 ytitle("Difference in S(t)") ///
>                 xtitle("Years from surgery")

```


![](/statasvg/stpm2_standsurv_survival_stand_hormon_difference.svg)

The covariate distribution we are averaging over is a combination of those on and not on hormon treatment. 
It may also be of interest to restrict to the covariate distribution of the exposed or the unexposed. Assuming our model has controlled for 
confounding this will give teh average causal effect in the exposed. All we need to do is to add an `if` statement.

```stata
. drop _at* _contrast*

. stpm2_standsurv if hormon==1, at1(hormon 0) at2(hormon 1) timevar(timevar) ci contrast(difference)

```

The resulting standardzied curves can then be plotted.

```stata
. twoway  (rarea _at1_lci _at1_uci timevar, color(red%25)) ///
>                 (rarea _at2_lci _at2_uci timevar, color(blue%25)) ///
>                 (line _at1 timevar, sort lcolor(red)) ///
>                 (line _at2  timevar, sort lcolor(blue)) ///
>                 , legend(order(1 "No hormonal treatment" 2 "Hormonal treatment") ring(0) cols(1) pos(1)) ///
>                 ylabel(0.5(0.1)1,angle(h) format(%3.1f)) ///
>                 ytitle("S(t)") ///
>                 xtitle("Years from surgery")

```


![](/statasvg/stpm2_standsurv_survival_stand_hormon_exposed.svg)

Note that these curves give higher survival. This is because on average those who received hormonal treatment were younger and had less 
severe disease.


We can also plot the difference in these standardized curves together with a 95% confidence interval.

```stata
. twoway  (rarea _contrast2_1_lci _contrast2_1_uci timevar, color(red%25)) ///
>                 (line _contrast2_1 timevar, sort lcolor(red)) ///
>                 , legend(off) ///
>                 ylabel(,angle(h) format(%3.2f)) ///
>                 ytitle("Difference in S(t)") ///
>                 xtitle("Years from surgery")

```


![](/statasvg/stpm2_standsurv_survival_stand_hormon_exposed_difference.svg)



## References
Aalen O.O., Cook R.J. Røysland K. Does Cox analysis of a randomized survival study yield a causal treatment effect? *Lifetime data analysis* 2015;21:579-593.
 
Hernán M.A. The hazards of hazard ratios. *Epidemiology* 2010;**21**:13-15

Sjölander A. Regression standardization with the R package `stdReg`. *European Journal of Epidemiology* 2016;**31**:563–574
