# define ui for the tab producing line charts
main_tab_ui <- function(id) {
  #the session scope
  ns <- NS(id)
  fluidRow(
    # the selectors module
    selectors_ui(ns('selServPlot')),
    checkboxInput(ns('doPredictions'), 'Predictions', FALSE),
    span(textOutput(ns("message")), style="color:grey"),
    wellPanel(
      fluidRow(column(12,
                      plotlyOutput(ns(
                        'doPlotUI'
                      ))),
      )
    )
  )
}