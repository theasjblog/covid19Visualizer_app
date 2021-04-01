# server logic for the tab showing maps
map_tab_server <- function(input, output, session) {
    # session scope
    ns <- session$ns
    
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
            events <- dataSel()$dataMapNorm
        } else {
            events <- dataSel()$dataMap
        }
        events <- getMapData(con, events)
        mapFacet <- TRUE
        if (dataSel()$groupOrCountry == "Groups") {
            mapFacet <- FALSE
        }
        p <- doMap(events, mapFacet)
        
        validate(need(nrow(p$tm_shape$shp) > 0, ""))
        p
        
    })
}
