# server logic for the tab making line charts
main_tab_server <- function(id) {
  moduleServer(id,
               function(input, output, session) {
                 # session scope
                 ns <- session$ns
                 # reactive values
                 rV <- reactiveValues(allCountries = sort(getOptions(con, 'groups', 'Country')),
                                      allGroups = sort(getOptions(con, 'groups', 'groups')),
                                      allMetrics = sort(getOptions(con, 'events', 'variable')),
                                      normaliseByOptions = sort(getOptions(con, 'population', 'variable')),
                                      optionsAre = NULL,
                                      events = NULL,
                                      population = NULL,
                                      thePlot = NULL,
                                      theMap = NULL
                 )
                 
                 refresh_data_server('refreshData')
                 
                 output$groupOrCountryUI <- renderUI({
                   radioButtons(ns('groupOrCountry'), 
                                label = '',
                                choices = c('Countries', 'Groups'), 
                                selected = 'Countries')
                 })
                 
                 output$selectMetricUI <- renderUI({
                   selectInput(ns('selectMetric'),
                               label = 'Metric', 
                               choices = rV$allMetrics, 
                               selected = 'new_cases_smoothed', 
                               multiple = TRUE)
                 })
                 
                 output$explainMetric <- renderText({
                   'If more than one metric is selected, only the first one will be used for the map.'
                 })
                 
                 
                 observeEvent(input$groupOrCountry,{
                   if(input$groupOrCountry == 'Countries'){
                     rV$optionsAre <- rV$allCountries
                   } else {
                     rV$optionsAre <- rV$allGroups
                   }
                 })
                 
                 output$groupOrCountrySelectorUI <- renderUI({
                   req(rV$optionsAre)
                   if(input$groupOrCountry == 'Countries'){
                     mySel <- 'Italy'
                   } else {
                     mySel <- 'Europe'
                   }
                   selectInput(ns('groupOrCountrySelector'),
                               label = '', choices = rV$optionsAre, 
                               selected = mySel, 
                               multiple = TRUE)
                 })
                 
                 observeEvent(list(input$groupOrCountry,
                                   input$groupOrCountrySelector,
                                   input$selectMetric,
                                   input$chooseIfNorm,
                                   input$chooseNorm,
                                   input$multiplyFactor),{
                                     
                                     # req does not work here for some reason
                                     validate(need(!is.null(input$groupOrCountry),''))
                                     validate(need(!is.null(input$groupOrCountrySelector),''))
                                     validate(need(!is.null(input$selectMetric),''))
                                     validate(need(!is.null(input$chooseIfNorm),''))
                                     
                                     date <- NULL
                                     if(input$groupOrCountry=='Countries'){
                                       groups <- NULL
                                       countries <- input$groupOrCountrySelector
                                       mapFacet <- TRUE
                                     } else {
                                       countries <- NULL
                                       groups <- input$groupOrCountrySelector
                                       mapFacet <- FALSE
                                     }
                                     if (!is.null(countries)){
                                       validate(need(all(countries %in% rV$allCountries),''))
                                     }
                                     if (!is.null(groups)){
                                       validate(need(all(groups %in% rV$allGroups),''))
                                     }
                                     population <- getPopulationDb(con, groups, countries)
                                     events <- getEventsDb(con, groups, countries, date, input$selectMetric)
                                     if(input$chooseIfNorm){
                                       
                                       validate(need(!is.null(input$multiplyFactor),''))
                                       validate(need(!is.null(input$chooseNorm),''))
                                       mf <- as.numeric(str_replace_all(input$multiplyFactor, ',',''))
                                       eventsDataMap <- normaliseEvents(events,
                                                                        population,
                                                                        input$chooseNorm,
                                                                        mf)
                                       
                                     } else {
                                       eventsDataMap <- events
                                     }
                                     
                                     eventsDataMap <- getMapData(con, eventsDataMap)
                                     
                                     if(input$groupOrCountry=='Groups'){
                                       events <- aggregateCountries(con, events, groups)
                                       population <- aggregateCountries(con, population, groups)
                                     }
                                     if(input$chooseIfNorm){
                                       validate(need(!is.null(input$multiplyFactor),''))
                                       validate(need(!is.null(input$chooseNorm),''))
                                       
                                       mf <- as.numeric(str_replace_all(input$multiplyFactor, ',',''))
                                       
                                       events <- normaliseEvents(events,
                                                                 population,
                                                                 input$chooseNorm,
                                                                 mf)
                                     }
                                     thePlot <- doPlot(events)
                                     theMap <- doMap(eventsDataMap, mapFacet)
                                     
                                     rV$population <- population
                                     rV$events <- events
                                     rV$thePlot <- thePlot
                                     rV$theMap <- theMap
                                     
                                     
                                   })
                 
                 output$doPlotUI <- renderPlotly({
                   req(rV$thePlot)
                   tryCatch({
                     ggplotly(rV$thePlot, tooltip = 'text')  %>%
                       layout(legend = list(
                         orientation = "h",
                         y=-0.1
                       ))
                   }, error = function(e){
                     
                   })
                   
                 })
                 
                 output$doMapUI <- renderPlot({
                   req(rV$theMap)
                   
                   validate(need(nrow(rV$theMap$tm_shape$shp)>0,
                                 ''))
                   rV$theMap
                   
                 })
                 
                 
                 output$chooseIfNormUI <- renderUI({
                   checkboxInput(ns('chooseIfNorm'),'Normalise', value = FALSE)
                 })
                 
                 output$chooseNormUI <- renderUI({
                   req(input$chooseIfNorm)
                   validate(need(input$chooseIfNorm,''))
                   tagList(
                     column(6,
                            selectInput(ns('chooseNorm'),'', choices = rV$normaliseByOptions, selected = 'population')
                     ),
                     column(6,
                            selectInput(ns('multiplyFactor'),'', choices = c('1','100','1,000',
                                                                             '100,000',
                                                                             '1,000,000'), selected = 100)
                     )
                   )
                 })
                 
                 output$dataView <- renderDT({
                   req(input$whichTable)
                   if(input$whichTable == 'Events'){
                     rV$events
                   } else {
                     rV$population
                   }
                 })
                 
               })
}
