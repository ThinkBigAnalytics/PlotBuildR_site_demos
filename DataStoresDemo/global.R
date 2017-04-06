if(!require(devtools)) {install.packages("devtools", dependencies = TRUE);require(devtools)}
if(!require(shiny)) {devtools::install_github("rstudio/shiny");require(shiny)}
if(!require(shinydashboard)) {install.packages("shinydashboard", dependencies = TRUE);require(shinydashboard)}
if(!require(shinyjs)) {install.packages("shinyjs", dependencies = TRUE);require(shinyjs)}
if(!require(shinyBS)) {devtools::install_github("ebailey78/shinyBS", ref = "shinyBS3");require(shinyBS)}
if(!require(shinythemes)) {install.packages("shinythemes", dependencies = TRUE);require(shinythemes)}
if(!require(plotly)) {install.packages("plotly");require(plotly)}
if(!require(plyr)) {install.packages("plyr", dependencies = TRUE);require(plyr)}
if(!require(dplyr)) {install.packages("dplyr");require(dplyr)}
if(!require(tidyr)) {install.packages("tidyr", dependencies = TRUE);require(tidyr)}
if(!require(stringr)) {install.packages("stringr", dependencies = TRUE);require(stringr)}
if(!require(networkD3)) {install.packages("networkD3", dependencies = TRUE);require(networkD3)}
if(!require(leaflet)) {install.packages("leaflet", dependencies = TRUE);require(leaflet)}
if(!require(parcoords)) {devtools::install_github("timelyportfolio/parcoords");require(parcoords)}
if(!require(fasttime)) {install.packages("fasttime", dependencies = TRUE);require(fasttime)}
if(!require(lubridate)) {install.packages("lubridate", dependencies = TRUE);require(lubridate)}
options(lubridate.fasttime = TRUE)
if(!require(PlotBuildR)){install_github('ThinkBigAnalytics/PlotBuildR', auth_token='acf4f5f2e1fe3cb2e07ef81991bc4fd4773dc5d2'); require(PlotBuildR)}
library(DBI)
if(!require(RMySQL)) {install.packages('RMySQL', dependencies = TRUE); require(PlotBuildR)}
if(!require(sparklyr)) {install.packages('sparklyr', dependencies = TRUE); require(sparklyr)}
if(!require(xml2)) {install.packages('xml2', dependencies = TRUE); require(xml2)}

Sys.setenv(SPARK_HOME='/usr/hdp/current/spark-client')
Sys.setenv(SPARK_MASTER_IP = "data-lab.io")
sc <- spark_connect(master = "yarn-client", config = spark_config())

dbGetQuery(sc, "USE quakesdb")
dbGetQuery(sc, "LOAD DATA INPATH '/user/nd186031/quakes.csv' INTO TABLE quakes_geo") #path: /user/nd186031/quakes.csv

quakes_geo_sdf <- tbl(sc, "quakes_geo") %>% sdf_register()
