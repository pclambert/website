+++
title = 'rcsgen'
date = '2017-09-13'
tags = ["software", "rcsgen"]

  
+++

The `rcsgen` command generates basis function for restricted cubic splines. The command is used by my `stpm2` command to fit flexible parameric survival models. It has a number of advantages over Stata's inbuilt `mkspline` command, which will be demonstrated in the tutorials below. 


## Using `rcsgen`
- Generating splines - use of the `knots()`, `bkknots()` and `percentiles()` options. 
- Using the `scalar()` option for predictions.
- Using the `center()` optin for easier predictions
- Some issues when orthogonalising.
- The derivative of resicted cubic spline function (the `dgen()` option).

