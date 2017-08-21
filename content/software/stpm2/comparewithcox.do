# Proportional hazards model

We first load the example breast cancer data data using `webuse` and then use `stset` to declare the survival time and event indicator.


<<dd_do>>
webuse brcancer, clear
stset rectime, f(censrec==1) scale(365.24)
<</dd_do>>




