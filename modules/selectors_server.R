# selectors_server
selectors_server <- function(input, output, session, 
                             isMultiple = TRUE, 
                             showRescale = FALSE, 
                             requester = 'map') {
  # session scope
  ns <- session$ns
  # reactive values
  rV <- reactiveValues(allCountries = sort(
    getOptions(con, "groups", "Country")),
    allGroups = sort(
      getOptions(con, "groups", "groups")), 
    allMetrics = sort(getOptions(con, "events", "variable")), 
    normaliseByOptions = sort(getOptions(con, "population", "variable")), 
    optionsAre = NULL, 
    dataMap = NULL, 
    dataMapNorm = NULL, 
    populationData = NULL, 
    eventsData = NULL, 
    eventsDataNorm = NULL)
  
  output$groupOrCountryUI <- renderUI({
    radioButtons(ns("groupOrCountry"), 
                 label = "Geography", 
                 choices = c("Countries", "Groups"), 
                 selected = "Countries")
  })
  
  output$selectMetricUI <- renderUI({
    if (requester == "map") {
      choices <- c(rV$allMetrics, rV$normaliseByOptions)
    } else {
      choices <- rV$allMetrics
    }
    selectInput(ns("selectMetric"), label = "Metric", choices = choices, 
                selected = "new_cases_smoothed", multiple = isMultiple)
  })
  
  observeEvent(input$groupOrCountry, {
    if (input$groupOrCountry == "Countries") {
      rV$optionsAre <- rV$allCountries
    } else {
      rV$optionsAre <- rV$allGroups
    }
  })
  
  output$groupOrCountrySelectorUI <- renderUI({
    req(rV$optionsAre)
    if (input$groupOrCountry == "Countries") {
      mySel <- "Italy"
    } else {
      mySel <- "Europe"
    }
    selectInput(ns("groupOrCountrySelector"), label = "", 
                choices = rV$optionsAre, 
                selected = mySel, multiple = TRUE)
  })
  
  observeEvent(list(input$groupOrCountry, input$groupOrCountrySelector, 
                    input$selectMetric), {
                      
                      # req does not work here for some reason
                      validate(need(!is.null(input$groupOrCountry), ""))
                      validate(need(!is.null(input$groupOrCountrySelector), ""))
                      validate(need(!is.null(input$selectMetric), ""))
                      
                      
                      date <- NULL
                      if (input$groupOrCountry == "Countries") {
                        groups <- NULL
                        countries <- input$groupOrCountrySelector
                        mapFacet <- TRUE
                      } else {
                        countries <- NULL
                        groups <- input$groupOrCountrySelector
                        mapFacet <- FALSE
                      }
                      if (!is.null(countries)) {
                        validate(need(all(countries %in% rV$allCountries), ""))
                      }
                      if (!is.null(groups)) {
                        validate(need(all(groups %in% rV$allGroups), ""))
                      }
                      
                      populationData <- getPopulationDb(con, groups, countries)
                      if (requester == "map") {
                        if (input$selectMetric %in% rV$allMetrics) {
                          events <- getEventsDb(con, groups, countries, 
                                                date, input$selectMetric)
                        } else {
                          events <- populationData %>% 
                            dplyr::filter(variable %in% input$selectMetric)
                        }
                        
                        rV$dataMap <- events
                      } else if (requester %in% c("plot", "data")) {
                        events <- getEventsDb(con, groups, countries, date, 
                                              input$selectMetric)
                        if (input$groupOrCountry == "Groups") {
                          events <- aggregateCountries(con, events, groups)
                          populationData <- aggregateCountries(con, 
                                                               populationData, 
                                                               groups)
                        }
                        
                        rV$eventsData <- events
                        
                      }
                      
                      rV$populationData <- populationData
                    })
  
  # add tot this list the eventsData
  observeEvent(list(rV$eventsData,
                    rV$dataMap, input$chooseIfNorm), {
                      validate(need(!is.null(input$selectMetric), ""))
                      if (input$chooseIfNorm) {
                        mf <- 100
                        nb <- "population"
                        if (!is.null(rV$dataMap)){
                          dataMapNorm <- normaliseEvents(rV$dataMap, 
                                                         rV$populationData, 
                                                         nb, mf)
                        } else {
                          dataMapNorm <- NULL
                        }
                        if (!is.null(rV$eventsData)){
                          eventsDataNorm <- normaliseEvents(rV$eventsData, 
                                                            rV$populationData, 
                                                            nb, mf)
                        } else {
                          eventsDataNorm <- NULL
                        }
                        
                      } else {
                        dataMapNorm <- NULL
                        eventsDataNorm <- NULL
                      }
                      rV$dataMapNorm <- dataMapNorm
                      rV$eventsDataNorm <- eventsDataNorm
                    })
  
  output$plotSettingsUI <- renderUI({
    if (showRescale) {
      tagList(
        checkboxInput(ns("chooseIfNorm"), 
                      "Show in percentage of the population",
                      value = FALSE),
        checkboxInput(ns("chooseIfRescale"),
                      "Fit to y-axis", value = FALSE))
    } else {
      checkboxInput(ns("chooseIfNorm"), 
                    "Show in percentage of the population", 
                    value = FALSE)
    }
  })
  
  
  return(reactive(list(dataMap = rV$dataMap, dataMapNorm = rV$dataMapNorm, 
                       populationData = rV$populationData, 
                       eventsData = rV$eventsData,
                       eventsDataNorm = rV$eventsDataNorm,
                       chooseIfRescale = input$chooseIfRescale,
                       groupOrCountry = input$groupOrCountry)))
}
