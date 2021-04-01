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
    
    output$doMapUI <- renderPlotly({
        
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
        #get the map data
        events$code <- countrycode::countrycode(events$Country,
                                                origin = 'country.name',
                                                destination = 'iso3c')
        # add tooltip text
        events <- getText(events)
        # select only the latest date
        events <- events %>% 
            dplyr::group_by(Country) %>%
            dplyr::filter(date == max(date))
        # do plot
        p <- plotly::plot_ly(events,
                             type='choropleth',
                             locations=events$code,
                             z=events$value,
                             text=events$text,
                             hoverinfo = 'text',
                             colorscale="bluered")
        p
    })
}
