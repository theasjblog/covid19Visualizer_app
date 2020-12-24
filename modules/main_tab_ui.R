# define ui for the tab producing line charts
main_tab_ui <- function(id) {
  #the session scope
  ns <- NS(id)
  wellPanel(
    # button to refresh JHU data
    refresh_data_ui(ns('refreshData')),
    fluidRow(
      column(3,
             # log or liner scale
             uiOutput(ns('chooseScaleUI'))),
      column(3,
             # cases, deaths or recovered
             uiOutput(ns('chooseMetricUI'))),
      column(2,
             # if to plot cumulative or rate date
             uiOutput(ns('chooseDiffUI'))),
      column(2,
             # if to smooth the data
             uiOutput(ns('chooseSmoothUI'))),
      column(2,
             uiOutput(ns(
               # if to normalize by population (100K people)
               'chooseNormaliseUI'
             )))
    ),
    # choose a country
    uiOutput(ns('chooseCountryUI')),
    fluidRow(column(6,
                    # show the plot with the single metric
                    plotlyOutput(ns(
                      'doPlotUI'
                    )),),
             column(6,
                    # show the faceted plots grouped y country and with all
                    # metrics for each country
                    plotlyOutput(ns(
                      'allPlotsUI'
                    ))))
  )
}