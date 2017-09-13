clear
set obs 10000
range x -1 1
gen y = x^2 + rnormal(0,0.05)
scatter y x, msize(tiny) msymbol(Oh)

rcsgen x, df(5) gen(rcs) dgen(drcs)
regress y rcs*
predict fv
twoway	(scatter y x, msize(tiny) msymbol(Oh)) ///
		(line fv x, sort)

dydx fv x, gen(deriv)

gen rcs_deriv = _b[rcs1]*drcs1 + _b[rcs2]*drcs2 + _b[rcs3]*drcs3 + _b[rcs4]*drcs4 + _b[rcs5]*drcs5


twoway (line deriv x) ///
		(line rcs_deriv x) ///
		(function y =2*x, range(-1 1))
		
