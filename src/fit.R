library(stom)

dat = jsonlite::fromJSON("made/data.json")
dat$nt = 21


# Fit model
write_init_files = function(dir="init", chains=1:4) {
    sapply( chains, function(chain) {
        init = tibble::lst(
            Pi    = rep(1/dat$gn, gn), 
            v     = runif(1, 1, 1000),
            theta = sapply(1:dat$ns, \(i) rep(1/dat$nz, nz)) |> t()
        )
        dir.create(dir, showWarnings = F)
        fp = file.path(dir, paste0(chain,".json") )
        cmdstanr::write_stan_json(init, fp)
        fp
    })
}
set.seed(50)
m = cmdstanr::cmdstan_model("src/m1.stan")
fit = m$sample(data = dat, chains = 4, parallel_chains = 4,
               iter_warmup = 700, iter_sampling = 700,
               save_warmup = TRUE, refresh = 200,
               init = write_init_files())
fit$save_object("made/m1_fit.RDS")


######## Check Model #########
ds = precis(fit, pars="Pi,v,theta", depth=3)
plot(ds$rhat)


# Viz posterior knower levels 
theta = precis(fit, depth=3, pars="theta")
mat_theta = matrix(theta$mean, nrow=dat$ns, ncol=dat$nz)
par(mfrow=c(4,5))
for (i in 1:dat$ns) {
    barplot(mat_theta[i,], main=f('Subject {i}'))
}

