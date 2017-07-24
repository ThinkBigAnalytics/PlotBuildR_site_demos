############################## CREATE THE SIDEBAR ##############################
sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("MySQL Context",      tabName = "Tab1", icon = icon("database")),
    menuItem("Spark Context",      tabName = "Tab2", icon = icon("database"))
  ),

  # Logo in sidebar menu
  div(style = "position: fixed; bottom: 35px; left: 35px;",
      img(src = 'tb_images/tb_logo.png', width = 197)
  )
)

############################### CREATE THE BODY ################################
body <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "AdminLTE.min.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "_all-skins.min.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "skin-yellow.min.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
  ),

  # Write the UI reference of the modules
  tabItems(
    #tabItem(tabName = "Tab0", tab_0_ui("tab_0")),
    tabItem(tabName = "Tab1", mysqlConUI("tab_1")),
    tabItem(tabName = "Tab2", sparkConUI("tab_2"))
  )
)

#################### PUT THEM TOGETHER INTO A DASHBOARDPAGE ####################
dashboardPage(skin = "yellow",
  dashboardHeader(title = "Database Demo"),
  sidebar,
  body
)
