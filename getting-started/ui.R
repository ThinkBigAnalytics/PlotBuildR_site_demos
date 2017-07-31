library(shiny)


ui <- fluidPage({
  titlePanel("Getting Started with plotbuildr", windowTitle = "plotbuildr")
},{
  fluidRow({
    column(
      width = 12,
      wellPanel({
        bootstrapPage({
          div(
            style = "display:inline-block; vertical-align:top;",
            selectInput(
              inputId = "continent", label = "Select a Continent", 
              choices = continent_choices, selected = continent_choices[1], 
              width = "160px")
          )
        },{
          shiny::div(
            style="display: inline-block; vertical-align:top; width: 10px;",
            HTML("<br>"))
        },{
          div(
            style = "display:inline-block; vertical-align:top;",
            sliderInput(
              inputId = "year", label = "Select a Year", min = 1952L, dragRange = T,
              max = 2007L, value = c(1987L, 2007L), step = 5L, width = "180px")
          )
        })
      },{
        selectInput(
          inputId = "country", label = "Select Country(s)", 
          choices = NULL, multiple = T)
      },{
        actionButton(inputId = "go", label = "Apply", width = "80px")
      }, style = "display:inline-block")
    )
  })
},{
  conditionalPanel(
    condition = "input.go >= 1",
  tabsetPanel({
    tabPanel(
      title = "Table", 
      br(),
      fluidRow(
        column(
          width = 10,
          dataTableOutput("table")
        )
      )
    )
  }, {
    tabPanel(
      title = "Plot", 
      fluidRow(
        plotbuildr::plotbuildrOutput("plot", col_width = 10)
      )
    )
  }, type = "pills"))
})
