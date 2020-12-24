# logic for the tab creating maps
maps_tab_server <- function(id) {
  moduleServer(id,
               
               function(input, output, session) {
                 # session scope
                 ns <- session$ns
                 # reactive values
                 rV <- reactiveValues(allData = NULL, # the JHU data
                                      world = NULL, # the overall map data
                                      mapArgs = NULL)# the plot object
                 
                 # module ot refresh data
                 allData <- refresh_data_server('refreshData')
                 # if we get new data, update rV
                 observeEvent(allData(), {
                   rV$allData <- allData()$allData
                 })
                 # update rV in the refresh module to dispay the correct date
                 # of the last update
                 observeEvent(rV$allData,{
                   allData()$setState(rV$allData)
                 })
                 # the title of the map
                 output$mapTitleUI <- renderUI({
                   req(rV$world)
                   plotTitle <- tryCatch(
                     getMapTitle(
                       world = rV$world,
                       plotMetric = rV$mapArgs$plotMetric,
                       filterByCountry = rV$mapArgs$filterByCountry,
                       chosenDay = rV$mapArgs$chosenDay,
                       plotType = rV$mapArgs$plotType
                     ),
                     error = function(err) {
                     }
                   )
                   p(plotTitle)
                 })
                 # the UI to select a country
                 output$countryMapUI <- renderUI({
                   req(allData)
                   # availbale countries
                   avaCount <-
                     unique(slot(rV$allData, 'populationDf')$Country[!is.na(slot(rV$allData, 'populationDf')$Population)])
                   selectInput(
                     ns('chooseCountryMap'),
                     'Country',
                     choices = avaCount,
                     selected = 'Italy',
                     multiple = TRUE
                   )
                 })
                 # up to which day do we want to plot?
                 output$dayMapUI <- renderUI({
                   req(rV$allData)
                   maxVal <- ncol(slot(rV$allData, 'JHUData_raw')) - 1
                   sliderInput(
                     ns('chooseDayMap'),
                     label = 'Dates limits',
                     min = 1,
                     max = maxVal,
                     value = maxVal,
                     step = 1
                   )
                 })
                 # if to plot cases, recovered or deaths
                 output$plotMetricUI <- renderUI({
                   req(rV$allData)
                   req(input$plotType)
                   # past 7 days normalised can ony be plot for cases
                   req(!input$plotType %in% c('Total past 7 days normalised'))
                   selectInput(
                     ns('plotMetric'),
                     'Metric to plot',
                     choices = c('cases', 'deaths', 'recovered'),
                     selected = 'cases',
                     multiple = FALSE
                   )
                 })
                 # which plot do we wat to see?
                 output$plotTypeUI <- renderUI({
                   req(rV$allData)
                   selectInput(
                     ns('plotType'),
                     'Type of map',
                     choices = c(
                       'Trend',
                       'Normalised trend',
                       'Rate',
                       'Normalised rate',
                       'Total past 7 days normalised',
                       'Total number',
                       'Total number normalised'
                     ),
                     selected = 'Trend',
                     multiple = FALSE
                   )
                 })
                 
                 observeEvent(
                   list(
                     input$chooseDayMap,
                     input$plotMetric,
                     input$chooseCountryMap,
                     input$plotType
                   ),
                   {
                     if (!is.null(input$plotType)) {
                       plotType <- switch (
                         input$plotType,
                         'Normalised trend' = 'doMapTrend_normalise',
                         'Trend' = 'doMapTrend',
                         'Rate' = 'doMapDataRate_raw',
                         'Normalised rate' = 'doMapDataRate_normalised',
                         'Total past 7 days normalised' = 'doMapGBQuarantine',
                         'Total number' = 'doMapData_raw',
                         'Total number normalised' = 'doMapData_normalised'
                       )
                       
                       if (plotType %in% c('doMapGBQuarantine_binary',
                                           'doMapGBQuarantine')) {
                         plotMetric <- 'cases'
                       } else {
                         plotMetric <- input$plotMetric
                       }
                       rV$mapArgs <-
                         list(
                           plotMetric = plotMetric,
                           filterByCountry = input$chooseCountryMap,
                           chosenDay = input$chooseDayMap,
                           plotType = plotType
                         )
                       
                     }
                   }
                 )
                 
                 
                 observeEvent(rV$mapArgs, {
                   rV$world <- tryCatch(
                     withProgress(message = 'Refreshing map',
                                  {
                                    getWorld(
                                      plotData = rV$allData,
                                      plotMetric = rV$mapArgs$plotMetric,
                                      filterByCountry = rV$mapArgs$filterByCountry,
                                      chosenDay = rV$mapArgs$chosenDay,
                                      plotType = rV$mapArgs$plotType
                                    )
                                  }),
                     error = function(err) {
                     }
                   )
                 })
                 
                 
                 output$mapUI <- renderPlot({
                   req(rV$world)
                   tryCatch(
                     withProgress(message = 'Refreshing map',
                                  {
                                    plotMap(world = rV$world)
                                  }),
                     error = function(err) {
                     }
                   )
                   
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
