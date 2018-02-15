+++
title = "Interactive Graphs"
date = "2017-01-01T00:00:00Z"
math = true
highlight = false

# Optional featured image (relative to `static/img/` folder).
[header]
image = ""
caption = ""

+++

I have written some programs in JavaScript using the excellent [D3 library](http://d3js.org) as a teaching guide to using splines in regression models and to illustrate some issues in survival analysis. I have found these to be excellent teaching tools and use them in lectures, but also encourage students to try them out to help gain an understanding of key concepts. I stronly believe that to be able to interact with graphs leads to a much better understanding of various methods.

The graphs do not work in older versions of Internet Explorer, but appear OK in newer versions (I am currently using IE11) or using Microsoft Edge. However, the best perforamce appears to be in Chrome and Firefox.


## Splines 


### <a href="spline_eg/spline_eg.html" target="_blank">The number and location of knots</a>

The first graph fits a non-linear function using splines within a linear regression model. The user is allowed to move, add and remove knots. Follow the instructions below the graph. The user can also select different spline functions, including linear, quadratic, cubic and restricted cubic splines. The fitted  regression line is updated in real time. To open the graph in a new window click <a href="spline_eg/spline_eg.html" target="_blank">here</a>.


### <a href="spline_continuity/spline_continuity.html" target="_blank">Continuity restrictions</a>

A spline function of degree $n$ is a piecewise polynomial function whose function values and first $n-1$ derivatives agree at the knots, i.e. the function is constrained to be continuous and continuously differentiable up to order $n-1$. The continuity restrictions graph allows the user to investigate the impact of different continuity restrictions from piecewise polynomials with no restrictions to the function being continuously differentiable up to order  $n-1$. To open the graph in a new window click <a href="spline_continuity/spline_continuity.html" target="_blank">here</a>. Note that the continuity restriction menu sometimes disappears when using Internet Explorer. I am not sure why this is, and suggest you use an alternative browser where this problem does not occur (I have tested in Chrome and Firefox).

## Survival Analysis

### <a href="survival_weibull/survival_weibull.html" target="_blank">Weibull proportional hazards model</a>

This graph plots the probability density function, the survival function and the hazard function from a Weibull model under proportional hazards where two groups are being compared (e.g. standard and new treatment). The Weibull model is as follows,

$$\lambda\gamma t^{\gamma-1}\exp(\beta x))$$

where $h(t)$ is the hazard function and the hazard ratio is $\exp(β)$. The user is able to change the parameters of the baseline hazard, i.e. $\lambda$ and $\gamma$, and also the hazard ratio using the slide bars. It is useful to fix the range of the y-axis at an appropriate level. To open the graph in a new window click  <a href="survival_weibull/survival_weibull.html" target="_blank">here</a>.

### <a href="mixture_weibull/mixture_weibull.html" target="_blank">Mixture Weibull distribution</a>

We have used the mixture Weibull distribution to simulate data when evaluating how well spline function approximate true, complex survival/hazard functions. For example see [Rutherford et al. (2014), Journal of Statistical Computation and Simulation](http://www.tandfonline.com/doi/abs/10.1080/00949655.2013.845890#.VDK1HPldWSo) or [Crowther and Lambert (2014), _Statistics in Medicine_](http://onlinelibrary.wiley.com/doi/10.1002/sim.6300/abstract). This graph allows the user to play around with the parameters of a mixture Weibull distribution and see the hazard/survival curves. The component distributions of the mixture Weibull can also be displayed. <span>To open the graph in a new window click <a href="mixture_weibull/mixture_weibull.html" target="_blank">here</a>.


### <a href="competing_risks/competingrisks.html" target="_blank">Competing Risks</a>

This is a simple demonstration of the link between cause-specific hazards and cause-specific cumulative incidence functions. Assuming exponential distributions, i.e. a constant hazard, the cause-specific hazards for cancer and for other causes can be defined for those unexposed and exposed to a risk factor. By changing the underlying mortality (hazard) rate and/or the hazard ratio between the exposed and unexposed it is possible to see the impact on the cause-specific cumulative incidence function for both cancer and other causes. Performance is not so good in FireFox for some reason. To open the graph in a new window click <a href="competing_risks/competingrisks.html" target="_blank">here</a>.


### <a href="lifeexpectency/life_expectency.html" target="_blank">Expected Survival</a>

This shows expected survival by deprivation quintile and sex. You can drag the age slide bar, so you can see the expected survival for someone of a given age. To open the graph in a new window click [here](lifeexpectency/life_expectency.html).

### <a href="http://interpret.le.ac.uk" target="_blank">InterPreT</a>


This is a webpage developed by Sarwar Islam, a PhD student based in Leicester. This is far more professional looking than my attempts. What we have done here is export the model parameters and details about knot locations etc from a flexible parametric model fitted in Stata using `stpm2`. Various predictions can then be made instantly as they are just transformations of model parameters. I particularly like the ability to drag the y-axis in order to get conditional estimates.

  
### <a href="model_sensitivity/model_sensitivity.html" target="_blank">Model Sensitivity</a>  

This is work with Elisavet Syriopoulou, Sarwar Islam and Mark Rutherford to assess how sensitive estimates obtained from flexible parametric models  (FPM) with different number of knots are. A sensitivity analysis was performed for a range of cancer types. For each cancer type considered, 18 FPMs were fitted assuming varying degrees of freedom to model the log cumulative baseline excess hazard and the main and time dependent effect of age. Both estimates of relative survival and excess hazard functions over years since diagnosis are given and there is also an option to choose marginal or age-specific estimates. Age specific estimates are obtained by moving the slider in the age histogram that is available under the graphs. Agreement across different models is so good that for most of the cancers the estimates overlay.
  