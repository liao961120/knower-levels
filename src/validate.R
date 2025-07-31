library(stom)
dat = readRDS("made/sim.RDS")
f = glue::glue

# Fit model
write_init_files = function(dir="init", chains=1:4) {
    sapply( chains, function(chain) {
        init = tibble::lst(
            Pi    = rep(1/dat$gn, dat$gn), 
            v     = runif(1, 1, 1000),
            theta = sapply(1:dat$ns, \(i) rep(1/dat$nz, dat$nz)) |> t()
        )
        dir.create(dir, showWarnings = F)
        fp = file.path(dir, paste0(chain,".json") )
        cmdstanr::write_stan_json(init, fp)
        fp
    })
}
set.seed(50)
m = cmdstanr::cmdstan_model("src/m2.stan")
fit = m$sample(data = dat, chains = 4, parallel_chains = 4,
               iter_warmup = 700, iter_sampling = 700,
               save_warmup = TRUE, refresh = 200,
               init = write_init_files())
fit$save_object("made/m2_validate.RDS")


library(stom)

ds = precis(fit, pars="Pi,v,Pz", depth=3)
plot(ds$rhat)


v = "Pi"
est = precis(fit, pars=v, depth=3)
true = dat[[v]]
plot(true, est$mean, ylim=range(est$q5, est$q95))
abline(0,1, lty="dashed")
for (i in 1:length(true)) {
    points(true[i], est$mean[i], col=2, pch=19)
    x_ = rep(true[i], 2)
    y_ = c(est$q5[i], est$q95[i])
    lines(x_, y_, col=stom::col.alpha(2), lwd=2)
}

# Viz posterior knower levels 
Pz = precis(fit, depth=3, pars="Pz")
mat_Pz = matrix(Pz$mean, nrow=dat$ns, ncol=dat$nz)
par(mfrow=c(4,5))
for (i in 1:dat$ns) {
    barplot(mat_Pz[i,], main=f('Subject {i} / z = {dat$z[i]}'))
}
