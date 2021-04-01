#selectors_ui
selectors_ui <- function(id) {
  #the session scope
  ns <- NS(id)
  
  fluidRow(
    column(4,
           wellPanel(
           # country or group radio button
           uiOutput(ns('groupOrCountryUI')),
           # actually specify which country/group
           uiOutput(ns('groupOrCountrySelectorUI'))
           )
    ),
    column(4,
           wellPanel(
           # select the metric to display 
           uiOutput(ns('selectMetricUI'))
           ),
    ),
    column(4,
           wellPanel(
           # the mormalise and/or rescale options
           uiOutput(ns('plotSettingsUI'))
           )
    )
  )
}