refresh_data_ui <- function(id){
  ns <- NS(id)
  uiOutput(ns('manualRefreshUI'))
}

refresh_data_server <- function(id){
  moduleServer(id,
    function(input, output, session){
      ns <- session$ns
      con <- createConnection()
      output$manualRefreshUI <- renderUI({
        lastDate <- getLastDate(con)
        tagList(
          h6('Last time refreshed: ', lastDate, '.'),
          h6(
            'To refresh the app with the latest data click the button below. This might take a few seconds.'
          ),
          actionButton(ns('manualRefresh'), 'Refresh Data')
        )
      })
      
      # get new data if button clicked
      observeEvent(input$manualRefresh, {
        # get the new data
        withProgress(message = 'Getting new data',
                     {
                       updateDb(con)
                     })
        
      })
    }
  )
}