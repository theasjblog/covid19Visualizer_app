library('covid19Visualizer')

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
  
  output$chooseCountryUI <- renderUI({
    req(rV$allData)
    selectInput('chooseCountry', 'Country',
                choices = unique(rV$allData$country),
                selected = unique(rV$allData$country)[1],
                multiple = TRUE)
  })
  
  output$chooseMetricUI <- renderUI({
    req(rV$allData)
    selectInput('chooseMetric', 'Metric',
                choices = c('cases', 'deaths', 'recovered'),
                selected = 'cases')
  })
  
  observeEvent(list(input$chooseCountry, input$chooseScale, input$chooseMetric),{
    req(rV$allData)
    req(length(input$chooseCountry)>0)
    req(input$chooseMetric %in% rV$allData$type)
    req(all(input$chooseCountry %in% rV$allData$country))
    
    rV$doPlotGgplot <- doPlot(df = rV$allData,
                           typePlot = input$chooseMetric,
                           countryPlot = input$chooseCountry,
                           scale = input$chooseScale)
    
    rV$allMetricsGgplot <- plotAllMetrics(allDf = rV$allData,
                                          countryPlot = input$chooseCountry,
                                          scale = input$chooseScale)
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