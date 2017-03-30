renderLeafletsource("global.R")

ui <- fluidPage(
  br(),
  br(),
  textAreaInput("q1", "Enter the SQL Query:", 'SELECT * FROM City LIMIT 100',width = '100%', '30%' ),
  actionButton("runquery", "Run"),
  #uiOutput("panels")
  br(),
  br(),
  
  tabsetPanel(
    tabPanel("Summary",dataTableOutput("tbl")),
    tabPanel("Plot", PlotBuildR::generatePlotUI("plot1"))
  )
)

server <- function(input, output, session) {
  
  query1 <- reactiveValues(data = NULL)
  
  query1$data <- reactive({
    input$runquery
    selected_query <- isolate(input$q1)
  })
  
  data <- reactive({
    conn <- dbConnect(
      drv = RMySQL::MySQL(),
      dbname = "shinydemo",
      host = "shiny-demo.csa7qlmguqrf.us-east-1.rds.amazonaws.com",
      username = "guest",
      password = "guest")
    on.exit(dbDisconnect(conn), add = TRUE)
    dbGetQuery(conn, paste0(query1$data()))
  })
  
  reactive_list <- list()
  reactive_list$df <- reactive({data()})
  
  output$tbl <- renderDataTable({data()})
  callModule(generatePlot, "plot1", df_list = df_list, reactive_df = reactive_list, 
             df = "df", title = "Demo SQL Plot")
  
  # observeEvent(input$runquery,{
  #   output$panels=renderUI({
  #   tabsetPanel(
  #     tabPanel("Summary",dataTableOutput("tbl")),
  #     tabPanel("Plot", PlotBuildR::generatePlotUI("plot1"))
  #   )
  #   })
  # })
}

shinyApp(ui, server)