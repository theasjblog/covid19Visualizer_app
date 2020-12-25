# server logic for the tab making line charts
main_tab_server <- function(id) {
  moduleServer(id,
               function(input, output, session) {
                 # session scope
                 ns <- session$ns
                 # reactive values
                 rV <- reactiveValues(allData = NULL, # the data to plot
                                      doPlotGgplot = NULL, # single metric plot
                                      allMetricsGgplot = NULL) # faceted plots
                 
                 allData <- refresh_data_server('refreshData')
                 
                 observeEvent(allData(), {
                   rV$allData <- allData()$allData
                 })
                 
                 observeEvent(rV$allData,{
                   allData()$setState(rV$allData)
                 })
                 
                 output$showPlotInfoUI <- renderUI({
                   req(rV$allData)
                   includeMarkdown('./vignettes/plotDescription.md')
                 })
                 
                 
                 output$chooseScaleUI <- renderUI({
                   req(rV$allData)
                   selectInput(
                     ns('chooseScale'),
                     'Scale',
                     choices = c('linear', 'log'),
                     selected = 'linear'
                   )
                 })
                 
                 output$chooseDiffUI <- renderUI({
                   req(rV$allData)
                   checkboxInput(ns('chooseDiff'), 'Plot rate',
                                 value = TRUE)
                 })
                 
                 output$chooseNormaliseUI <- renderUI({
                   req(rV$allData)
                   checkboxInput(ns('chooseNormalise'), 'Normalise by population',
                                 value = FALSE)
                 })
                 
                 output$chooseSmoothUI <- renderUI({
                   req(rV$allData)
                   checkboxInput(ns('chooseSmooth'), 'Smooth plot',
                                 value = TRUE)
                 })
                 
                 output$chooseCountryUI <- renderUI({
                   req(rV$allData)
                   optionsAre <- slot(rV$allData, 'keys')
                   selectInput(
                     ns('chooseCountry'),
                     'Country',
                     choices = unique(optionsAre),
                     selected = 'Italy',
                     multiple = TRUE
                   )
                 })
                 
                 output$chooseMetricUI <- renderUI({
                   req(rV$allData)
                   selectInput(
                     ns('chooseMetric'),
                     'Metric',
                     choices = c('cases', 'deaths', 'recovered'),
                     selected = 'cases'
                   )
                 })
                 
                 observeEvent(
                   list(
                     input$chooseCountry,
                     input$chooseScale,
                     input$chooseMetric,
                     input$chooseDiff,
                     input$chooseSmooth,
                     input$chooseNormalise
                   ),
                   {
                     req(rV$allData)
                     req(input$chooseMetric %in% slot(rV$allData, 'populationDf')$type)
                     
                     rV$doPlotGgplot <-
                       doPlot(
                         dataObj = rV$allData,
                         typePlot = input$chooseMetric,
                         geographyFilter = input$chooseCountry,
                         scale = input$chooseScale,
                         plotRate = input$chooseDiff,
                         smooth = input$chooseSmooth,
                         normalizeByPop = input$chooseNormalise
                       )
                     
                     
                     rV$allMetricsGgplot <-
                       plotAllMetrics(
                         dataObj = rV$allData,
                         geographyFilter = input$chooseCountry,
                         plotRate = input$chooseDiff,
                         smooth = input$chooseSmooth,
                         scale = input$chooseScale,
                         normalizeByPop = input$chooseNormalise
                       )
                   }
                 )
                 
                 output$doPlotUI <- renderPlotly({
                   req(rV$doPlotGgplot)
                   ggplotly(rV$doPlotGgplot, tooltip = 'text')
                 })
                 
                 output$allPlotsUI <- renderPlotly({
                   req(rV$allMetricsGgplot)
                   ggplotly(rV$allMetricsGgplot, tooltip = 'text')
                 })
                 
                 return(reactive(
                   list(
                     allData = rV$allData,
                     setState = function(allData = NULL){
                       rV$allData <- allData
                     }
                   )
                 ))
               })
}
