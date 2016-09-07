build_parent_env <- function(varlist, envir){
    out <- new.env
    for(name in varlist){
        assign(name, get(name, envir), out)
    }
    out
}


#' Create or update a function closure with new values
#' 
#' Adds data to a function so that it can be serialized and run on a remote
#' cluster, avoiding errors of type \code{Object not found}.
#'
#' The updating behavior means that if \code{fun} already has an
#' environment containing \code{a = 10} then running \code{a <- 20;
#' updateClosure(fun, "a")} will return a function where \code{a = 20}.
#' 
#' This function is modeled after \code{\link[parallel]{clusterExport}}.
#'
#' @param fun function with old or no environment
#' @param varlist character vector of names of objects to export.
#' @param envir environment from which to export variables
#' @return function with updated environment
#' @seealso \code{\link[parallel]{clusterExport}}
#'
#' @examples
#' # To apply f you'll need to also get it's dependencies
#' f <- makeClosure(f, c("a", "helperfunc"))
#' clusterApply(sc, 1:10, f)
#' @export
update_closure <- function(fun, varlist, envir = .GlobalEnv){
}


#' Parallelize computations using a Spark cluster
#'
#' This works by serializing x onto the worker nodes, running the
#' computation, and finally deserializing the result.
#' 
#' @param cl cluster is a Spark connection as returned from
#'      \code{\link[sparkapi]{start_shell}}
#' @param x R object that can be coerced to list
#' @param fun function to evaluate
#'
#' @return list with \code{fun} evaluated at each element of x
#'
#' @examples
#' library(sparkapi)
#' sc <- start_shell(master = "local")
#'
#' clusterApply(sc, 1:10, function(x) x + 2)
#'
#' a <- 20
#' helperfunc <- function(x) sin(x)
#' f <- function(x) helperfunc(x) + a
#' # To apply f you'll need to also get it's dependencies
#' f <- makeClosure(f, c("a", "helperfunc"))
#' clusterApply(sc, 1:10, f)
#'
#' @seealso \code{makeClosure}, \code{\link[base]{lapply}}, 
#'      \code{\link[parallel]{clusterApply}},
#'      \code{\link[parallel]{clusterExport}}, in \code{parallel} package
#' @export
clusterApply <- function(cl, x, fun, ...){

    sc <- cl
    x <- as.list(x)
    fun <- match.fun(fun)

    sparkfun <- function(partIndex, part) {
        fun(part)
    }

    packageNamesArr <- serialize(NULL, connection = NULL)

    xserial <- lapply(x, serialize, connection = NULL)

    # An RDD of the serialized R parts
    # This is class org.apache.spark.api.java.JavaRDD
    xrdd <- sparkapi::invoke_static(sc,
                "org.apache.spark.api.r.RRDD",
                "createRDDFromArray",
                sparkapi:::java_context(sc),
                xserial
                )

    # Use Spark to apply the function
    fxrdd <- sparkapi::invoke_new(sc,
                "org.apache.spark.api.r.RRDD",  # A new instance of this class
                sparkapi::invoke(xrdd, "rdd"),
                serialize(sparkfun, connection = NULL),
                "byte",     # name of serializer / deserializer
                "byte",     # name of serializer / deserializer
                packageNamesArr,
                list(),     # broadcastArr
                sparkapi::invoke(xrdd, "classTag")
                )

    # Collect and return
    rawlist = sparkapi::invoke(fxrdd, "collect")
    lapply(rawlist, unserialize)
}
