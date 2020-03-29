# Define UI for app that draws a histogram ----
library('shinythemes')

ui <- navbarPage(title = 'COVID 19 Tracker',
                 #theme = shinytheme('united'),
                 tabPanel('Main',
                          wellPanel(
                            fluidRow(
                              column(6,
                                     uiOutput('chooseScaleUI')
                                     ),
                              column(6,
                                     uiOutput('chooseMetricUI')
                                     )
                            ),
                            uiOutput('chooseCountryUI'),
                            fluidRow(
                              column(6,
                                     plotOutput('doPlotUI')
                              ),
                              column(6,
                                     plotOutput('allPlotsUI')
                              )
                            )
                          ),
                          
    
                          )#,
                 # tabPanel('Background',
                 #          includeMarkdown('vignettes/tssPlanner_background.md')),
                 # tabPanel('Coming next',
                 #          includeMarkdown('vignettes/tssPlanner_notes.md')),
                 # tabPanel('About',
                 #          includeMarkdown('vignettes/tssPlanner_about.md'))
)