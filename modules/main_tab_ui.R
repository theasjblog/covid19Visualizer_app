# define ui for the tab producing line charts
main_tab_ui <- function(id) {
  #the session scope
  ns <- NS(id)
  wellPanel(
    # button to refresh JHU data
    refresh_data_ui(ns('refreshData')),
    fluidRow(
      column(3,
             uiOutput(ns('groupOrCountryUI'))
      ),
      column(3,
             uiOutput(ns('groupOrCountrySelectorUI'))),
      column(3,
             uiOutput(ns('selectMetricUI')))
    ),
    fluidRow(column(12,
                    # show the plot with the single metric
                    plotlyOutput(ns(
                      'doPlotUI'
                    )))
             
    ),
    fluidRow(column(12,
                    # show the plot with the single metric
                    plotOutput(ns(
                      'doMapUI'
                    )))
             
    )
  )
}