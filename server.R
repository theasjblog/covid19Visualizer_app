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
  rV <- reactiveValues(allData = refreshData(),
                       doPlotGgplot = NULL,
                       allMetricsGgplot = NULL)
  
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
    sliderInput('choosePlotLim', label = 'Dates limits', min = 0, 
                max = 100, value = c(0, 100), step = 1)
                
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
  
}