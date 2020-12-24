refresh_data_ui <- function(id){
  ns <- NS(id)
  uiOutput(ns('manualRefreshUI'))
}

refresh_data_server <- function(id){
  moduleServer(id,
    function(input, output, session){
      ns <- session$ns
      rV <- reactiveValues(allData = readRDS(here::here('data', 'allData.rds')))
      # refresh the data
      output$manualRefreshUI <- renderUI({
        req(rV$allData)
        # get the last day that the data was refreshed
        rawData <- slot(rV$allData, 'JHUData_raw')
        lastDate <- colnames(rawData)[ncol(rawData) - 1]
        lastDate <- getDates(lastDate)
        lastDate <- format(as.Date(lastDate), '%d %B %Y')
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
        withProgress(message = 'Getting new data from JHU',
                     {
                       refreshJHU()
                     })
        # format the new data
        rV$allData <-
          withProgress(message = 'Preparing data',
                       {
                         getJHU()
                       })
      })
      
      return(reactive(
        list(
          allData = rV$allData,
          setState = function(allData = NULL){
            rV$allData <- allData
          }
        )
      ))
    }
  )
}