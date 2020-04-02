# Define UI for app that draws a histogram ----
library('shinythemes')
library('dplyr')
library('tidyr')
library('ggplot2')
library('here')
library('markdown')

ui <- navbarPage(title = 'COVID 19 Tracker',
                 #theme = shinytheme('united'),
                 tabPanel('Main',
                          wellPanel(
                            fluidRow(
                              column(4,
                                     uiOutput('chooseScaleUI')
                                     ),
                              column(4,
                                     uiOutput('chooseMetricUI')
                                     ),
                              column(4,
                                     uiOutput('chooseDiffUI')
                              )
                            ),
                            uiOutput('chooseCountryUI'),
                            fluidRow(
                              column(6,
                                     plotOutput('doPlotUI'),
                                     fluidRow(
                                      column(6,
                                             uiOutput('chooseAlignUI')
                                             ), 
                                      column(6,
                                             uiOutput('choosePlotLimUI')
                                             )
                                     )
                              ),
                              column(6,
                                     plotOutput('allPlotsUI')
                              )
                            )
                          ),
                          
    
                          ),
                 tabPanel('Background',
                         includeMarkdown('vignettes/background.md')),
                 tabPanel('Coming next',
                         includeMarkdown('vignettes/coming.md')),
                 tabPanel('About',
                         includeMarkdown('vignettes/about.md'))
)