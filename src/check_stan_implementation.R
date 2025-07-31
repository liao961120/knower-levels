library(stom)

##### Check Likelihood Implementations #####
bugs = function(i, j, k) {
    nz = 6
    ind1 = (i - 1) >= k
    ind2 = k == j
    ind3 = i == 1
    ind4 = i == nz
    ind5 = ind3 + ind4 * (2 + ind2) + 
        (1 - ind4) * (1 - ind3) * (ind1 * ind2 + ind1 + 1)
    return(ind5)
}

mine = function(i, j, k) {
    if (!understands(i,k)) return(1)
    if (j == k) {
        return(3)
    } else {
        return(2)   
    }
}

understands = function(i, k) {
    if (i == 1) return(FALSE)
    if (i == 6) return(TRUE)
    if (i > k) return(TRUE)
    return(FALSE)
}

d = expand.grid(
    i = 1:6,
    j = 1:10,
    k = 1:10 
)
d$bugs = sapply(1:nrow(d), 
                \(idx) bugs(d$i[idx], d$j[idx], d$k[idx]) )
d$mine = sapply(1:nrow(d), 
                \(idx) mine(d$i[idx], d$j[idx], d$k[idx]) )
all(d$bugs == d$mine)


##### Compare Inference Results ######
fit_bugs = readRDS("made/m3_fit.RDS")
fit_mine = readRDS("made/m2_fit.RDS")

piprime = list(
    bugs = precis(fit_bugs, pars="npiprime", depth=4),
    mine = precis(fit_mine, pars="piprime", depth=4)
)

plot(piprime$bugs$mean, piprime$mine$mean); abline(0,1)
idx = which(abs(piprime$bugs$mean - piprime$mine$mean) > .01)

piprime$bugs[idx,]
