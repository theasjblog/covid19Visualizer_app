# server logic for the tab making line charts
main_tab_server <- function(id) {
  moduleServer(id,
               function(input, output, session) {
                 # session scope
                 ns <- session$ns
                 # reactive values
                 rV <- reactiveValues(allCountries = sort(getOptions('groups', 'Country')),
                                      allGroups = sort(getOptions('groups', 'groups')),
                                      allMetrics = sort(getOptions('events', 'variable')),
                                      countries = NULL,
                                      groups = NULL,
                                      optionsAre = NULL,
                                      events = NULL,
                                      poplation = NULL)
                 
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
                               selected = rV$allMetrics[1], 
                               multiple = TRUE)
                 })
                 
                 observeEvent(input$groupOrCountry,{
                   if(input$groupOrCountry == 'Countries'){
                     rV$groups <- NULL
                     rV$countries <- 1
                     rV$optionsAre <- rV$allCountries
                   } else {
                     rV$countries <- NULL
                     rV$groups <- 1
                     rV$optionsAre <- rV$allGroups
                   }
                 })
                 
                 output$groupOrCountrySelectorUI <- renderUI({
                   req(rV$optionsAre)
                   selectInput(ns('groupOrCountrySelector'),
                               label = '', choices = rV$optionsAre, 
                               selected = rV$optionsAre[1], 
                               multiple = TRUE)
                 })
                 
                 output$doPlotUI <- renderPlotly({
                   req(input$groupOrCountrySelector)
                   req(input$selectMetric)
                   if(!is.null(rV$groups)){
                     groupsAre <- input$groupOrCountrySelector
                     groups <- getCountriesFromGroups(groupsAre)
                     countries <- unique(groups$Country)
                   } else {
                     countries <- input$groupOrCountrySelector
                     groups <- NULL
                   }
                   population <- getPopulationDb(countries)
                   events <- getEventsDb(countries,
                                         input$selectMetric)
                   events <- aggregateCountries(events, groups)
                   population <- aggregateCountries(population, groups)
                   
                   p <- eventsPlot(events, population, NULL, 100)
                   ggplotly(p, tooltip = 'text')  %>%
                     layout(legend = list(
                       orientation = "h",
                       y=-0.1
                     )
                     )
                 })
                 
                 output$doMapUI <- renderPlot({
                   req(input$groupOrCountrySelector)
                   req(input$selectMetric)
                   if(!is.null(rV$groups)){
                     groups <- getCountriesFromGroups(input$groupOrCountrySelector)
                     countries <- unique(groups$Country)
                   } else {
                     countries <- input$groupOrCountrySelector
                   }
                   population <- getPopulationDb(countries)
                   events <- getEventsMapDb(countries,
                                            input$selectMetric[1],
                                            getLastDate(),
                                            NULL,100)
                   if(is.null(rV$groups)){
                     doFacet <- TRUE
                   } else {
                     doFacet <- FALSE
                   }
                   p <- doMap(events,doFacet)
                   p
                 })
               })
}
