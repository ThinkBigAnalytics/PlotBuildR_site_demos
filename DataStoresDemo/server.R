shinyServer(function(input, output, session) {

########################### CALL EACH OF THE MODULES ###########################

  callModule(mysqlCon, "tab_1")
  callModule(sparkCon, "tab_2")
  
  session$onSessionEnded(function() {
    if(!is.null(sc)) spark_disconnect(sc = sc)
    rm(list = ls())
  })

})
