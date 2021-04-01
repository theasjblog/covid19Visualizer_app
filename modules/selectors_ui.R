#selectors_ui
selectors_ui <- function(id) {
  #the session scope
  ns <- NS(id)
  fluidRow(
    column(4,
           wellPanel(
           uiOutput(ns('groupOrCountryUI')),
           uiOutput(ns('groupOrCountrySelectorUI'))
           )
    ),
    column(4,
           wellPanel(
           uiOutput(ns('selectMetricUI'))
           ),
    ),
    column(4,
           wellPanel(
           uiOutput(ns('plotSettingsUI'))
           )
    )
  )
}