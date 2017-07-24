################################ LOAD LIBRARIES ################################

# Shiny app related packages
if(!require(dplyr)){install.package('dplyr'); require(dplyr)}
if(!require(shiny)){install.package('shiny'); require(shiny)}
if(!require(shinydashboard)){install.package('shinydashboard'); require(shinydashboard)}
if(!require(plotbuildr)){devtools::install_github('ThinkBigAnalytics/PlotBuildR'); require(plotbuildr)}

# Packages to connect with databases
if(!require(sparklyr)) {install.packages('sparklyr'); require(sparklyr)}
if(!require(DBI)) {install.packages('DBI'); require(DBI)}
if(!require(RMySQL)) {install.packages('RMySQL'); require(RMySQL)}
if(!require(xml2)) {install.packages('xml2'); require(xml2)}

################################# LOAD MODULES #################################

my_modules <- list.files("tabs", pattern = "tab_module.R", full.names = TRUE,
                         recursive = TRUE)

for(my_module in my_modules) source(my_module)


Sys.setenv(SPARK_HOME='/usr/hdp/current/spark2-client')
Sys.setenv(SPARK_MASTER_IP = "data-lab.io")
sc_flag <- 0
sc <- NULL
quakes_sdf <- NULL

