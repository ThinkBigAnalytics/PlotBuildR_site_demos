
# Shiny app related packages
if(!require(dplyr)){devtools::install_github('tidyverse/dplyr'); require(dplyr)}
if(!require(shiny)){devtools::install_github('rstudio/shiny'); require(shiny)}
if(!require(plotbuildr)){devtools::install_github('ThinkBigAnalytics/PlotBuildR'); require(plotbuildr)}

# Packages to connect with databases
if(!require(sparklyr)) {install.packages('sparklyr'); require(sparklyr)}
if(!require(DBI)) {install.packages('DBI'); require(DBI)}
if(!require(RMySQL)) {install.packages('RMySQL'); require(RMySQL)}
if(!require(xml2)) {install.packages('xml2'); require(xml2)}

Sys.setenv(SPARK_HOME='/usr/hdp/current/spark2-client')
Sys.setenv(SPARK_MASTER_IP = "data-lab.io")
sc_flag <- 0
sc <- NULL
quakes_sdf <- NULL