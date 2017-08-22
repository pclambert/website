+++
title = 'stpm2'
date = '2017-08-21'
tags = ["software", "stpm2"]

  
+++

`stpm2` fits flexible parametric survival models. These models use splines to model some transformation of the survial function. The most common is the  $\log\[-\log\[S(t)\]\]$ link function, which fits proportional hazards models.

I have added some examples and aim to add to these.

## Proportional hazards models
- [Comparison with a Cox model]({{< ref "software/stpm2/comparewithcox.md" >}})
- simple simulation study to show agreement with Cox model.
- predicting hazard and survival functions (use of the `timevar()` option)
- [Sensitvity analsis for the number of knots]({{< ref "software/stpm2/sensitivity_analysis.md" >}}).

## Time-dependent effects (non proportional hazards)
- non-proportional hazards
 
## Relative survival
- a simple relative survival model

## Alternative link functions
- the logistic, probit and Aranda-Ordaz link functions.



