+++
date = "2018-06-15"
title = "RMST of Standardized Survival Functions"
summary = "stpm2"
tags = ["stpm2","stpm2_standsurv","software","Stata","survival","Standardization"]
external_link = "" 
math = true
[header]
image = ""
caption = ""
+++




Here I will show another useful measure from standardized survival functions. There have been several papers promoting the use of restricted mean survival time (RMST) in clinical trials. The arguments are (i) ease of interpretation (though I am not convinced a restricted mean is that easy to explain) and (ii) providing a simple summary in the presence of non-proportional hazards. See Royston and Parmar (2013) for a description of the use of the measure in RCTs.

The restricted mean survival time at time $t^\*$ is defined as,
$$
E\left[min(t,t^*)\right]
$$
i.e. it is the mean up to some point $t^\*$. The treatment effect in a RCT can be defined as the difference in RMST between the randomized arms at time $t^\*$. The RMST can be estimated by calculating the area under the survival curve between 0 and $t^\*$. In an observational study where we need to take account of potential confounders, we can define the RMST of the standardized survival function as

$$
RMST(t^\*|X=x,Z) = \int_0^{t^\*} E\left[S(t|X=x,Z)\right]
$$

and is estimated by

$$
\widehat{RMST}(t^\*|X=x,Z) = \int_0^{t^\*} \frac{1}{N}\sum\_{i=1}^{N}S(t|X=x,Z=z_i)]
$$

Contrasts between exposure groups can either be differences or ratios,

$$
\widehat{RMST}(t^\*|X=1,Z) - \widehat{RMST}(t^\*|X=0,Z) 
$$


$$
\frac{\widehat{RMST}(t^\*|X=1,Z)}{\widehat{RMST}(t^\*|X=0,Z)}
$$

Standardized RMST and contrasts is implemented in `stpm2_standsurv` using the `rmst` option.

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

I have made the effect of our exposure, `hormon`, time-dependent using the `tvc` option to illustrate that we can have interactions etc with our exposure in our model. This is an interaction with time, i.e. non proportional hazards.


I first calculate the standardized survival curves where everyone is forced to be exposed and then unexposed.

```stata
. range timevar 0 10 100
(2,882 missing values generated)

. stpm2_standsurv, at1(hormon 0) at2(hormon 1) timevar(timevar) ci atvar(S_hormon0 S_hormon1)

. 
. twoway  (area S_hormon0 timevar, sort fcolor(red%30) lcolor(red)) ///
>         , legend(off) ///
>         ylabel(0(0.1)1, format(%3.1f)) ///
>         ytitle("S(t)") ///
>         xtitle("Years from surgery") ///
>                 title("No treatment") ///
>                 name(hormon0, replace)

. 
. twoway  (area S_hormon1 timevar, sort fcolor(blue%30) lcolor(blue)) ///
>         , legend(off) ///
>         ylabel(0(0.1)1, format(%3.1f)) ///
>         ytitle("S(t)") ///
>         xtitle("Years from surgery") ///
>                 title("Treatment") ///
>                 name(hormon1, replace)

.                 
. graph combine hormon0 hormon1, nocopies         

```


![](/statasvg/stpm2_standsurv_rmst_stand.svg)

The RMST at 10 years for each of the standardized survival functions is the area under the standardized survival curve, shown by the shaded areas in the graphs above.

I will now run `stpm2_standsurv` again with the `rmst` option to estimate these togther with the difference in RMST. I only want the RMST at 
10 years so create a variable `t_rmst10` with only one observation, equal to 10.

```stata
. gen t_rmst10 = 10 in 1
(2,981 missing values generated)

. stpm2_standsurv, at1(hormon 0) at2(hormon 1) timevar(t_rmst10) rmst ci contrast(difference) ///
>     atvar(rmst_h0 rmst_h1) contrastvar(rmstdiff)

```

I will first list the standardized RMST in both treatment groups.

```stata
. list t_rmst10 rmst_h0* rmst_h1* in 1, noobs abb(12) 

  +------------------------------------------------------------------------------------------+
  | t_rmst10     rmst_h0   rmst_h0_lci   rmst_h0_uci     rmst_h1   rmst_h1_lci   rmst_h1_uci |
  |------------------------------------------------------------------------------------------|
  |       10   7.5444214     7.4318182     7.6587307   7.9386152     7.6870964     8.1983635 |
  +------------------------------------------------------------------------------------------+

```

The RMST at 10 years is 7.54 years in those not taking treatment and 7.94 years in those taking treatment. The 95% confidence
intervals are also shown. As I used the `contrast(difference)` option I can look at the difference in RMST at 10 years.

```stata
. list t_rmst     rmstdiff* in 1, noobs abb(12)

  +---------------------------------------------------+
  | t_rmst10   rmstdiff   rmstdiff_lci   rmstdiff_uci |
  |---------------------------------------------------|
  |       10   .3941938      .11623628      .67215133 |
  +---------------------------------------------------+

```

The difference is 0.39 years (95% CI 0.12 to 0.67).


The RMST will vary by the choice of $t^\*$. A range of values of $t^\*$ can be given and then plotted. 


```stata
. range t_rmst 0 10 50
(2,932 missing values generated)

. stpm2_standsurv, at1(hormon 0) at2(hormon 1) timevar(t_rmst) rmst ci contrast(difference) ///
>     atvar(rmst_h0b rmst_h1b) contrastvar(rmstdiffb)

```

We can plot how the RMST changes and the difference in RMST changes as a function of $t^\*$.

```stata
. twoway  (line rmst_h0b rmst_h1b t_rmst) ///
>         , legend(order(1 "No treatment" 2 "Treatment") cols(1) pos(11)) ///
>         ytitle("RMST (years)") ///
>         xtitle("Years from surgery") ///
>                 name(RMST,replace)

. 
. twoway  (rarea rmstdiffb_lci rmstdiffb_uci t_rmst, color(blue%20)) ///
>                 (line rmstdiffb t_rmst, lcolor(blue)) ///
>         , legend(off) ///
>         ylabel(, format(%3.1f)) ///
>         ytitle("Difference in RMST (years)") ///
>         xtitle("Years from surgery") ///
>                 name(RMSTdiff, replace)

.                 
. graph combine RMST RMSTdiff, nocopies

```


![](/statasvg/stpm2_standsurv_RMST_diff.svg)

## References

Royston, P. Parmar, M. K. B. Restricted mean survival time: an alternative to the hazard ratio for the design and analysis of randomized trials with a time-to-event outcome. 
*BMC medical research methodology* 2013;**13**:152
