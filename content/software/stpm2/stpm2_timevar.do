clear

use https://www.pclambert.net/data/rott2b, clear
stset rf, f(rfi==1) scale(12) exit(time 60)
rcsgen age, df(3) gen(agercs) center(60)

stpm2 hormon agercs* pr_1, scale(hazard) df(4) eform

range tt 0 5 100
predict s0, survival timevar(tt) zeros ci

twoway (rarea s0_lci s0_uci tt, color(blue%25)) ///
		(line s0 tt, lcolor(red)) ///
		, legend(off) ///
		ylabel(,angle(h) format(%3.1f)) ///
		xtitle("Years from surgery") ///
		ytitle("S(t)")

predict h0, hazard timevar(tt) at(hormon 0 pr_1 3.43) zeros per(1000) ci
predict h1, hazard timevar(tt) at(hormon 1 pr_1 3.43) zeros per(1000) ci

twoway	(rarea h0_lci h0_uci tt, color(red%25)) ///		
		(rarea h1_lci h1_uci tt, color(blue%25)) ///
		(line h0 tt, lcolor(red) lwidth(thick)) ///
		(line h1 tt, lcolor(blue) lwidth(thick)) ///
		,xtitle("Years from surgery") ///
		ytitle("Recrurrence rate (per 1000 py)") ///
		legend(order( 3 "hormon=0" 4 "hormon=1") ring(0) pos(1) cols(1))
		
gen t1 = 1 
predict s_time1, survival timevar(t1) 
hist s_time1, width(0.02) xlab(0.3(0.1)1) name(t1, replace)		
		
		
gen t5 = 5 
predict s_time5, survival timevar(t5) 
hist s_time5, width(0.02) xlab(0.3(0.1)1)  name(t5, replace)		 

predict t1_age, surv at(hormon 0 pr_1 3.43) ci timevar(t1)
twoway 	(rarea t1_age_lci t1_age_uci age, sort color(blue%25))	///
		(line t1_age age, sort lcolor(red)) ///
		,ytitle("1 year survival") legend(off) ///
		ylabel(,angle(h) format(%3.1f))
		
predict t5_age, surv at(hormon 0 pr_1 3.43) ci timevar(t5)
twoway 	(rarea t5_age_lci t5_age_uci age, sort color(blue%25))	///
		(line t5_age age, sort lcolor(red)) ///
		,ytitle("5 year survival") legend(off) ///
		ylabel(,angle(h) format(%3.1f))
