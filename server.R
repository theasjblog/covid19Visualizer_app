##
# publishing from package fails
# workaround is to download the repo here and source the R folder
download.file(url = "https://github.com/theasjblog/covid19_package/archive/master.zip"
              , destfile = "covid19Package.zip")
unzip(zipfile = "covid19Package.zip")

listFiles <- list.files(paste0('./covid19_package-master/R'))
for (i in listFiles){
  source(paste0('./covid19_package-master/R/', i))
}

server <- function(input, output, session) {
  # REACTIVE VALUES
  rV <- reactiveValues(allData = withProgress(message = 'Retriving data from JHU',
                                              {refreshData()}),
                       doPlotGgplot = NULL,
                       allMetricsGgplot = NULL,
                       mapArgs = NULL)
  
  output$allDataTable <- renderTable({
    req(rV$allData)
    head(rV$allData,2)
  })
  
  
  output$chooseScaleUI <- renderUI({
    req(rV$allData)
    selectInput('chooseScale', 'Scale',
                choices = c('linear', 'log'),
                selected = 'linear')
  })
  
  output$chooseDiffUI <- renderUI({
    req(rV$allData)
    selectInput('chooseDiff', 'Plot type',
                choices = c('raw', 'rate'),
                selected = 'raw')
  })
  
  output$chooseCountryUI <- renderUI({
    req(rV$allData)
    selectInput('chooseCountry', 'Country',
                choices = unique(rV$allData$country),
                selected = unique(rV$allData$country)[1],
                multiple = TRUE)
  })
  
  output$chooseAlignUI <- renderUI({
    req(rV$allData)
    checkboxInput('chooseAlign', 'Align dates', FALSE)
  })
  
  output$choosePlotLimUI <- renderUI({
    req(rV$allData)
    maxVal <- ncol(rV$allData)-6
    sliderInput('choosePlotLim', label = 'Dates limits', min = 0, 
                max = maxVal, value = c(1, maxVal), step = 1)
                
  })
  
  output$chooseMetricUI <- renderUI({
    req(rV$allData)
    selectInput('chooseMetric', 'Metric',
                choices = c('cases', 'deaths', 'recovered'),
                selected = 'cases')
  })
  
  observeEvent(list(input$chooseCountry, input$chooseScale, input$chooseMetric,
                    input$chooseDiff, input$chooseAlign, input$choosePlotLim),{
    req(rV$allData)
    req(length(input$chooseCountry)>0)
    req(input$chooseMetric %in% rV$allData$type)
    req(all(input$chooseCountry %in% rV$allData$country))
    if (input$chooseDiff == 'raw'){
      plotDiff <- FALSE
    } else {
      plotDiff <- TRUE
    }
    
    rV$doPlotGgplot <- doPlot(df = rV$allData,
                              typePlot = input$chooseMetric,
                              countryPlot = input$chooseCountry,
                              scale = input$chooseScale,
                              plotDiff = plotDiff,
                              align = input$chooseAlign,
                              plotLim = input$choosePlotLim)
    
    rV$allMetricsGgplot <- plotAllMetrics(allDf = rV$allData,
                                          countryPlot = input$chooseCountry,
                                          scale = input$chooseScale,
                                          plotDiff = plotDiff)
  })
  
  output$doPlotUI <- renderPlot({
    req(rV$doPlotGgplot)
    rV$doPlotGgplot
  })
  
  output$allPlotsUI <- renderPlot({
    req(rV$allMetricsGgplot)
    rV$allMetricsGgplot
  })
  
  
  output$logicalCountryMapUI <- renderUI({
    req(rV$allData)
    checkboxInput('ifAllCountriesMap', 'Show all countries?', value = TRUE)
  })
  
  output$countryMapUI <- renderUI({
    req(rV$allData)
    if(!is.null(input$ifAllCountriesMap)){
      if(!input$ifAllCountriesMap){
        selectInput('chooseCountryMap', 'Country',
                    choices = unique(rV$allData$Country.Region),
                    selected = unique(rV$allData$Country.Region)[1],
                    multiple = TRUE)
      }
    }
  })
  
  output$dayMapUI <- renderUI({
    req(rV$allData)
    if(!is.null(input$trendMap)){
      if(!input$trendMap){
        maxVal <- ncol(rV$allData)-6
        sliderInput('chooseDayMap', label = 'Dates limits', min = 1, 
                    max = maxVal, value = maxVal, step = 1)
      }
    }
  })
  
  output$trendMapUI <- renderUI({
    req(rV$allData)
    checkboxInput('trendMap', 'Show trend?', value = FALSE)
  })
  
  output$normalizeMapUI <- renderUI({
    req(rV$allData)
    if(!is.null(input$trendMap)){
      if(!input$trendMap){
        checkboxInput('normalizeMap', 'Normalize by population?', value = FALSE)
      }
    }
  })
  
  output$logicalRemoveCountryMapUI <- renderUI({
    req(rV$allData)
    checkboxInput('ifRemoveCountries', 'Remove some countries?', value = FALSE)
  })
  
  output$removeCountryMapUI <- renderUI({
    req(rV$allData)
    if(!is.null(input$ifRemoveCountries)){
      if(input$ifRemoveCountries){
        selectInput('removeCountryMap', 'Country to remove',
                    choices = unique(rV$allData$Country.Region),
                    selected = unique(rV$allData$Country.Region)[1],
                    multiple = TRUE)
      }
    }
  })
  
  observeEvent(list(input$trendMap, input$ifAllCountriesMap, input$chooseDayMap,
                    input$normalizeMap, input$chooseCountryMap, input$ifRemoveCountries,
                    input$removeCountryMap),{
      
    
      if(!is.null(input$trendMap) & !is.null(input$ifAllCountriesMap) & !is.null(input$ifRemoveCountries)){
        if(input$trendMap){
          chosenDay <- NULL
          normalizeByPopulation <- FALSE
        } else {
          chosenDay <- input$chooseDayMap
          normalizeByPopulation <- input$normalizeMap
        }
        if(input$ifAllCountriesMap){
          countriesToPlot <- NULL
        } else {
          countriesToPlot <- input$chooseCountryMap
        }
        if(!input$ifRemoveCountries){
          removeCountries <- NULL
        } else {
          removeCountries <- input$removeCountryMap
        }
        
        rV$mapArgs <- list(normalizeByPopulation = normalizeByPopulation,
                           filterByCountry = countriesToPlot,
                           removeCountries = removeCountries,
                           chosenDay = chosenDay,
                           showTrend = input$trendMap)
      }
  })
    
    
  
  output$mapUI <- renderPlot({
    req(rV$allData)
    req(rV$mapArgs)
    
    tryCatch(doMap(rawData = rV$allData,
                   normalizeByPopulation = rV$mapArgs$normalizeByPopulation,
                   filterByCountry = rV$mapArgs$filterByCountry,
                   removeCountries = rV$mapArgs$removeCountries,
                   chosenDay =  rV$mapArgs$chosenDay,
                   showTrend = rV$mapArgs$showTrend),
             error = function(err){})
    
  })
  
  output$mapQChoiceUI <- renderUI({
    req(rV$allData)
    checkboxInput('mapQChoice', 'Categorical',value = TRUE)
  })
  
  
  output$mapQUI <- renderPlot({
    doQMap(rV$mapArgs$filterByCountry, input$mapQChoice)
  })
  
}