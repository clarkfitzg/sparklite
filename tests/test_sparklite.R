# Not possible to use testthat here because "manually constructed
# enviroment" passes when it should fail. 
# Unexpected things happening with closures and environments.
#
# So instead just run this script

library(sparkapi)
library(sparklite)

# TODO: hardcoded in a recent version of the library here.
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

add_ab_closure <- update_closure(add_ab, c("a", "b"))

actual <- clusterApply(sc, x, add_ab_closure)

pass["manually constructed closure"] <-
    all.equal(actual, expected)

############################################################

a <- 20
b <- 30
fmaker <- function(){
    a <- 100
    function(x) x + a + b
}
f <- fmaker()
x <- 1:3
expected <- as.list(x + a + b)
fnew <- update_closure(f, c("a", "b"))

actual <- clusterApply(sc, x, fnew)

pass["closure updates as expected"] <-
    all.equal(actual, expected)

############################################################

if (!all(pass)){
    fails <- names(pass)[!pass]
    cat("\ntest failures:\n", paste(fails, sep = "\n"))
} else{
    cat("\ntests PASS!\n")
}

stop_shell(sc)
