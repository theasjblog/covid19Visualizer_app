# define ui for the tab showing data tables
data_tab_ui <- function(id) {
  #the session scope
  ns <- NS(id)
  
  fluidRow(
    # the selectors module
    selectors_ui(ns('selServData')),
    wellPanel(
      fluidRow(
        # select if showing demographics or metric data
        uiOutput(ns('whichTableUI')),
        # the table
        DTOutput(ns('dataView'))
      )
    ))
}