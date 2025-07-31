/*
    This implementation is WRONG. I have no idea how I came up with it.
*/
functions {
    real p_understand_k(int k, vector theta) {
        /* 
            The probability that one understands the number word k, 
                given the knower level distribution 
        */
        real cum_theta = 0;
        if (k <= 5) {
            for (i in 1:k) cum_theta += theta[i];
        } else {
            for (i in 1:5) cum_theta += theta[i];
        }
        return 1 - cum_theta;
    }
}
data {
    int ns;  // num of subjects
    int nz;  // num of knower levels (1: NN, 2: one, 3: two, 4: three, 5: four, 6: CP)
    int nt;  // num of trials (max)
    int gn;  // num of categories (i.e., num of toys in the bowl)
    array[ns, nt] int gq;  // question matrix (0: missing value)
    array[ns, nt] int ga;  // answer matrix (0: missing value)
}
parameters {
    simplex[gn] Pi;               // base rate preference
    real<lower=1, upper=1000> v;  // evidence value
    array[ns] simplex[nz] theta;  // knower-level distribution for each subj
}
model {
    // Priors
    Pi ~ dirichlet(rep_vector(1,gn));
    v ~ uniform(1, 1000);
    for (i in 1:ns)
        theta[i] ~ dirichlet(rep_vector(1,nz));
    
    // model
    for (i in 1:ns) {
        for (j in 1:nt) {
            // Missing questions
            if (gq[i,j] == 0) continue;

            // Updated belief
            vector[gn] Pi2;
            for (k in 1:gn) {
                real p = p_understand_k(k, theta[i]);
                real logPi = log(Pi[k]);
                if (k == gq[i,j]) {
                    Pi2[k] = exp(log1m(p) + logPi) + exp(log(p) + log(v) + logPi);  // latent mixture
                }
                else {
                    Pi2[k] = exp(log1m(p) + logPi) + exp(log(p) - log(v) + logPi);  // latent mixture
                }
            }

            // Answer (returned number)
            ga[i,j] ~ categorical( Pi2/sum(Pi2) );
        }
    }
}
