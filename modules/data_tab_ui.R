# define ui for the tab showing data tables
data_tab_ui <- function(id) {
  #the session scope
  ns <- NS(id)
  wellPanel(
    selectors_ui(ns('selServData')),
    fluidRow(
      uiOutput(ns('whichTableUI')),
      DTOutput(ns('dataView'))
    )
  )
}