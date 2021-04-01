# server logic for the tab showing data tables
data_tab_server <- function(input, output, session) {
    # session scope
    ns <- session$ns
    # the selectors module
    dataSel <- callModule(selectors_server, "selServData", 
                          isMultiple = TRUE, 
                          showRescale = FALSE, 
                          requester = "data"
                          )

    # render the data table
    output$dataView <- renderDT({
        req(input$whichTable)
        
        if (input$whichTable == "Metrics") {
            # show the metrics data
            if (!is.null(dataSel()$eventsDataNorm)){
                # show normalised data, if available
                displayEvents(dataSel()$eventsDataNorm)
            } else {
                # show non normalised data
                displayEvents(dataSel()$eventsData)
            }
        } else {
            # show demographic data
            validate(need(!is.null(dataSel()$populationData), ''))
            displayPopulation(dataSel()$populationData, NULL)
        }
    })

    # select if to show metrics or demographic data
    output$whichTableUI <- renderUI({
        radioButtons(ns("whichTable"), "Show data", 
                     choices = c("Metrics", "Demographic"), 
                     selected = "Demographic")
    })

}
