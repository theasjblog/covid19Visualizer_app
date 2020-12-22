server <- function(input, output, session) {

# set up ------------------------------------------------------------------
  # publishing to shiny server from package fails
  # workaround is to download the repo 
  # and source the R folder
  loadCode <- function(){
    listFiles <- list.files('./auxFunctions')
    for (i in listFiles){
      source(paste0('./auxFunctions/', i))
    }
  }
  # REACTIVE VALUES
  rV <- reactiveValues(loadCode = withProgress(message = 'Loading app',
                                               {loadCode()}),
                       allData = readRDS(here::here('data', 'allData.rds')),
                       doPlotGgplot = NULL,
                       allMetricsGgplot = NULL,
                       world = NULL,
                       mapArgs = NULL)
  
  
  output$manualRefreshUI <- renderUI({
    req(rV$allData)
    rawData <- slot(rV$allData, 'JHUData_raw')
    lastDate <- colnames(rawData)[ncol(rawData)-1]
    lastDate <- getDates(lastDate)
    lastDate <- format(as.Date(lastDate), '%d %B %Y')
    tagList(
      h6('Last time refreshed: ', lastDate, '.'),
      h6('To refresh the app with the latest data click the button below. This might take a few seconds.'),
      actionButton('manualRefresh', 'Refresh Data')
    )
  })
  
  observeEvent(input$manualRefresh,{
    withProgress(message = 'Retriving new data from JHU',
                 {refreshJHU()})
    rV$allData <- withProgress(message = 'Preparing data',
                               {getJHU()})
  })
  
  output$showPlotInfoUI <- renderUI({
    req(rV$allData)
    includeMarkdown('./vignettes/plotDescription.md')
  })
  
  output$mapTitleUI <- renderUI({
    req(rV$world)
    plotTitle <- tryCatch(
      getMapTitle(world = rV$world,
               plotMetric = rV$mapArgs$plotMetric,
               filterByCountry = rV$mapArgs$filterByCountry,
               chosenDay = rV$mapArgs$chosenDay,
               plotType = rV$mapArgs$plotType),
      error = function(err){})
    p(plotTitle)
  })
  
  output$markdownMapUI <- renderUI({
    req(rV$allData)
    includeMarkdown('./vignettes/mapDescription.md')
  })
  output$chooseScaleUI <- renderUI({
    req(rV$allData)
    selectInput('chooseScale', 'Scale',
                choices = c('linear', 'log'),
                selected = 'linear')
  })
  
  output$chooseDiffUI <- renderUI({
    req(rV$allData)
    checkboxInput('chooseDiff', 'Plot rate',
                  value = TRUE)
  })
  
  output$chooseNormaliseUI <- renderUI({
    req(rV$allData)
    checkboxInput('chooseNormalise', 'Normalise by population',
                  value = FALSE)
  })
  
  output$chooseSmoothUI <- renderUI({
    req(rV$allData)
    checkboxInput('chooseSmooth', 'Smooth plot',
                  value = TRUE)
  })
  
  output$chooseCountryUI <- renderUI({
    req(rV$allData)
    optionsAre <- rV$allData@keys
    selectInput('chooseCountry', 'Country',
                choices = unique(optionsAre),
                selected = 'Italy',
                multiple = TRUE)
  })
  
  
  output$choosePlotLimUI <- renderUI({
    req(rV$allData)
    maxVal <- ncol(rV$allData@JHUData_raw)-1
    sliderInput('choosePlotLim', label = 'Dates limits', min = 1, 
                max = maxVal, value = c(1, maxVal), step = 1)
    
  })
  
  output$chooseMetricUI <- renderUI({
    req(rV$allData)
    selectInput('chooseMetric', 'Metric',
                choices = c('cases', 'deaths', 'recovered'),
                selected = 'cases')
  })
  
  observeEvent(list(input$chooseCountry, input$chooseScale, input$chooseMetric,
                    input$chooseDiff, input$choosePlotLim, input$chooseSmooth,
                    input$chooseNormalise),{
                      req(rV$allData)
                      req(input$chooseMetric %in% rV$allData@populationDf$type)
                      
                      rV$doPlotGgplot <- doPlot(dataObj = rV$allData,
                                                typePlot = input$chooseMetric,
                                                geographyFilter = input$chooseCountry,
                                                scale = input$chooseScale,
                                                plotLim = input$choosePlotLim,
                                                plotRate = input$chooseDiff,
                                                smooth = input$chooseSmooth,
                                                normalizeByPop = input$chooseNormalise)
                      
                      
                      rV$allMetricsGgplot <- plotAllMetrics(dataObj = rV$allData,
                                                            geographyFilter = input$chooseCountry,
                                                            plotRate = input$chooseDiff,
                                                            smooth = input$chooseSmooth,
                                                            scale = input$chooseScale,
                                                            normalizeByPop = input$chooseNormalise,
                                                            plotLim = input$choosePlotLim)
                    })
  
  output$doPlotUI <- renderPlotly({
    req(rV$doPlotGgplot)
    ggplotly(rV$doPlotGgplot, tooltip = 'text')
  })
  
  output$allPlotsUI <- renderPlotly({
    req(rV$allMetricsGgplot)
    ggplotly(rV$allMetricsGgplot, tooltip = 'text')
  })
  
  
  
  output$countryMapUI <- renderUI({
    req(rV$allData)
    
        avaCount <- unique(rV$allData@populationDf$Country[!is.na(rV$allData@populationDf$Population)])
        selectInput('chooseCountryMap', 'Country',
                    choices = avaCount,
                    selected = 'Italy',
                    multiple = TRUE)
  })
  
  output$dayMapUI <- renderUI({
    req(rV$allData)
    maxVal <- ncol(rV$allData@JHUData_raw)-1
    sliderInput('chooseDayMap', label = 'Dates limits', min = 1, 
                max = maxVal, value = maxVal, step = 1)
  })
  
  output$plotMetricUI <- renderUI({
    req(rV$allData)
    selectInput('plotMetric', 'Metric to plot',
                choices = c('cases', 'deaths', 'recovered'), selected = 'cases',
                multiple = FALSE)
  })
  
  output$plotMetricUI <- renderUI({
    req(rV$allData)
    req(input$plotType)
    req(!input$plotType %in% c('In/Out for UK quarantine',
                               'Total past 7 days normalised'))
    selectInput('plotMetric', 'Metric to plot',
                choices = c('cases', 'deaths', 'recovered'), selected = 'cases',
                multiple = FALSE)
  })
  
  output$plotTypeUI <- renderUI({
    req(rV$allData)
    selectInput('plotType', 'Type of plot',
                choices = c('Trend',
                            'Normalised trend',
                            'Rate',
                            'Normalised rate',
                            'In/Out for UK quarantine',
                            'Total past 7 days normalised',
                            'Total number',
                            'Total number normalised'),
                selected = 'In/Out for UK quarantine',
                multiple = FALSE)
  })
  
  observeEvent(list(input$chooseDayMap, input$plotMetric, input$chooseCountryMap,
                    input$plotType),{
              
                      if(!is.null(input$plotType)){
                        
                        plotType <- switch (input$plotType,
                              'Normalised trend' = 'doMapTrend_normalise',
                              'Trend' = 'doMapTrend',
                              'Rate' = 'doMapDataRate_raw',
                              'Normalised rate' = 'doMapDataRate_normalised',
                              'In/Out for UK quarantine' = 'doMapGBQuarantine_binary',
                              'Total past 7 days normalised' = 'doMapGBQuarantine',
                              'Total number' = 'doMapData_raw',
                              'Total number normalised' = 'doMapData_normalised'
                        )
                
                        if(plotType %in% c('doMapGBQuarantine_binary',
                                                 'doMapGBQuarantine')){
                          plotMetric <- 'cases'
                        } else {
                          plotMetric <- input$plotMetric
                        }
                        rV$mapArgs <- list(plotMetric = plotMetric,
                                           filterByCountry = input$chooseCountryMap,
                                           chosenDay = input$chooseDayMap,
                                           plotType = plotType)
                        
                      }
                    })
  
  
  observeEvent(rV$mapArgs,{
print(rV$mapArgs$filterByCountry)
    rV$world <- tryCatch(
      getWorld(plotData = rV$allData,
               plotMetric = rV$mapArgs$plotMetric,
               filterByCountry = rV$mapArgs$filterByCountry,
               chosenDay = rV$mapArgs$chosenDay,
               plotType = rV$mapArgs$plotType),
      error = function(err){})
  })
  
  
  output$mapUI <- renderPlot({
    req(rV$world)
    tryCatch(
      plotMap(world = rV$world),
      error = function(err){})
    
  })
  
}