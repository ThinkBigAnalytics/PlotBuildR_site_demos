#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
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
  
  # PlotBuildR::renderPlotBuildR("plot_spark", reactive_df = reactive_list_spark, df = "df", 
  #                              plot_type = "Map", title = "Demo Spark Plot")

  
})
