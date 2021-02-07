# server for the main app
server <- function(input, output, session) {
  # reactive values
  # all data is the JHU data
  rV <- reactiveValues(countries = NULL,
                       groups = NULL,
                       events = NULL,
                       poplation = NULL)
  # the logic producing the line plots
  allData_main <- main_tab_server('main_tab')
  
}