#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- navbarPage(
  title = "PlotBuildR",
  tabPanel(
    "Spark Context",
    fluidPage(
      fluidRow(
        radioButtons("sparkChoice", label = "Select Spark Context", choices = c("Hive", "dplyr"), inline = T)
      ),
      fluidRow(
        textAreaInput("spark", value = NULL, 
                      placeholder = "eg. SELECT * FROM quakes LIMIT 10 (Hive table: quakes) \n \t quakes_sdf %>% head(10) (Spark table: quakes_sdf)", 
                      width = '130%', '40%'),
        actionButton("sparkQueryButton", "Run")
      ),
      br(),
      fluidRow(
        conditionalPanel(
          condition = "input.sparkQueryButton%2 == 1",
          tabsetPanel(
            tabPanel("Summary",
                     br(),
                     dataTableOutput("tbl_spark")
            ),
            tabPanel("Plot",
                     PlotBuildR::plotBuildROutput("plot_spark")
            )
          )
        )
      )
    )
  )
)
