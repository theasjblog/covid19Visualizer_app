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
             uiOutput(ns('selectMetricUI')),
             span(textOutput(ns('explainMetric')),
                  style="color:grey")
             )
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
      radioButtons(ns('whichTable'),'Show data', choices=c('Events', 'Demographic'), selected='Demographic'),
      DTOutput(ns('dataView'))
    )
  )
}