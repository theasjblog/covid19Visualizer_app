# define ui for the tab showing maps
map_tab_ui <- function(id) {
  #the session scope
  ns <- NS(id)
  wellPanel(
    selectors_ui(ns('selServMap')),
    fluidRow(column(12,
                    plotOutput(ns(
                      'doMapUI'
                    ))
    )
    )
  )
}