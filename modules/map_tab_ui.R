# define ui for the tab showing maps
map_tab_ui <- function(id) {
  #the session scope
  ns <- NS(id)
  fluidRow(
    # the selectors module
    selectors_ui(ns('selServMap')),
    wellPanel(
      # the map
      fluidRow(column(12,
                      plotOutput(ns(
                        'doMapUI'
                      ))
      )
      )
    )
  )
}