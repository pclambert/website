+++
title = 'stcrprep'
date = '2017-08-21'
tags = ["software", "stcrprep","competing risks"]
+++

stcrprep prepares data for estimating and modelling cause-specific cumulative incidence functions using time-dependent weights. Once the data has been prepared and the weights incorporated using `stset` it is possible to obtain a graph of the non-parametric estimates of the cause-specific cumulative incidence function using `sts graph`.  In addition a model that estimates subhazard ratios (equivalent to the Fine and Gray model) can be fitted using `stcox`. It is also possible to fit parametric models to directly estimate the cause-specific CIF (my main reason for developing the command).

Below are some simple examples of using `stcrprep`.

## Examples

### Non and semi parametric methods
- Using `sts graph` for cause-specific CIFs
- Using `stcox` instead of `stcrreg`
- Schoenfeld residuals

### Parametric models
- Using `stpm2` to model the cause-specific CIF
- Alternative link functions.


