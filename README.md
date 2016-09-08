# sparklite

Lightweight R package to use an [Apache Spark](http://spark.apache.org/)
cluster for parallel computation

__ATTENTION: This package should be considered as an experimental beta
version only. I have yet to test it on a real cluster :)__

Please see [SparkR](https://spark.apache.org/docs/latest/sparkr.html) for
the official Apache supported Spark / R interface.

This project initially came out of an attempt to connect
Spark to the more general [ddR project](https://github.com/vertica/ddR)
(distributed data in R).  Work supported by
[R-Consortium](https://www.r-consortium.org/projects).

## Example

Suppose we want to check how well [similar
invariance](https://en.wikipedia.org/wiki/Similarity_invariance) of the
trace holds numerically for random matrices.

This is useful for demonstration because this is an expensive function taking
between O(n^2) and O(n^3) operations. Push the heavy computation to
the cluster.

Note that this is the naive way to set random seeds. For more sophisticated
uses see the `rsprng` and `rlecuyer` packages.

```

# Here the "local[3]" argument means there will be 3 local workers
sc <- sparkapi::start_shell(master = "local[3]", app_name = "sparklite_demo")

library(sparklite)

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

sparkapi::stop_shell(sc)

```

The web UI to watch a local Spark job progress is here by default:
`http://localhost:4040/jobs/`

## Motivation

The goal of this package is to enable distributed computation in Spark from
R through the __simplest__ possible interface, using a minimum amount of
code. It can therefore be considered a direct translation of the
Java class
[org.apache.spark.api.r.RRDD](https://spark.apache.org/docs/latest/api/java/index.html).
This would be useful for users who would like to use Spark and R for
heavy computation in embarrassingly parallel problems such as simulation.

Whenever possible we emulate the API of functions from R's excellent
included `parallel` package, since we're doing exactly the same thing with
a Spark cluster instead of `SNOW` clusters.

The official SparkR package is useful if you'd like to use more of the native capabilities in
Spark. However, at around 30K lines of R code it's much more complex.

```
# Line count:
~/dev/spark/R $ find . -name "*.R" | xargs wc -l | tail -n 1
   27895 total
```

## Example with real data

```
# 22 MB dataset
df <- read.csv("~/data/nycflights13.csv")

# I imagine that tuning this matters:
N <- 5
splits <- sort(rep(1:N, length.out = nrow(df)))

# The elements of this list will be serialized into Spark
dflist <- split(df, splits)

# Function to apply
linmod <- function(d){
    fit <- lm(arr_delay ~ year + month, data = d)
    confint(fit)
}

# Apply it over the data in chunks
results <- clusterApply(sc, dflist, linmod)
```
