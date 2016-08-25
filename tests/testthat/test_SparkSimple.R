library(sparkapi)

if(!exists("sc")){
    sc <- start_shell(master = "local", 
            spark_home = "/Users/clark/Library/Caches/spark/spark-2.0.0-preview-bin-hadoop2.6/")
}

############################################################

test_that("clusterApply on numeric vector", {

    x <- 1:10
    add2 <- function(x) x + 2
    expected <- lapply(x, add2)
    actual <- clusterApply(sc, x, add2)

    expect_equal(actual, expected)

})



############################################################

stop_shell(sc)
