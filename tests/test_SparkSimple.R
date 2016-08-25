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

fmaker <- function(){
    a <- 100
    function(x) x + a
}
f <- fmaker()
x <- 1:10
expected <- lapply(x, f)

actual <- clusterApply(sc, x, f)

pass["evaluate a closure"] <-
    all.equal(actual, expected)

############################################################

a <- 20
b <- 30
add_ab <- function(x) x + a + b
x <- 1:10
expected <- lapply(x, add_ab)

actual <- clusterApply(sc, x, add_ab, varlist = c("a", "b"))

pass["manually constructed environment"] <-
    all.equal(actual, expected)

############################################################

a <- 20
b <- 30
fmaker <- function(){
    a <- 100  # This value of a should show up
    function(x) x + a + b
}
f <- fmaker()
x <- 1:10
expected <- lapply(x, f)

actual <- clusterApply(sc, x, f, varlist = c("a", "b"))

pass["closure scoping consistent with R"] <-
    all.equal(actual, expected)

############################################################

if (!all(pass)){
    fails <- names(pass)[!pass]
    cat("\ntest failures:\n", paste(fails, sep = "\n"))
} else{
    cat("\ntests PASS!\n")
}

stop_shell(sc)
