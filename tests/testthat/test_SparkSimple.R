library(sparkapi)

if(!exists("sc")){
    sc <- start_shell(master = "local")
}

############################################################

test_that("clusterApply on numeric vector", {

    x <- 1:10
    add2 <- function(x) x + 2
    expected <- lapply(x, add2)
    actual <- clusterApply(sc, x, add2)

    expect_equal(actual, expected)

})
