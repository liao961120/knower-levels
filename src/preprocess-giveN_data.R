# Data for number concept development taken from Bayesian Cognitive modeling's 
# associated code (Lee & Wagenmakers, 2013), available at <https://bayesmodels.com>
library(R.matlab)
d <- readMat("raw/NumberConcepts/fc_given.mat")
str(d)

dat = list(
    ns  = d$ns[1,1],
    nz  = d$nz[1,1],
    # give-N data
    gn  = d$gn[1,1],
    gnq = d$gnq[1, ],
    gq  = d$gq,
    ga  = d$ga,
    # fast-cards data
    fnq = d$fnq[1,],
    fq  = d$fq,
    fa  = d$fa
)
str(dat)

dir.create("made", showWarnings=F)
jsonlite::write_json(dat, "made/data.json", pretty=T, auto_unbox=T)
