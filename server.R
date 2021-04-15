# server for the main app
server <- function(input, output, session) {
  # update the data
  # get the latest data in the database
  date <- getLastDate(createConnection())
  # get today's date
  today <- Sys.Date()
  # if the data is older than yesterday, 
  # then update the database
  if (today-1>date){
    withProgress(message = 'Getting the latest data.',
                 detail = 'This might take a few seconds...',{
                   saveAllData()
                 }
    )
  }
  
  # module for the chart
  callModule(main_tab_server, 'main_tab')
  # module for the map
  callModule(map_tab_server, 'map_tab')
  # module for the data tables
  callModule(data_tab_server, 'data_tab')
}