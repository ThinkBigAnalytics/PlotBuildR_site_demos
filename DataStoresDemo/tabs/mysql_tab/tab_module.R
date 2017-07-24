# MySQL context

# UI function
mysqlConUI <- function(id) {

  # Create the unique namespace for the tab
  ns <- NS(id)

  # Build UI

  fluidPage(
    fluidRow(
      textAreaInput(ns("mysql"), label = "Enter the SQL Query:", 
                    'SELECT * FROM City LIMIT 100', width = '100%', height = '40%'),
      actionButton(ns("sqlQueryButton"), "Run")
    ),
    br(),
    fluidRow(
      conditionalPanel(
        condition = sprintf("input['%s'] >= 1", ns("sqlQueryButton")),
        tabsetPanel(
          tabPanel("Summary",
                   br(),
                   dataTableOutput(ns("tbl_sql"))
          ),
          tabPanel("Plot",
                   br(),
                   plotbuildr::plotbuildrOutput(ns("plot_sql"), status = "warning", solidHeader = T)
          )
        )
      )
    )
  )

} # end: tab_2_ui()

# Server function
mysqlCon <- function(input, output, session) {

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
  
  output$tbl_sql <- renderDataTable({mysql_data()}, options = list(pageLength = 10))
  
  plotbuildr::renderPlotbuildr("plot_sql", reactive_df = reactive_list_mysql,
                               df = "df", plot_type = "Bar Plot", title = "Demo SQL Plot")

} # end: mysql_con()
