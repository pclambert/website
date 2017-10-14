+++
title = 'stpm2'
date = '2017-08-21'
tags = ["software", "stpm2"]

  
+++

`stpm2` fits flexible parametric survival models. These models use splines to model some transformation of the survial function. The most common is the  $\log\[-\log\[S(t)\]\]$ link function, which fits proportional hazards models.

I have added some examples and aim to add to these.

## Proportional hazards models
- [Comparison with a Cox model]({{< ref "software/stpm2/comparewithcox.md" >}})
- Simple simulation study to show agreement with Cox model.
- [Predicting hazard and survival functions (use of the `timevar()` option)]({{< ref "software/stpm2/stpm2_timevar.md" >}})
- [Sensitivity analysis for the number of knots]({{< ref "software/stpm2/sensitivity_analysis.md" >}}).
- [The default knot positions - are they sensible?]({{< ref "software/stpm2/knot_positions_sensitivity.md" >}})

## Time-dependent effects (non proportional hazards)
- Non-proportional hazards
 
## Relative survival 
- A simple relative survival model

## Alternative link functions
- the logistic, probit and Aranda-Ordaz link functions.



