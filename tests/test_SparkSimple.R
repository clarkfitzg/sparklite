# Not possible to use testthat here because "manually constructed
# enviroment" passes when it should fail. 
# Unexpected things happening with closures and environments.

library(sparkapi)
library(SparkSimple)

if(!exists("sc")){
    sc <- start_shell(master = "local", 
            spark_home = "/Users/clark/Library/Caches/spark/spark-2.0.0-preview-bin-hadoop2.6/")
}

pass = vector()

############################################################

x <- 1:10
add2 <- function(x) x + 2
expected <- lapply(x, add2)
actual <- clusterApply(sc, x, add2)

pass["basic operation on numeric vector"] <- 
    all.equal(expected, actual)

############################################################

 g <- 100
 x <- 1:10
 addg <- function(x) x + g
 expected <- lapply(x, addg)
 actual <- clusterApply(sc, x, addg)

pass["manually constructed environment"] <-
    all.equal(actual, expected)

############################################################

if (!all(pass)){
    fails <- names(pass)[!pass]
    print("test failures:\n", paste(fails, sep = "\n"))
} else{
    print("tests PASS!")
}

stop_shell(sc)
