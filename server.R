# server for the main app
server <- function(input, output, session) {
  # reactive values
  # all data is the JHU data
  rV <- reactiveValues(allData = NULL)
  # the logic producing the line plots
  allData_main <- main_tab_server('main_tab')
  allData_maps <- maps_tab_server('maps_tab')
  # if we get new data from the main tab
  # update the rV
  observeEvent(allData_main(),{
    rV$allData <- allData_main()$allData
  })
  # if we get new data from the maps tab
  # update the rV
  observeEvent(allData_maps(),{
    rV$allData <- allData_maps()$allData
  })
  # if the rV data has changed, update the tabs
  observeEvent(rV$allData,{
    allData_maps()$setState(rV$allData)
    allData_main()$setState(rV$allData)
  })
}