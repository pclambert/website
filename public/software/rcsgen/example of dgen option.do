clear
set obs 100000
range x -0.5 0.5

local fx (x^2-5)*(x^3-2*x+3)
local dfx 5*x^4 -21*x^2 +6*x + 10 

local fx x^4 + 2*x^3
local dfx (4*x^3 +6*x^2)


gen y = `fx' + rnormal(0,0.000001)
scatter y x, msize(vtiny) msymbol(Oh)
rcsgen x, df(5) gen(rcs) dgen(drcs) orthog 

regress y rcs*
predict fv
twoway	(scatter y x, msize(vtiny) msymbol(Oh)) ///
		(line fv x, sort) ///
		(function y = `fx', lcolor(black) range(-0.5 0.5))

dydx fv x, gen(deriv)

gen rcs_deriv = _b[rcs1]*drcs1 + _b[rcs2]*drcs2 + _b[rcs3]*drcs3 + _b[rcs4]*drcs4 + _b[rcs5]*drcs5


twoway (line deriv x) ///
		(line rcs_deriv x) ///
		(function y =`dfx', range(-0.5 0.5))
		
