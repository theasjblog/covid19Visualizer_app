# define ui for the tab showing data tables
data_tab_ui <- function(id) {
  #the session scope
  ns <- NS(id)
  fluidRow(
    selectors_ui(ns('selServData')),
    wellPanel(
      fluidRow(
        uiOutput(ns('whichTableUI')),
        DTOutput(ns('dataView'))
      )
    ))
}