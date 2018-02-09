+++
date = "2017-11-09"
title = "Hazard of Standardized Survival Functions"
summary = "stpm2"
tags = ["stpm2","stpm2_standsurv","software","Stata","survival","Standardization"]
external_link = "" 
math = true
[header]
image = ""
caption = ""
+++

This will be a short tutorial as the ideas are very simple. I have previously discussed standardized survival functions. In survival analysis we know that there is a simple mathematical transformation from hazard to survival function and vice versa. The idea here is to transform  to a hazard function from the *standardized* survival function. Recall that a standardized survivak funnction; $S_s(t)$ is 

$$
S_s(t) = \frac{1}{N}\sum\_{i=1}^{N}S(t|X=x,Z)
$$


If we apply the usual transformation from survival to hazard to function ($h(t) = \frac{-d}{dt}\log[S(t)]$) we get

$$
h_s(t) = \frac{1}{N} \frac{\sum\_{i=1}^{N}S(t|X=x,Z=z_i)h(t|X=x,Z=z_i)}{\sum\_{i=1}^{N}S(t|X=x,Z=z_i)}
$$

This is a weighted average of the $N$ individual hazard functions with weights equal to $S(t|X=x,Z=z_i)$, i.e. the predicted survival function for individual $i$ when forced to take a specific value of the exposure variable, $X$, but their observed values of confounding variables, $Z$.

This is implemented in `stpm2_standsurv` using the `hazard` option.

## Example

I will use the Rotterdam Breast cancer data. The code below loads and `stset`'s the data and then fits a model using `stpm2`. 

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

. stpm2 hormon age enodes pr_1, scale(hazard) df(4) eform nolog tvc(hormon) dftvc(3)

Log likelihood = -2666.5999                     Number of obs     =      2,982

--------------------------------------------------------------------------------
               |     exp(b)   Std. Err.      z    P>|z|     [95% Conf. Interval]
---------------+----------------------------------------------------------------
xb             |
        hormon |   .8019893   .0741703    -2.39   0.017     .6690322     .961369
           age |   1.013249   .0024115     5.53   0.000     1.008534    1.017987
        enodes |   .1132406    .011008   -22.41   0.000     .0935961    .1370082
          pr_1 |   .9061179   .0119267    -7.49   0.000      .883041    .9297979
         _rcs1 |   2.644573   .0814503    31.58   0.000     2.489656    2.809129
         _rcs2 |   1.209479   .0379393     6.06   0.000      1.13736    1.286172
         _rcs3 |      1.014   .0162037     0.87   0.384     .9827339    1.046262
         _rcs4 |   .9961807   .0072731    -0.52   0.600     .9820273    1.010538
  _rcs_hormon1 |   1.003465   .0756175     0.05   0.963     .8656822    1.163176
  _rcs_hormon2 |    .891054    .056664    -1.81   0.070      .786637    1.009331
  _rcs_hormon3 |   1.025052   .0390804     0.65   0.516     .9512477    1.104583
         _cons |   1.103353   .1771893     0.61   0.540     .8054133    1.511508
--------------------------------------------------------------------------------
Note: Estimates are transformed only in the first equation.

```

I have made the effect of our exposure, `hormon`, time-dependent using the `tvc` option.


I first calculate the standardized survival curves where everyone is forced to be exposed and then unexposed.

```stata
. range timevar 0 10 100
(2,882 missing values generated)

. stpm2_standsurv, at1(hormon 0) at2(hormon 1) timevar(timevar) ci contrast(difference)

. 
. twoway  (rarea _at1_lci _at1_uci timevar, color(red%25)) ///
>         (rarea _at2_lci _at2_uci timevar, color(blue%25)) ///
>         (line _at1 timevar, sort lcolor(red)) ///
>         (line _at2  timevar, sort lcolor(blue)) ///
>         , legend(order(1 "No hormonal treatment" 2 "Hormonal treatment") ring(0) cols(1) pos(1)) ///
>         ylabel(0.5(0.1)1,angle(h) format(%3.1f)) ///
>         ytitle("S(t)") ///
>         xtitle("Years from surgery")

```


![](/statasvg/stpm2_standsurv_survival_stand_hormon_hazard.svg)


If I run `stpm2_standsurv` again with the `hazard` option I get the corresponding hazard functions of the standardized curves.


```stata
. capture drop _at* _contrast*

. stpm2_standsurv, at1(hormon 0) at2(hormon 1) timevar(timevar) hazard ci contrast(ratio) per(1000)

```

Plot the standardized hazard functions.

```stata
. twoway (rarea _at1_lci _at1_uci timevar, color(red%30)) ///
>         (rarea _at2_lci _at2_uci timevar, color(blue%30)) ///
>         (line _at1 timevar, color(red)) ///
>         (line _at2 timevar, color(blue)) ///
>     , legend(off) ///
>     ylabel(,angle(h) format(%3.1f)) ///
>     xtitle("Years from surgery")         

```


![](/statasvg/stpm2_standsurv_hazard_stand_hormon_hazard.svg)


I can't explain the lower and then higher hazard for those on hormon therapy. Perhaps better adjustment for confounders would change this.

I can also plot the ratio of these two hazard functions with a 95% confidence interval.

```stata
. twoway (rarea _contrast2_1_lci _contrast2_1_uci timevar, color(red%30)) ///
>     (line _contrast2_1 timevar, color(black)) ///
>     , yscale(log) ///
>     ylabel(1 2 4 8 20 40,angle(h) format(%3.1f)) ///
>     xtitle("Years from surgery") ///
>     legend(off) ///
>     yscale(log) 

```


![](/statasvg/stpm2_standsurv_hazard_stand_hormon_hazard_ratio.svg)


If I had used the `difference` argument of the `contrast()` option I would have obtained the absolute difference in the standardized hazard functions.

I am still thinking about the usefulness of this - in general I prefer the idea of standardized survival functions rather than the corresponding hazard function. However, it is harder to see how the risk of events changes over follow-up time with a cumulative measure (i.e. standardized survival).




