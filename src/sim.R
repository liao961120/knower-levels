set.seed(9999)

ns = 20
nz = 6   # 1: NN, 2: one, 3: two, 4: three, 5: four, 6: CP
nt = 21  # number of trials
gn = 15  # number of categories (toys in the bowl)
# questions asked
gq  = sapply(1:ns, \(s) {
    qs = rep(c(1:5, 8, 10), each=3)
    # Simulate random missing values
    n_mis = sample(0:3, 1, prob=c(.8, .2/3, .2/3, .2/3))
    idx_mis = sample(1:length(qs), n_mis)
    qs[idx_mis] = 0
    qs
}) |> t()

UNDERSTANDS = function(k, z) {
    # Checking
    if (!z %in% 1:6)
        stop("z must be one of 1~6")
    if (!k > 0)
        stop("k must be a positive integer")
    
    # NN-knower
    if (z == 1) return(FALSE)
    # CP-knower
    if (z == 6) return(TRUE)
    # one~four-knower
    # (e.g., two-knower: z=3 understands k=1&2)
    if (k < z) return(TRUE)
    return(FALSE)
}

# Parameters
Pi = c(6, rep(3,3), rep(1,10), 6)
Pi = Pi / sum(Pi)    # base rate
pi2_rec = vector("list", length=gn)
v  = 100             # evidence value
z = rep(1:6, length=ns) |> sort()  # knower-levels
# Answers (numbers returned)
ga = sapply(1:ns, \(i) {
    qs = gq[i, ]
    sapply(qs, \(q) {
        # Missing questions
        if (q == 0) {
            return(0)            
        } 
        # Observed questions
        else {
            # Updated belief distribution
            pi2 = Pi
            for (k in 1:gn) {
                # Does not understand the category k
                if (!UNDERSTANDS(k, z[i])) {
                    pi2[k] = Pi[k]
                } 
                # Understands the category k
                else {
                    if (k == q) {
                        pi2[k] = v * Pi[k]
                    } else {
                        pi2[k] = (1/v) * Pi[k]
                    }
                }
                
            }
            # Normalize updated belief
            pi2 = pi2 / sum(pi2)
            # Generate an answer based on pi2
            a = sample(1:gn, 1, prob=pi2)
            # if (q == 3 & a != 3)
            #     pi2_rec[[i]] <<- pi2
            a
        }
    })
}) |> t()


dat = list(
    # Data
    ns = ns,
    nz = nz,
    nt = nt,
    gn = gn,
    gq = gq,
    ga = ga,
    # Parameters
    Pi = Pi,
    v  = v,
    z  = z
)
saveRDS(dat, "made/sim.RDS")
