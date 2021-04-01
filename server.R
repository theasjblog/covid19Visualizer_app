# server for the main app
server <- function(input, output, session) {
  # module for the chart
  callModule(main_tab_server, 'main_tab')
  # module for the map
  callModule(map_tab_server, 'map_tab')
  # module for the data tables
  callModule(data_tab_server, 'data_tab')
}