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
m = cmdstanr::cmdstan_model("src/m2.stan")
fit = m$sample(data = dat, chains = 4, parallel_chains = 4,
               iter_warmup = 700, iter_sampling = 700,
               save_warmup = TRUE, refresh = 200,
               init = write_init_files())
fit$save_object("made/m2_fit.RDS")


######## Check Model #########
library(stom)
fit = readRDS("made/m2_fit.RDS")
ds = precis(fit, pars="Pi,v,Pz", depth=3)
plot(ds$rhat)

f = glue::glue
# Viz posterior knower levels 
Pz = fit$draws("Pz")
post = matrix(nrow=dim(Pz)[1]*dim(Pz)[2], ncol=dim(Pz)[3])
for (k in 1:120)
    post[,k] = c(Pz[,,k])
post_Pz = matrix(0, nrow=dat$ns, ncol=dat$nz)
for (i in 1:nrow(post)) 
    post_Pz = post_Pz + matrix(post[i,], nrow=dat$ns, ncol=dat$nz)
post_Pz = post_Pz / nrow(post)

f = glue::glue

pdf("made/base-rate.pdf", width=10, height=4)
# Base rate plot
par(mfrow=c(1,1))
Pi = precis(fit, pars="Pi")
barplot(Pi$mean, 
        names.arg=1:15, xlab="Number of toys returned", ylab="Probability",
        main=expression(
            paste("Posterior of the Base Rate (", pi, ") parameter")
        ),
        ylim=c(0,.6)
)
dev.off()

pdf("made/knower-levels.pdf", width=10.5, height=7)
# Knower level posterior
Pz = precis(fit, depth=3, pars="Pz")
mat_Pz = matrix(Pz$mean, nrow=dat$ns, ncol=dat$nz)
par(mfrow=c(4,5))
for (i in 1:dat$ns) {
    barplot(mat_Pz[i,], main=f('Child {i}'), ylim=c(0,1),
            names.arg=c("PN", 1:4, "CP"), las=1)
}
dev.off()