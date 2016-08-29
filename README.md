# sparklite

Lightweight R package to use an [Apache Spark](http://spark.apache.org/)
cluster for parallel computation

__ATTENTION: This package should be considered as an experimental beta
version only. I have yet to test it on a real cluster :)__

Please see [SparkR](https://spark.apache.org/docs/latest/sparkr.html) for
the official Apache supported Spark / R interface.

## Motivation

The goal of this package is to enable distributed computation in Spark from
R through the __simplest__ possible interface, using a minimum amount of
code. It can therefore be considered a direct translation of the
Java class
[org.apache.spark.api.r.RRDD](https://spark.apache.org/docs/latest/api/java/index.html).

This would be useful for users who would like to use Spark and R for
heavy computation in embarrassingly parallel problems. In particular we
expect it to work well for applications that require very little
serialization, such as simulation.

The official SparkR package is useful if you'd like to use more of the native capabilities in
Spark. However, at around 30K lines of R code it's much more complex.

```
# Line count:
~/dev/spark/R $ find . -name "*.R" | xargs wc -l | tail -n 1
   27895 total
```

Whenever possible we emulate the API of functions from R's included `parallel`
package.
