# server for the main app
server <- function(input, output, session) {
  callModule(main_tab_server, 'main_tab')
  callModule(map_tab_server, 'map_tab')
  callModule(data_tab_server, 'data_tab')
  
}