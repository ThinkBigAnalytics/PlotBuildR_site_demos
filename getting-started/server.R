library(shiny)

server <- function(input, output, session){
  
  continent_selected <- reactive({ input$continent })
  
  country_list <- reactive({
    gapminder %>% 
      filter(continent == continent_selected()) %>% 
      distinct(as.character(country)) %>% 
      unlist(use.names = F)
  })
  
  observe({
    updateSelectInput(
      session, inputId = "country", choices = country_list(), 
      selected = sample(country_list(), size = 5, replace = FALSE))
  })
  
  year_range <- reactive({ input$year})
  
  rdf_list <- list()
  
  rdf_list$gapminder_filtered <- eventReactive(input$go,{
    gapminder %>% 
      mutate(country = as.character(country)) %>% 
      filter(country %in% input$country, 
             between(year, year_range()[1], year_range()[2])) %>% 
      group_by(country) %>% 
      summarise_at(.vars = vars(lifeExp:gdpPercap), 
                   .funs = function(x){mean(x) %>% round(2)})
  })
  
  output$table <- renderDataTable({
    req(input$country)
    rdf_list$gapminder_filtered()
  }, options = list(pageLength = 10))
  
  renderPlotbuildr(
    id = "plot", reactive_df = rdf_list, df = "gapminder_filtered", 
    plot_type = "Scatter Plot", x = "lifeExp", y = "gdpPercap", 
    color = "country", size = "pop", 
    title = "Average Life Expectency vs GDP per Capita"
  )
}