# selectors_server
# @param isMultiple: boolean to control if the metric selector
#   should accept multiple ptions or not
# @param showRescale: boolean to control if the rescale
#   option should be displayed
# @param requester: one of map, plot, or data. This specifies
#   which modules called this module and set some specific
#   option and behaviour
selectors_server <- function(input, output, session, 
                             isMultiple = TRUE, 
                             showRescale = FALSE, 
                             requester = 'map') {
  # session scope
  ns <- session$ns
  # reactive values
  rV <- reactiveValues(
    # the countries available in the database
    allCountries = sort(
      getOptions(con, "groups", "Country")),
    # the groups available in the database
    allGroups = sort(
      getOptions(con, "groups", "groups")), 
    # the metrics available in the database
    allMetrics = sort(getOptions(con, "events", "variable")), 
    # the demographic options available in the database
    normaliseByOptions = sort(getOptions(con, "population", "variable")), 
    # the selected countries/groups
    optionsAre = NULL, 
    # the data for the map
    dataMap = NULL, 
    # the normalised data for the map
    dataMapNorm = NULL, 
    # the demographic data
    populationData = NULL, 
    # the data for the chart
    eventsData = NULL, 
    # the normalised data for the chart
    eventsDataNorm = NULL,
    # selected metrics
    selectedMetrics = NULL)
  
  output$groupOrCountryUI <- renderUI({
    # defaults
    if(requester == 'map'){
      selected <- 'Groups'
    } else {
      selected <- 'Countries'
    }
    radioButtons(ns("groupOrCountry"), 
                 label = "Geography", 
                 choices = c("Countries", "Groups"), 
                 selected = selected)
  })
  
  output$selectMetricUI <- renderUI({
    # in map we can plot both demographic and metric data
    # in plot and data those we cannot
    if (requester == "map") {
      # it is map: merge demographic and metrics options
      choices <- c(rV$allMetrics, rV$normaliseByOptions)
    } else {
      # just use metrics options
      choices <- rV$allMetrics
    }
    choices <- stringr::str_replace_all(choices,
                                        '_',
                                        ' ')
    selectInput(ns("selectMetric"), label = "Metric", 
                choices = choices, 
                selected = "new cases smoothed", 
                multiple = isMultiple)
  })
  
  observeEvent(input$selectMetric,{
    rV$selectedMetrics <- stringr::str_replace_all(input$selectMetric,
                                                   ' ',
                                                   '_')
  })
  observeEvent(input$groupOrCountry, {
    # store which countries/groups were used
    # this will be the choices for the country/group
    # selector
    if (input$groupOrCountry == "Countries") {
      rV$optionsAre <- rV$allCountries
    } else {
      rV$optionsAre <- rV$allGroups
    }
  })
  
  output$groupOrCountrySelectorUI <- renderUI({
    # select the desired countries/groups
    req(rV$optionsAre)
    # defaults
    if (input$groupOrCountry == "Countries") {
      mySel <- "Italy"
    } else {
      if (requester == 'map'){
        mySel <- "World"
      } else {
        mySel <- "Europe"
      }
    }
    selectInput(ns("groupOrCountrySelector"), label = "", 
                choices = rV$optionsAre, 
                selected = mySel, multiple = TRUE)
  })
  
  # observer to generate the data
  observeEvent(list(input$groupOrCountry, 
                    input$groupOrCountrySelector, 
                    rV$selectedMetrics), {
                      
                      # req does not work here for some reason
                      validate(need(!is.null(input$groupOrCountry), ""))
                      validate(need(!is.null(input$groupOrCountrySelector), ""))
                      validate(need(!is.null(rV$selectedMetrics), ""))
                      
                      if (input$groupOrCountry == "Countries") {
                        # function options if we selected to show countries
                        groups <- NULL
                        countries <- input$groupOrCountrySelector
                      } else {
                        # ffunction options if we selected to see groups
                        countries <- NULL
                        groups <- input$groupOrCountrySelector
                      }
                      if (!is.null(countries)) {
                        # validate the chosen countries
                        validate(need(all(countries %in% rV$allCountries), ""))
                      }
                      if (!is.null(groups)) {
                        # validate thhe chosen groups
                        validate(need(all(groups %in% rV$allGroups), ""))
                      }
                      # the date that will be used:
                      # for maps NULL means latest date
                      # for charts means all the dates
                      date <- NULL
                      
                      # get the population data
                      populationData <- getPopulationDb(con, groups, countries)
                      if (requester == "map") {
                        # the module was called by map
                        if (rV$selectedMetrics %in% rV$allMetrics) {
                          # if the metric chosen is actually a metric,
                          # not a demographic value
                          events <- getEventsDb(con, groups, countries, 
                                                date, rV$selectedMetrics)
                        } else {
                          # if we selected a demographic value for the map
                          events <- populationData %>% 
                            dplyr::filter(variable %in% rV$selectedMetrics)
                        }
                        # save output for map
                        rV$dataMap <- events
                      } else if (requester %in% c("plot", "data")) {
                        # the module was called by plot or data
                        events <- getEventsDb(con, groups, countries, date, 
                                              rV$selectedMetrics)
                        if (input$groupOrCountry == "Groups") {
                          # if we picked groups, we need to aggregate 
                          # by our group
                          events <- aggregateCountries(con, events, groups)
                          # the demographic data needs to be aggregated
                          # as well
                          populationData <- aggregateCountries(con, 
                                                               populationData, 
                                                               groups)
                        }
                        # store the results
                        rV$eventsData <- events
                      }
                      # store the demographic data
                      rV$populationData <- populationData
                    })
  
  # in this observer we normalise the data by n/population_size*100
  # if we requested so
  observeEvent(list(rV$eventsData,
                    rV$dataMap, 
                    input$chooseIfNorm), {
                      validate(need(!is.null(rV$selectedMetrics), ""))
                      if (input$chooseIfNorm) {
                        # we want to normalise
                        mf <- 100 # every 100 inhabitants
                        nb <- "population" # normlaise by population size
                        if (!is.null(rV$dataMap)){
                          # normalise the map data
                          dataMapNorm <- normaliseEvents(rV$dataMap, 
                                                         rV$populationData, 
                                                         nb, mf)
                        } else {
                          # we do not want to normalise map data, so we set
                          # the normalised map data to NULL
                          dataMapNorm <- NULL
                        }
                        if (!is.null(rV$eventsData)){
                          #  normlaise metrics
                          eventsDataNorm <- normaliseEvents(rV$eventsData, 
                                                            rV$populationData, 
                                                            nb, mf)
                        } else {
                          # we do not want to normalise metrics data, so we set
                          # the normalised map data to NULL
                          eventsDataNorm <- NULL
                        }
                      } else {
                        # data was not normlaised
                        dataMapNorm <- NULL
                        eventsDataNorm <- NULL
                      }
                      # save the data
                      rV$dataMapNorm <- dataMapNorm
                      rV$eventsDataNorm <- eventsDataNorm
                    })
  
  # show normalise and/or rescale options
  output$plotSettingsUI <- renderUI({
    if (showRescale) {
      # we want to show also the rescale option
      tagList(
        checkboxInput(ns("chooseIfNorm"), 
                      "Show in percentage of the population",
                      value = FALSE),
        checkboxInput(ns("chooseIfRescale"),
                      "Fit to y-axis", value = FALSE))
    } else {
      # we only want the normalise option
      checkboxInput(ns("chooseIfNorm"), 
                    "Show in percentage of the population", 
                    value = FALSE)
    }
  })
  
  return(reactive(list(
    # the dat for the map
    dataMap = rV$dataMap, 
    # the normlaised data for the map 
    dataMapNorm = rV$dataMapNorm, 
    # the demographic data
    populationData = rV$populationData, 
    # the metrics data
    eventsData = rV$eventsData,
    # the normlaised metrics data
    eventsDataNorm = rV$eventsDataNorm,
    # if we rescaled the data
    chooseIfRescale = input$chooseIfRescale,
    # if we choosed countries or groups
    groupOrCountry = input$groupOrCountry)))
}
