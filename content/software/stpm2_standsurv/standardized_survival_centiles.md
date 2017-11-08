+++
date = "2017-11-07"
title = "Centiles of Standardized Survival Functions"
summary = "stpm2"
tags = ["stpm2","stpm2_standsurv","software","Stata","survival","Standardization"]
external_link = "" 
math = true
[header]
image = ""
caption = ""
+++

## Background

In the previous tutorial I used `stpm2_standsurv` to obtain standardized survival functions. In this tutorial I show the first of a 
number of different measures of the standardized survival function where I obtain centiles of the standardized survival function.

As a reminder a centiles of a survival function can be obtanined by solving $S(t) = \alpha$ for $t$. For simple parametric distributions, such as the Weibull, this can be done analytically, but for more complex models the centile is obtained analytically. This what is done when using `stpm2`. 

The centile of a standardized survival function is obtained by solving the following equation for t. 

$$
E\left(S(t | X=x,Z\right) = \alpha
$$

This is done through root finding (using Brent's root finder) by solving

$$
\sum_{i=1}^N {S(t | X=x,Z)} - \alpha = 0
$$

Variances can be obtained using M-estimation.

## Example

I use a colon cancer example. I first load and `stset` the data

```stata
. //use https://www.pclambert.net/data/colon, clear
. use c:/cansurv/data/colon, clear
(Colon carcinoma, diagnosed 1975-94, follow-up to 1995)

. drop if stage==0
(2,356 observations deleted)

. stset surv_mm, f(status=1,2) scale(12) exit(time 120)

     failure event:  status == 1 2
obs. time interval:  (0, surv_mm]
 exit on or before:  time 120
    t for analysis:  time/12

------------------------------------------------------------------------------
     13,208  total observations
          0  exclusions
------------------------------------------------------------------------------
     13,208  observations remaining, representing
      8,866  failures in single-record/single-failure data
 43,950.667  total analysis time at risk and under observation
                                                at risk from t =         0
                                     earliest observed entry t =         0
                                          last observed exit t =        10

```

I drop those with missing stage information (`stage == 0`). I am investigating all cause survival (`status=1,2`).

I fit a model that includes stage, sex and age (using a rectriced cubic splines). I assume proportional hazards, but if I relax this assusmption the syntax for `stpm2_standsurv` would be identical. Stage is classified as local, regional and distant and is modelled using two dummatu covariates with local as the reference category.


```stata
. tab stage, gen(stage)

   Clinical |
   stage at |
  diagnosis |      Freq.     Percent        Cum.
------------+-----------------------------------
  Localised |      6,274       47.50       47.50
   Regional |      1,787       13.53       61.03
    Distant |      5,147       38.97      100.00
------------+-----------------------------------
      Total |     13,208      100.00

. gen female = sex==2

. rcsgen age, df(3) gen(agercs) center(60)
Variables agercs1 to agercs3 were created

. stpm2 stage2 stage3 female agercs*, scale(hazard) df(4) nolog eform

Log likelihood = -19665.932                     Number of obs     =     13,208

------------------------------------------------------------------------------
             |     exp(b)   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
xb           |
      stage2 |   1.758926   .0617187    16.09   0.000     1.642026    1.884149
      stage3 |   5.656322   .1390555    70.48   0.000      5.39024    5.935539
      female |   .8634681     .01891    -6.70   0.000     .8271894     .901338
     agercs1 |   .9958187   .0053355    -0.78   0.434     .9854161    1.006331
     agercs2 |   1.000015   .0000127     1.22   0.223     .9999906     1.00004
     agercs3 |   .9999654   .0000155    -2.24   0.025     .9999351    .9999957
       _rcs1 |   3.484444   .0392205   110.90   0.000     3.408415    3.562169
       _rcs2 |     1.1908   .0101285    20.53   0.000     1.171113    1.210817
       _rcs3 |   .9620673   .0050498    -7.37   0.000     .9522207    .9720158
       _rcs4 |   1.015331    .003491     4.43   0.000     1.008512    1.022197
       _cons |   .1615451   .0046341   -63.55   0.000     .1527132    .1708879
------------------------------------------------------------------------------
Note: Estimates are transformed only in the first equation.

```

The is a clear effect of stage with a hazard ratio of 5.66 for distant stage versus local stage. Remember that I am modelling all¨cause survival and one would expect a cause-specific hazard ratio to be higher. The all-cause mortality rate for females is 14% lower tham males.

I will now predict the standardized survival function, one where I force all subjects to be male and one where I force everyone to be female.


```stata
. range tt 0 10 100
(13,108 missing values generated)

. stpm2_standsurv, at1(female 0) at2(female 1) timevar(tt) atvar(ms_male ms_female) ci

. twoway  (line ms_male ms_female tt, sort) ///
>                 , yline(0.5, lpattern(dash) lcolor(black)) ///
>                 yline(0.5, lpattern(dash) lcolor(black)) ///
>                 xtitle("Years since diagnosis") ///
>                 ytitle("S(t)", angle(h)) ///
>                 ylabel(0(0.2)1, format(%3.1f) angle(h)) ///
>                 legend(order(1 "Male" 2 "Female") ring(0) pos(1) cols(1))

```

The graph of the two standardised survival functions can be seen below.


![](/statasvg/stpm2_standsurv_survival_centile1.svg)

As expected (given the hazard ratio) females have better survival than males. I have added a horizontal reference line at $S(t) 0.5$. Where thhis line crosses the survival curves gives the median survival time. Reading from the graph, this is just under 2 years for the males and just under 2.5 years for females. Using the `centile` option of `stpm2_standsurv` will estimate these values more accurately with 95% confidenec intervals. We are also interested in contrasts of the centiles and 

```stata
. stpm2_standsurv, at1(female 0) at2(female 1) timevar(tt) centile(50) ///
>                 atvar(med_male med_female) contrast(difference) ci

. list med_male* in 1     

     +-----------------------------------+
     |  med_male   med_m~lci   med_m~uci |
     |-----------------------------------|
  1. | 1.9801987   1.8728516   2.0936987 |
     +-----------------------------------+

. list med_female* in 1   

     +-----------------------------------+
     | med_fem~e   med_f~lci   med_f~uci |
     |-----------------------------------|
  1. | 2.4249751   2.3000843   2.5566472 |
     +-----------------------------------+

. list _contrast* in 1

     +----------------------------------+
     | _contra~1   _cont~lci   _con~uci |
     |----------------------------------|
  1. | .44477636   .30074772    .588805 |
     +----------------------------------+

```

The median survival time is 1.98 years for males with a 95% CI (1.87 to 2.09). The median for females is 2.42 years (95% CI, 2.30 to 2.56). As I use the `contrast` option I also get the difference in the median of the standardised survival curves with a 95% CI. Thus the time at which 50% of females have died is 0.44 years more than the time at which 50% of males have died, 95% CI (0.30 to 0.59).

It is possible to predict for multiple centiles by passing a **numlist** to the `centiles` option. For example, the code below calculations centiles xxx

```stata
. stpm2_standsurv, at1(female 0) at2(female 1) timevar(tt) centile(10(10)60) ///
>                 atvar(cen_males cen_females) contrast(difference) ci ///
>                 centvar(centiles) contrastvar(cendiff)

. list centile cen_males cen_females cendiff in 1/6, sep(0) noobs

  +----------------------------------------------+
  | centiles   cen_males   cen_fem~s     cendiff |
  |----------------------------------------------|
  |       10   .14919254   .16940399   .02021145 |
  |       20   .32365079   .38459929    .0609485 |
  |       30   .63821705   .78393263   .14571558 |
  |       40   1.1648032   1.4192444   .25444124 |
  |       50   1.9801987   2.4249751   .44477636 |
  |       60   3.4239223    4.277573   .85365069 |
  +----------------------------------------------+

```

## Acknowledgement

I would like to acknowledge David Druker of StataCorp who I discussed these ideas with at two Nordic Stata User group meetings. David has written a command that estimates centiles of standardized distributions using a two parameter gamma distribution which is available [here]{https://www.researchgate.net/publication/263218606_Quantile_treatment_effect_estimation_from_censored_data_by_regression_adjustment}.
