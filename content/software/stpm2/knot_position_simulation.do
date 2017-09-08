cd "C:\website\content\software\stpm2"

clear all
program define enzosim, rclass
  syntax [, OBS(integer 1000) lambda1(real 1) lambda2(real 1) ///
      gamma1(real 1) gamma2(real 1) pi(real 0.5) maxt(real 5)]
  clear
  set obs `obs'
  survsim t d, mixture lambda(`lambda1' `lambda2') gamma(`gamma1' `gamma2') ///
    pmix(`pi') maxt(`maxt')
  replace t = ceil(t*365.24)/365.24
  stset t, f(d==1)
  local harrell4 27.5 50 72.5
  local harrell4b 5 95
  local harrell5 23 41 59 77
  local harrell5b 5 95
  local harrell6 18.33 34.17 50 65.83 81.67
  local harrell6b 2.5 97.5
  foreach i in 4 5 6  {
    stpm2, df(`i') scale(hazard)
    return scalar AIC1_df`i' = e(AIC)
    return scalar BIC1_df`i' = e(BIC)
    stpm2, knots(`harrell`i'') knscale(centile) scale(hazard) bknots(`harrell`i'b')
    return scalar AIC2_df`i' = e(AIC)
    return scalar BIC2_df`i' = e(BIC)
  }
  ereturn clear
end

enzosim,
return list

local scenario1 lambda1(0.6) lambda2(0.6) gamma1(0.8) gamma2(0.8) pi(1) maxt(5)
local scenario2 lambda1(0.2) lambda2(1.6) gamma1(0.8) gamma2(1) pi(0.2) maxt(5)
local scenario3 lambda1(1) lambda2(1) gamma1(1.5) gamma2(0.5) pi(0.5) maxt(5)
local scenario4 lambda1(0.03) lambda2(0.3) gamma1(1.9) gamma2(2.5) pi(0.7) maxt(5)

set seed 78126378
forvalues i = 1/4 {
	simulate , reps(1000) saving(sim_scenaro`i', replace double): enzosim, `scenario`i''
}




capture pr drop weibmixplot
program define weibmixplot
  syntax [, OBS(integer 1000) lambda1(real 1) lambda2(real 1) ///
      gamma1(real 1) gamma2(real 1) pi(real 0.5) maxt(real 5)  scenario(integer 1)]
  twoway function y = `pi'*exp(-`lambda1'*x^(`gamma1')) + (1-`pi')*exp(-`lambda2'*x^(`gamma2')) ///
    , range(0 `maxt') name(s`scenario',replace) ///
    xtitle("Time (years)") ///
    ytitle("S(t)") ///
    ylabel(,angle(h) format(%3.1f)) ///
	title("Scenario `scenario'")
 twoway function y = (`lambda1'*`gamma1'*x^(`gamma1' - 1)*`pi'*exp(-`lambda1'*x^(`gamma1')) + ///
                     (`lambda2'*`gamma2'*x^(`gamma2' - 1)*(1-`pi')*exp(-`lambda2'*x^(`gamma2'))))/ ///
					 (`pi'*exp(-`lambda1'*x^(`gamma1')) + (1-`pi')*exp(-`lambda2'*x^(`gamma2'))) ///
    , range(0 `maxt') name(h`scenario',replace) ///
    xtitle("Time (years)") ///
    ytitle("h(t)") ///
    ylabel(,angle(h) format(%3.1f)) ///
	title("Scenario `scenario'")
	
end

local scenario1 lambda1(0.6) lambda2(0.6) gamma1(0.8) gamma2(0.8) pi(1) maxt(5) 
local scenario2 lambda1(0.2) lambda2(1.6) gamma1(0.8) gamma2(1) pi(0.2) maxt(5)
local scenario3 lambda1(1) lambda2(1) gamma1(1.5) gamma2(0.5) pi(0.5) maxt(5)
local scenario4 lambda1(0.03) lambda2(0.3) gamma1(1.9) gamma2(2.5) pi(0.7) maxt(5)
forvalues i = 1/4 {
	weibmixplot ,  `scenario`i'' scenario(`i')
}
graph combine s1 s2 s3 s4, nocopies name(true_s, replace) title("Survival functions")
graph combine h1 h2 h3 h4, nocopies name(true_h, replace) title("Hazard functions")
