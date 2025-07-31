library(stom)

dat = jsonlite::fromJSON("made/data.json")
dat$nt = 21


# Fit model
write_init_files = function(dir="init", chains=1:4) {
    sapply( chains, function(chain) {
        init = tibble::lst(
            Pi    = rep(1/dat$gn, dat$gn), 
            v     = runif(1, 1, 1000),
        )
        dir.create(dir, showWarnings = F)
        fp = file.path(dir, paste0(chain,".json") )
        cmdstanr::write_stan_json(init, fp)
        fp
    })
}
set.seed(50)
m = cmdstanr::cmdstan_model("src/m3.stan")
fit = m$sample(data = dat, chains = 4, parallel_chains = 4,
               iter_warmup = 700, iter_sampling = 700,
               save_warmup = TRUE, refresh = 200,
               init = write_init_files())
fit$save_object("made/m3_fit.RDS")


Pz = precis(fit, depth=3, pars="prob")
f = glue::glue
mat_Pz = matrix(Pz$mean, nrow=dat$ns, ncol=dat$nz)
par(mfrow=c(4,5))
for (i in 1:dat$ns) {
    barplot(mat_Pz[i,], main=f('Subject {i}'))
}


