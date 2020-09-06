server <- function(input, output, session) {
  
  # publishing to shiny server from package fails
  # workaround is to download the repo here and source the R folder
  loadCode <- function(branchName){
    
    download.file(url = paste0("https://github.com/theasjblog/covid19_package/archive/",branchName,".zip")
                  , destfile = "covid19Package.zip")
    unzip(zipfile = "covid19Package.zip")
    
    listFiles <- list.files(paste0('./covid19_package-',branchName,'/R'))
    for (i in listFiles){
      source(paste0('./covid19_package-', branchName, '/R/', i))
    }
  }
  
  
  # REACTIVE VALUES
  rV <- reactiveValues(loadCode = withProgress(message = 'Loading app',
                                               {loadCode('master')}),
                       allData = withProgress(message = 'Retriving data from JHU',
                                              {getJHU()}),
                       doPlotGgplot = NULL,
                       allMetricsGgplot = NULL,
                       world = NULL,
                       mapArgs = NULL)#list(plotMetric = 'cases',
                                      #filterByCountry = 'Italy',
                                      #chosenDay = NULL,
                                      #plotType = 'doMapGBQuarantine_binary'))
  
  
  
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
                      req(length(input$chooseCountry)>0)
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
  
  output$doPlotUI <- renderPlot({
    req(rV$doPlotGgplot)
    rV$doPlotGgplot
  })
  
  output$allPlotsUI <- renderPlot({
    req(rV$allMetricsGgplot)
    rV$allMetricsGgplot
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
    req(!input$plotType %in% c('doMapGBQuarantine_binary', 'doMapGBQuarantine'))
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
              print(input$plotType)
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
      plotMap(world = rV$world,
               plotMetric = rV$mapArgs$plotMetric,
               filterByCountry = rV$mapArgs$filterByCountry,
               chosenDay = rV$mapArgs$chosenDay,
               plotType = rV$mapArgs$plotType),
      error = function(err){})
    
  })
  
}