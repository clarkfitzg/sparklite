# Here the "local[3]" argument means there will be 3 local workers
sc <- sparkapi::start_shell(master = "local[3]", app_name = "sparklite_demo")

library(sparklite)

# An expensive function
sim <- function(seed, n = 1000){
    set.seed(seed)
    A <- matrix(rnorm(n * n), nrow = n)
    B <- matrix(rnorm(n * n), nrow = n)
    Binv <- solve(B)
    BAB <- Binv %*% A %*% B
    tr <- function(X) sum(diag(X))
    c(trA = tr(A), trBAB = tr(BAB))
}

results <- clusterApply(sc, 1:20, sim)
