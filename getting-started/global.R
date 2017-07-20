# Shiny app related packages
if(!require(dplyr)){install.packages('dplyr'); require(dplyr)}
if(!require(shiny)){install.packages('shiny'); require(shiny)}
if(!require(shinythemes)){install.packages('shinythemes'); require(shinythemes)}
if(!require(plotbuildr)){devtools::install_github('ThinkBigAnalytics/PlotBuildR'); require(plotbuildr)}
if(!require(gapminder)){install.packages("gapminder"); require(gapminder)}

df_list <- "gapminder"

continent_choices <- select(gapminder_unfiltered, continent) %>% 
  unique() %>% unlist(use.names = F)