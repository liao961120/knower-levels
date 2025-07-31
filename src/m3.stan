/*
    This is an updated Stan translation of the WinBUGS implementation. 
    The original Stan code (with older syntax) by Martin Smira can be found at: 
    https://github.com/stan-dev/example-models/blob/master/Bayesian_Cognitive_Modeling/CaseStudies/NumberConcepts/NumberConcept_1_Stan.R
*/

// Knower Level Model Applied to Give-N Data
data { 
    int<lower=1> ns;
    int<lower=1> nz;
    int<lower=1> gn;
    array[ns] int gnq;
    array[ns,21] int gq;  // no. columns = max(gnq)
    array[ns,21] int ga;  // no. columns = max(gnq)
}
parameters {
    vector<lower=0,upper=1>[gn] pitmp;  // See m2.stan: Dirichlet prior
    real<lower=1,upper=1000> v;
} 
transformed parameters {
    simplex[gn] Pi = pitmp / sum(pitmp);  // See m2.stan: Dirichlet prior
    array[nz, gn] vector[gn] npiprime;
    array[ns, nz] real lp_parts;
    
    // Model
    for (i in 1:nz) {
        for (j in 1:gn) {
            vector[gn] piprime;
            for (k in 1:gn) {
                real ind1;
                real ind2;
                real ind3;
                real ind4;
                real ind5;
                
                // Will be 1 if Knower-Level (i.e, i-1) is Same or Greater than Answer
                ind1 = step((i - 1) - k);
                // Will be 1 for the Possible Answer that Matches the Question
                ind2 = k == j;
                // Will be 1 for 0-Knowers
                ind3 = i == 1;
                // Will be 1 for CP-Knowers
                ind4 = i == nz;
                ind5 = ind3 + ind4 * (2 + ind2) 
                + (1 - ind4) * (1 - ind3) * (ind1 * ind2 + ind1 + 1);
                
                if (ind5 == 1)
                    piprime[k] = Pi[k];
                else if (ind5 == 2)  
                    piprime[k] = 1 / v * Pi[k];
                else if (ind5 == 3)  
                    piprime[k] = v * Pi[k];
            }  
            for (k in 1:gn)
                npiprime[i,j,k] = piprime[k] / sum(piprime);
        }
    }
    
    for (i in 1:ns) {
        for (m in 1:nz) {
            real lp_parts_tmp;
            lp_parts_tmp = 0;
            
            // Probability a z[i]-Knower Will Answer ga[i,j] to Question gq[i,j]
            // is a Categorical Draw From Their Distribution over the 1:gn Toys
            for (j in 1:gnq[i])
                lp_parts_tmp = lp_parts_tmp + categorical_lpmf(ga[i,j] | npiprime[m,gq[i,j]]);
            
            lp_parts[i,m] = log(1.0 / nz) + lp_parts_tmp;
        }  
    }
}
model {
    for (i in 1:ns)
        target += log_sum_exp(lp_parts[i]);
}
generated quantities {
    array[ns] vector[nz] prob;
    array[ns] int z;
    array[ns,gn] int predga;
    array[nz,gn] int predz;
    int predpi;
    
    for (i in 1:ns) {
        prob[i] = softmax(to_vector(lp_parts[i,]));
        z[i] = categorical_rng(prob[i]);
    }
    
    // Posterior Predictive
    for (i in 1:ns)
        for (j in 1:gn)
            predga[i,j] = categorical_rng(npiprime[z[i],j]);
    
    // Posterior Prediction For Knower Levels
    for (i in 1:nz)
        for (j in 1:gn)
            predz[i,j] = categorical_rng(npiprime[i,j]);
    
    predpi = categorical_rng(Pi);
}
