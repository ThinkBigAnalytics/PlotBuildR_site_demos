source("global.R")
library(shiny)

ui <- navbarPage(
  title = "PlotBuildR",
  tabPanel(
    "MySQL Context",
    fluidPage(
      fluidRow(
        textAreaInput("mysql", "Enter the SQL Query:", 'SELECT * FROM City LIMIT 100',width = '100%', '30%'),
        actionButton("sqlQueryButton", "Run")
      ),
      br(),
      fluidRow(
        tabsetPanel(
          tabPanel("Summary",
                   br(),
                   dataTableOutput("tbl")
          ),
          tabPanel("Plot",
                   PlotBuildR::plotBuildROutput("plot1")
          )
        )
      )
    )
  ),
  tabPanel(
    "Spark Context",
    fluidPage(
      fluidRow(
        radioButtons("sparkChoice", label = "Select Spark Context", choices = c("Hive", "dplyr"), inline = T)
      ),
      fluidRow(
        textAreaInput("spark", value = NULL, width = '100%', '30%'),
        actionButton("sparkQueryButton", "Run")
      ),
      br(),
      fluidRow(
        tabsetPanel(
          tabPanel("Summary",
                   br(),
                   #verbatimTextOutput("print1")
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

server <- function(input, output, session) {
  
  ## MYSQL ####
  
  mysql_query <- eventReactive(input$sqlQueryButton, {
    selected_query <- isolate(input$mysql)
  })
  
  mysql_data <- reactive({
    conn <- dbConnect(
      drv = RMySQL::MySQL(),
      dbname = "shinydemo",
      host = "shiny-demo.csa7qlmguqrf.us-east-1.rds.amazonaws.com",
      username = "guest",
      password = "guest")
    on.exit(dbDisconnect(conn), add = TRUE)
    dbGetQuery(conn, paste0(mysql_query()))
  })
  
  reactive_list_mysql <- list()
  reactive_list_mysql$df <- reactive({mysql_data()})
  
  output$tbl <- renderDataTable({mysql_data()})
  PlotBuildR::renderPlotBuildR("plot1", reactive_df = reactive_list_mysql, 
                               df = "df", plot_type = "Bar Plot", title = "Demo SQL Plot")
  
  
  ## Spark ####
  
  sparkChoiceSelected <- reactive({
    input$sparkChoice
  })
  
  observe({
    validate(need(input$sparkChoice, F))
    
    switch(sparkChoiceSelected(),
           "Hive" = updateTextAreaInput(session, "spark", label = "Enter the Hive Query:", value = 'SELECT * FROM quakes_geo LIMIT 10'),
           "dplyr" = updateTextAreaInput(session, "spark", label = "Enter the dplyr operation", value = 'quakes_geo_sdf %>% head(10)')
    )
  })
  
  spark_query <- eventReactive(input$sparkQueryButton, {
    selected_query <- isolate(input$spark)
  })
  
  output$print1 <- renderText({
    spark_query()
  })
  
  spark_data <- reactive({
    switch(sparkChoiceSelected(),
           "Hive" = {
             dbGetQuery(sc, spark_query())
           },
           "dplyr" = {
             eval(parse(text = spark_query()))
           }
    )
  })
  
  reactive_list_spark <- list()
  reactive_list_spark$df <- reactive({
    spark_data() %>% collect
  })
  
  output$tbl_spark <- renderDataTable({
    spark_data()
  })
  
  PlotBuildR::renderPlotBuildR("plot_spark", reactive_df = reactive_list_spark, df = df, plot_type = "Map")
  
}

shinyApp(ui, server)