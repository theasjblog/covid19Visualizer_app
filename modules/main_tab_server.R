# server logic for the tab making line charts
main_tab_server <- function(input, output, session) {
    # session scope
    ns <- session$ns
    
    dataSel <- callModule(selectors_server, "selServPlot", 
                          isMultiple = TRUE, 
                          showRescale = TRUE, 
                          requester = "plot"
    )
    
    output$doPlotUI <- renderPlotly({
        validate(
            need(
                !is.null(dataSel()$eventsData) | !is.null(dataSel()$eventsDataNorm), 
                "")
        )
        if (!is.null(dataSel()$eventsDataNorm)) {
            events <- dataSel()$eventsDataNorm
        } else {
            events <- dataSel()$eventsData
        }
        
        p <- doPlot(events, dataSel()$chooseIfRescale)
        tryCatch({
            ggplotly(p, tooltip = "text") %>% 
                layout(legend = list(orientation = "h", 
                                     y = -0.1))
        }, error = function(e) {
            
        })
        
    })
}
