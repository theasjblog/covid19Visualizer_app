# define ui for the tab making maps
maps_tab_ui <- function(id) {
  # session scope
  ns <- NS(id)
  wellPanel(
    refresh_data_ui(ns('refreshData')),
    fluidRow(
      column(4,
             # (up to) which day to plot
             uiOutput(ns('dayMapUI'))),
      column(4,
             # type of plot
             uiOutput(ns('plotTypeUI'))),
      column(4,
             # cases, deaths or recovered
             uiOutput(ns('plotMetricUI')))
    ),
    # choose country
    uiOutput(ns('countryMapUI')),
    # the map title
    uiOutput(ns('mapTitleUI')),
    # the actual map
    plotOutput(ns('mapUI'))
  )
}