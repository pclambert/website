clear all
use https://www.pclambert.net/data/rott2b if nodes>0, 


// assume that maximum follow-up is 5 years
gen os2 = cond(os<(5*12),os,60)
gen osi2 = cond(os<(5*12),osi,0)

stset os2, f(osi2==1) scale(12) 

// stteffects using regression adjustment
// Weibull
stteffects ra (age enodes) (hormon), 
// Log Normal
stteffects ra (age enodes,lnormal) (hormon), 

// Intereactions between enodes and hormon
gen age_h = age*hormon
gen enodes_h = enodes*hormon

stpm2 hormon age enodes age_h enodes_h, scale(hazard) df(1) eform nolog tvc(hormon) dftvc(1)
range tt 0 5 100

// Note the interactions
stpm2_standsurv, at1(hormon 0 age_h 0 enodes_h 0) at2(hormon 1 age_h = age enodes_h = enodes) ci atvar(S_h0 S_h1) timevar(tt) trans(none)

twoway   (rarea S_h0_lci S_h0_uci tt, color(red%25)) ///
   (rarea S_h1_lci S_h1_uci tt, color(blue%25)) ///
   (line S_h0 tt, sort lcolor(red)) ///
   (line S_h1 tt, sort lcolor(blue)) ///
   , legend(order(1 "No hormonal treatment" 2 "Hormonal treatment") ring(0) cols(1) pos(1)) ///
   ylabel(0(0.1)1,angle(h) format(%3.1f)) ///
   ytitle("S(t)") ///
   xtitle("Years from surgery")	
  
gen tt5 = 5 in 1 
stpm2_standsurv, at1(hormon 0 age_h 0 enodes_h 0) at2(hormon 1 age_h = age enodes_h = enodes) rmst ci  timevar(tt5) trans(none) ///
	contrast(difference) atvars(rmst_h0 rmst_h1) contrastvar(rmstdiff5)
 
list rmst_h0 rmst_h1 rmstdiff5* in 1, noobs


range ttlong 0 40 100
stpm2_standsurv, at1(hormon 0 age_h 0 enodes_h 0) at2(hormon 1 age_h = age enodes_h = enodes) ci atvar(S_h0b S_h1b) timevar(ttlong) 

twoway  (line S_h0b ttlong, sort lcolor(red)) ///
   (line S_h1b ttlong, sort lcolor(blue)) ///
   , legend(order(1 "No hormonal treatment" 2 "Hormonal treatment") ring(0) cols(1) pos(1)) ///
   ylabel(0(0.1)1,angle(h) format(%3.1f)) ///
   ytitle("S(t)") ///
   xtitle("Years from surgery")	///
   xline(5, lpattern(dash) lcolor(black%50))

gen tt100 = 100 in 1 
stpm2_standsurv, at1(hormon 0 age_h 0 enodes_h 0) at2(hormon 1 age_h = age enodes_h = enodes) rmst ci  timevar(tt100) trans(none) ///
	contrast(difference) atvars(rmst_h0b rmst_h1b) contrastvar(rmstdiff100) mestimation
	
list rmst_h0b rmst_h1b rmstdiff100* in 1, noobs


/// extrapolation
keep if hormon == 0
foreach dist in exponential weibull gompertz loglogistic lognormal ggamma {
	streg, dist(`dist')
	estimates store `dist'
} 

preserve
drop _t
range _t 0 100 
local j 1
foreach dist in exponential weibull gompertz loglogistic lognormal ggamma {
	estimates restore `dist'
	predict s_`dist', surv
	estat ic
	local AIC_`dist': display %6.2f el(r(S),1,5)
	local lines `lines' (line s_`dist' _t)
} 
twoway `lines', ///
    legend(order(1 "Exponential" 2 "Weibull" 3 "Gompertz" 4 "LogLogistic" 5 "LogNormal" 6 "Ggamma") ring(0) cols(1) pos(1)) ///
    xline(5, lpattern(dash) lcolor(black%50))
restore
	