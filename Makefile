all:
	R -q -e "roxygen2::roxygenize(clean=TRUE)"
	R CMD INSTALL .

check:
	R CMD CHECK .

test:
	R CMD INSTALL .
	Rscript tests/test_sparklite.R

clean:
	rm tests/testthat/log4j.spark.log*
	rm -r ..Rcheck
	rm man/*
