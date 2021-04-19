# server logic for the tab making line charts
main_tab_server <- function(input, output, session) {
    # session scope
    ns <- session$ns
    # the selector module
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
            # plot normalised data
            events <- dataSel()$eventsDataNorm
        } else {
            # plot non-normalised data
            events <- dataSel()$eventsData
        }
        
        if (input$doPredictions){
            events <- predict_data(events, days_predict=60, 
                                   training_window=28, 
                                   confidence=NULL)
        }
        p <- doPlot(events, dataSel()$chooseIfRescale)
        tryCatch({
            ggplotly(p, tooltip = "text") %>% 
                layout(legend = list(orientation = "h", 
                                     y = -0.1))
        }, error = function(e) {
            
        })
        
    })
    
    output$message <- renderText({'Predictions will use that latest 14 days and will project 60 days in the future. For better results used the "smoothed" version of data, when available. A simple ARIMA model is used.'})
}
