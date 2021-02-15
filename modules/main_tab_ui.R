# define ui for the tab producing line charts
main_tab_ui <- function(id) {
  #the session scope
  ns <- NS(id)
  wellPanel(
    # button to refresh JHU data
    #refresh_data_ui(ns('refreshData')),
    fluidRow(
      column(4,
             uiOutput(ns('groupOrCountryUI')),
             uiOutput(ns('groupOrCountrySelectorUI'))
      ),
      column(4,
             uiOutput(ns('selectMetricUI'))#,
             # span(textOutput(ns('explainMetric')),
             #      style="color:grey")
             ),
      column(4,
             uiOutput(ns('metricMapUI')))
    ),
    fluidRow(column(6,
                    uiOutput(ns('chooseIfNormUI'))
                    ),
             column(6,
                    uiOutput((ns('chooseNormUI')))
             )
             
    ),
    fluidRow(column(6,
                    # show the plot with the single metric
                    plotlyOutput(ns(
                      'doPlotUI'
                    ))),
             column(6,
                    # show the plot with the single metric
                    plotOutput(ns(
                      'doMapUI'
                    ))
             )
             
    ),
    fluidRow(
      uiOutput(ns('whichTableUI')),
      DTOutput(ns('dataView'))
    )
  )
}