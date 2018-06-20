+++
date = "2018-06-17"
title = "Attributable Fraction from Standardized Survival Functions"
summary = "stpm2"
tags = ["stpm2","stpm2_standsurv","software","Stata","survival","Standardization"]
external_link = "" 
math = true
[header]
image = ""
caption = ""
+++



This example will demonstrate how the attributable fraction ($AF$) can be obtained for survival data. It will also demonstrate the flexibility to calculate various function of standardized estimates through use of the `userfunction()' option.


The is defined in epidemiology as the proportion of preventable outcomes if all subjects had not been exposed to a particular exposure. i.e.

$$
AF = \frac{P(D=1) - P(D=1|X=0)}{P(D=1)}
$$

where $P(D)$ is proportion diseased in the whole population, and $P(D|X=0)$ is the probability of being diseased in the exposed. In observation studies there will be confounding and we need to consider potential confounders, $Z$. 

$$
AF = \frac{E(D=1|Z) - E(D=1|X=0,Z)}{P(D|Z)}
$$

In survival studies the probability of being diseased is a function of time, so we define the $AF$ using the failure function, $F(t) = 1 - S(t)$, so $AF(t)$ is defined as

$$
AF(t) = \frac{E[F(t|Z)] - E[F(t|X=0,Z)]}{E[F(t|Z)]} = 1 - \frac{E[F(t|X=0,Z)]}{E[F(t|Z)]}
$$

$E[F(t|Z)]$ is the standardized failure function over covariate distribution, $Z$, and $E[F(t|X=0,Z)]$ is the standardized failure function over covariate distribution, $Z$ where all subjects forced to be unexposed. See Samualson (2008) for some background.

## Example

I will use the Rotterdam Breast cancer data. The code below loads and `stset`'s the data and then fits a model using `stpm2`. 

```stata
. clear all

. use https://www.pclambert.net/data/rott2b, 
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

It is worthwhile commenting what we mean be "exposed" here. Those on hormal treatment will be consided unexposed and those **not** taking the treatment will be unexposed, i.e our unepxosed group is when `hormon=1`.


I will first use the `failure` option to calculate the standardized failure probabilities in both groups. I also predict the failure probability in the population as a whole. I do this using `.` within an `at()' option, i.e. using `at3(.)` in the example below.

```stata
. range timevar 0 10 101
(2,881 missing values generated)

. stpm2_standsurv, at1(hormon 0) at2(hormon 1) at3(.) timevar(timevar) ci atvar(F_hormon0 F_hormon1 F_all) failure

. 
. twoway  (line F_hormon0 timevar) ///
>     (line F_hormon1 timevar) ///
>     (line F_all timevar) ///
>         , legend(order(1 "No treatment" 2 "Treatment" 3 "All") cols(1) pos(11)) /// 
>     ylabel(, format(%3.1f)) ///
>     ytitle("S(t)") ///
>     xtitle("Years from surgery") 

```


![](/statasvg/stpm2_standsurv_failure_stand.svg)

These are just 1 - the standardized survival functions. There are more untreated women (88.6%) which is why the "No Treatment" function is closer to the combined function.The attributable fraction could be calculated using

```stata
. gen AF_tmp = 1 - F_hormon1/F_all
(2,882 missing values generated)

. list timevar F_hormon1 F_all AF_tmp if inlist(timevar,1,5,10), noobs

  +--------------------------------------------+
  | timevar   F_hormon1       F_all     AF_tmp |
  |--------------------------------------------|
  |       1   .01685169   .02035349    .172049 |
  |       5   .22362896   .26167585    .145397 |
  |      10   .39250923   .44808119   .1240221 |
  +--------------------------------------------+

```

I have listed the $AF$ at 1, 5 and 10 years. If I just wanted a point estimate I could stop here. However, generally we will want to calculate confidence intervals. This is where the `userfunction()` option comes in. We can calculate a transformation of our standardized estimates with standard errors estimated using the delta method where derivatives are calculated numerically (similar to `nlcom` and `predictnl`). I "borrowed" the idea of a `userfunction()` from Arvid Sjölander's `stdReg` R package (Sjölander 2018).


The user function needs to be written in Mata. The function should receive one argument `at`, which refer to the various `at` options and can be indexed by `at[1]`, `at[2]` etc. The code below calculates the AF assuming that `at1` is the standardized failure function in the population as a whole and `at2` is the standardized failure function assuming everyone is unexposed (takes hormonal treatment). We need to be careful to specify the `at()` options is this order.

```stata
. mata
------------------------------------------------- mata (type end to exit) ------------------------------------------------------------------------------------------------------------------------------------
: function calcAF(at) {
>     // at2 is F(t|unexposed,Z)
>     // at1 is F(t,Z)
>     return(1 - at[2]/at[1])
> }

: end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

```

Having defined the Mata function I just pass this to `stpm2_standsurv` using the `userfunction()` option.

```stata
. stpm2_standsurv, at1(.) at2(hormon 1) ci timevar(timevar) failure ///
>     userfunction(calcAF) userfunctionvar(AF) 

```

I have specified the `userfunctionvar(AF)` option so that the new variable is called `AF`. Without this option
the default is `_userfunc`. I can now plot the AF as a function of follow-up time.


```stata
. twoway  (rarea AF_lci AF_uci timevar, color(red%30)) ///
>     (line AF timevar, lcolor(red)) ///
>     , legend(off) /// 
>     ylabel(0(0.05)0.3, format(%4.2f)) ///
>     ytitle("AF") ///
>     xtitle("Years from surgery") 

```

![](/statasvg/stpm2_standsurv_AF_stand.svg)

I purposely chose for the effect of hormonal treatment to be proportional as this example is illustrative. When I relaxed this assumption, the AF was negative for the first few months.

Samualson (2008) defines alternative based on the hazard function. I am less keen on this than the use of the survival function, but show how this can be
estimated using `stpm2_standsurv` for completeness.

Samualson defines this is the attributable hazard fraction. The equation is similar to the AF defined above, but we replace the failure function with the hazard function.

$$
AHF(t) = \frac{E[\lambda(t|Z)] - E[\lambda(t|X=0,Z)]}{E[\lambda(t|Z)]} = 1 - \frac{E[\lambda(t|X=0,Z)]}{E[\lambda(t|Z)]}
$$

This give the proportion of preventable events **at** time $t$ rather than **by** time $t$.

See the page of [The hazard function of the standardized survival curve.]({{< ref "software/stpm2_standsurv/standardized_survival_hazard.md" >}}) for a description of standardized hazard functions. 

As I just have to replace the failure probability with the hazard function, I can just use the same Mata function. This means that I just have the change the option `failure` to `hazard` in `stpm2_standsurv`.

```stata
. drop _at*

. stpm2_standsurv, at1(.) at2(hormon 1) ci timevar(timevar) hazard ///
>     userfunction(calcAF) userfunctionvar(AHF) 

```

I can now plot the results.

```stata
. twoway  (rarea AHF_lci AHF_uci timevar, color(red%30)) ///
>     (line AHF timevar, lcolor(red)) ///
>     , legend(off) /// 
>     ylabel(0(0.05)0.3, format(%4.2f)) ///
>     ytitle("AHF") ///
>     xtitle("Years from surgery") 

```

![](/statasvg/stpm2_standsurv_AHF_stand.svg)



## References

Samuelsen S.O., Eide G.E. Attributable fractions with survival data. *Statistics in Medicine* 2008;**27**:1447--1467

Sjölander A. Estimation of causal effect measures with the R-package stdReg.*European Journal of Epidemiology* 2018
