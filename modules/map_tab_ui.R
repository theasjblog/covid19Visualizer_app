# define ui for the tab showing maps
map_tab_ui <- function(id) {
  #the session scope
  ns <- NS(id)
  fluidRow(
    selectors_ui(ns('selServMap')),
    wellPanel(
      fluidRow(column(12,
                      plotOutput(ns(
                        'doMapUI'
                      ))
      )
      )
    )
  )
}