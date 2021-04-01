# server logic for the tab showing maps
map_tab_server <- function(input, output, session) {
    # session scope
    ns <- session$ns
    # the selectors module
    dataSel <- callModule(selectors_server, "selServMap", 
                          isMultiple = FALSE, 
                          showRescale = FALSE, 
                          requester = "map"
                          )
    
    output$doMapUI <- renderPlot({
        validate(
            need(
                !is.null(dataSel()$dataMap) | !is.null(dataSel()$dataMapNorm), 
                      ""
                )
            )
        if (!is.null(dataSel()$dataMapNorm)) {
            # we plot normalised data
            events <- dataSel()$dataMapNorm
        } else {
            # we plot non-normalised data
            events <- dataSel()$dataMap
        }
        # get the map data
        events <- getMapData(con, events)
        mapFacet <- TRUE
        if (dataSel()$groupOrCountry == "Groups") {
            # if we selected groups, we actually do not
            # want to facet 
            mapFacet <- FALSE
        }
        p <- doMap(events, mapFacet)
        # check the map is correct by looking
        # at the size of the data
        validate(need(nrow(p$tm_shape$shp) > 0, ""))
        p
        
    })
}
