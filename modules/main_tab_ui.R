# define ui for the tab producing line charts
main_tab_ui <- function(id) {
  #the session scope
  ns <- NS(id)
  wellPanel(
    selectors_ui(ns('selServPlot')),
    fluidRow(column(12,
                    plotlyOutput(ns(
                      'doPlotUI'
                    ))),
    )
  )
}