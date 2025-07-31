functions {
    int understands(int z, int k) {
        /* 
            Whether a child with knower level z understands a number k.
                z: knower level (1: PN, 2: one, 3: two, 4: three, 5: four, 6: CP)
                k: Number
        */
        if (z == 1) return 0;
        if (z == 6) return 1;
        if ((z-1) >= k) return 1;
        return 0;
    }
}
data {
    int ns;  // num of children
    int nt;  // max num of trials
    int nz;  // num of knower levels (1: PN, 2: one, 3: two, 4: three, 5: four, 6: CP)
    int gn;  // num of categories (i.e., num of toys in the bowl)
    array[ns, nt] int gq;  // question matrix (0: missing value)
    array[ns, nt] int ga;  // answer matrix (0: missing value)
}
parameters {
    simplex[gn] Pi;               // base rate preference
    real<lower=1, upper=1000> v;  // evidence value
}
transformed parameters {
    /* 
        Variable holding the unaggregated marginalized log likelihood, 
          under all possible z (knower-level) states
    */
    array[ns] vector[nz] logM;
    {   
        /*
            piprime holds the enumeration of all potential states for the 
            updated belief distribution
        */ 

        // piprime Loop
        array[nz, gn] vector[gn] piprime;
        for (z in 1:nz) {
            for (q in 1:gn) {
                for (k in 1:gn) {
                    // k > z (doesn't understand)
                    if (!understands(z, k))
                        piprime[z,q,k] = Pi[k];
                    // k <= z (understands)
                    else {
                        if (q == k)
                            piprime[z,q,k] = Pi[k] * v;
                        else
                            piprime[z,q,k] = Pi[k] / v;
                    }
                }
                // Normalize piprime
                piprime[z,q,] = piprime[z,q,] / sum(piprime[z,q,]);
            }
        }

        // logM Loop
        for (i in 1:ns) {
            for (z in 1:nz) {
                logM[i,z] = log(1.0/nz);  // Prior of knower level
                // Independent trials (question-answer pairs)
                for (j in 1:nt) {
                    int q = gq[i,j];
                    int a = ga[i,j];
                    // Missing value (does not add information)
                    if (q == 0)
                        logM[i,z] += 0;
                    else
                        logM[i,z] += categorical_lpmf(a | piprime[z,q,]);
                }
            }
        }

    }
}
model {
    /*
        Note about the Dirichlet prior for Pi:
            The model on p. 238 in Bayesian Cognitive Modeling specifies the 
            prior of Pi as a Dirichlet distribution. However, in the WinBugs
            implementation (the "Base rate" section on p.240), Pi was actually 
            modeled as a vector of 15 independent flat Beta distributions 
            (i.e., dunif(0,1)), normalized to sum to one. This resulted in
            the posterior from m2.stan being different from that obtained 
            from m3.stan (translation of the WinBugs implementation in Stan). 
            The major conclusions about the knower-level inference does not 
            differ drastically, but there are noticible differences in the
            posterior of the knower levels.
    */
    Pi ~ dirichlet(rep_vector(1,gn));
    v ~ uniform(1, 1000);
    for (i in 1:ns) {
        target += log_sum_exp(logM[i,]);
    }
}
generated quantities {
    // Recover latent z
    array[ns] vector[nz] Pz;
    for (i in 1:ns)
        Pz[i] = softmax(logM[i,]);
}
