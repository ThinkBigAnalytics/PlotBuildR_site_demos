source("global.R")

#library(shiny)

ui <- navbarPage(
  title = "plotbuildr",
  tabPanel(
    "MySQL Context",
    fluidPage(
      fluidRow(
        textAreaInput("mysql", "Enter the SQL Query:", 'SELECT * FROM City LIMIT 100',width = '100%', '40%'),
        actionButton("sqlQueryButton", "Run")
      ),
      br(),
      fluidRow(
        conditionalPanel(
          condition = "input.sqlQueryButton%2 == 1",
          tabsetPanel(
            tabPanel("Summary",
                     br(),
                     dataTableOutput("tbl_sql")
            ),
            tabPanel("Plot",
                     plotbuildr::plotbuildrOutput("plot_sql")
            )
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
                     plotbuildr::plotbuildrOutput("plot_spark")
            )
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
  
  output$tbl_sql <- renderDataTable({mysql_data()})
  
  plotbuildr::renderPlotbuildr("plot_sql", reactive_df = reactive_list_mysql,
                               df = "df", plot_type = "Bar Plot", title = "Demo SQL Plot")
  
  ## Spark ####
  
  sparkChoiceSelected <- reactive({
    input$sparkChoice
  })
  
  observe({
    validate(need(input$sparkChoice, F))
    
    switch(sparkChoiceSelected(),
           "Hive" = updateTextAreaInput(session, "spark", label = "Enter a Hive Query:", value = ""),# placeholder = 'SELECT * FROM quakes LIMIT 10'),
           "dplyr" = updateTextAreaInput(session, "spark", label = "Enter a dplyr Operation:", value = "")#, placeholder = 'quakes_sdf %>% head(10)')
    )
  })
  
  spark_query <- eventReactive(input$sparkQueryButton, {
    selected_query <- isolate(input$spark)
  })
  
  output$print1 <- renderText({
    dbGetQuery(sc, "show tables") %>% unlist(use.names = F)
  })
  
  spark_data <- eventReactive(input$sparkQueryButton, {
    progress <- shiny::Progress$new()
    # Make sure it closes when we exit this reactive, even if there's an error
    on.exit(progress$close())
    
    progress$set(message = "Establishing Spark Context", value = 0)
    
    # Increment the progress bar, and update the detail text.
    progress$inc(8, detail = "Connecting to spark")
    sc <<- spark_connect(master = "yarn-client", config = spark_config())
    
    if(sc_flag == 0){
      sc_flag <<- 1
      progress$inc(50, detail = "Using database quakesdb")
      # Pause for 0.1 seconds to simulate a long computation.
      Sys.sleep(0.1)
      dbGetQuery(sc, "USE quakesdb")
      progress$inc(10, detail = "Registering quakes table in spark")
      # Pause for 0.1 seconds to simulate a long computation.
      Sys.sleep(0.1)
      quakes_sdf <<- tbl(sc, "quakes") %>% sdf_register()
      progress$inc(32, detail = "Fin")
    }
    
    spark_df <- switch(sparkChoiceSelected(),
                       "Hive" = {
                         dbGetQuery(sc, spark_query())
                       },
                       "dplyr" = {
                         eval(parse(text = spark_query()))
                       }
    )
    
    r_df <- spark_df %>% collect()
    
    return(r_df)
  })
  
  reactive_list_spark <- list()
  reactive_list_spark$df <- reactive({
    spark_data()
  })
  
  output$tbl_spark <- renderDataTable({
    spark_data()
  })
  
  plotbuildr::renderPlotbuildr("plot_spark", reactive_df = reactive_list_spark, df = "df", 
                               plot_type = "Map", title = "Demo Spark Plot")
  
  session$onSessionEnded(function() {
    if(!is.null(sc)) spark_disconnect(sc = sc)
    rm(list = ls())
  })
}

shinyApp(ui, server)