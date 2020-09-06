# Define UI for app that draws a histogram ----
library('shinythemes')
library('dplyr')
library('tidyr')
library('ggplot2')
library('here')
library('markdown')
library('zoo')
library('rnaturalearth')
library('rnaturalearthdata')
library('countrycode')
library('rgeos')
library('stringr')
library('reshape2')

ui <- navbarPage(title = 'COVID 19 Tracker',
                 #theme = shinytheme('united'),
                 tabPanel('Main',
                          wellPanel(
                            fluidRow(
                              column(3,
                                     uiOutput('chooseScaleUI')
                                     ),
                              column(3,
                                     uiOutput('chooseMetricUI')
                                     ),
                              column(2,
                                     uiOutput('chooseDiffUI')
                                    ),
                              column(2,
                                     uiOutput('chooseSmoothUI')
                              ),
                              column(2,
                                     uiOutput('chooseNormaliseUI')
                              )
                            ),
                            uiOutput('choosePlotLimUI'),
                            uiOutput('chooseCountryUI'),
                            fluidRow(
                              column(6,
                                     plotOutput('doPlotUI'),
                              ),
                              column(6,
                                     plotOutput('allPlotsUI')
                              )
                            ),
                            uiOutput('showPlotInfoUI')
                          ),
                          
    
                          ),
                 tabPanel(
                   'Map',
                   wellPanel(
                     fluidRow(
                       column(4,
                              uiOutput('dayMapUI')
                       ),
                       column(4,
                              uiOutput('plotTypeUI')
                       ),
                       column(4,
                              uiOutput('plotMetricUI')
                              )
                     ),
                     uiOutput('countryMapUI'),
                     plotOutput('mapUI'),
                     uiOutput('markdownMapUI')
                   )
                 ),
                 tabPanel('Background',
                         includeMarkdown('vignettes/background.md')),
                 tabPanel('Coming next',
                         includeMarkdown('vignettes/coming.md')),
                 tabPanel('About',
                         includeMarkdown('vignettes/about.md'))
)