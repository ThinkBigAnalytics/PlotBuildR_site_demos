# Spark context

# UI function
sparkConUI <- function(id) {
  
  # Create the unique namespace for the tab
  ns <- NS(id)
  
  # Build UI
  
  fluidPage(
    fluidRow(
      radioButtons(ns("sparkChoice"), label = "Select Spark Context", choices = c("Hive", "dplyr"), inline = T)
    ),
    fluidRow(
      textAreaInput(ns("spark"), value = NULL, label = NULL,
                    placeholder = "eg. SELECT * FROM quakes LIMIT 10 (Hive table: quakes) \n \t quakes_sdf %>% head(10) (Spark table: quakes_sdf)", 
                    width = '130%', height = '40%'),
      actionButton(ns("sparkQueryButton"), "Run")
    ),
    br(),
    fluidRow(
      conditionalPanel(
        condition = sprintf("input['%s']%s == 1", ns("sparkQueryButton"), "%2"),
        tabsetPanel(
          tabPanel("Summary",
                   br(),
                   dataTableOutput(ns("tbl_spark"))
          ),
          tabPanel("Plot",
                   br(),
                   plotbuildr::plotbuildrOutput(ns("plot_spark"), status = "warning")
          )
        )
      )
    )
  )
} # end: sparkConUI()

# Server function
sparkCon <- function(input, output, session) {
  
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
  }, options = list(pageLength = 10))
  
  plotbuildr::renderPlotbuildr("plot_spark", reactive_df = reactive_list_spark, df = "df", 
                               plot_type = "Map", title = "Demo Spark Plot")
} # end: sparkCon()
