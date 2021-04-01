# server logic for the tab showing data tables
data_tab_server <- function(input, output, session) {
    # session scope
    ns <- session$ns
    
    dataSel <- callModule(selectors_server, "selServData", 
                          isMultiple = TRUE, 
                          showRescale = FALSE, 
                          requester = "data"
                          )

    output$dataView <- renderDT({
        req(input$whichTable)
        
        if (input$whichTable == "Events") {
            if (!is.null(dataSel()$eventsDataNorm)){
                displayEvents(dataSel()$eventsDataNorm)
            } else {
                displayEvents(dataSel()$eventsData)
            }
            
        } else {
            validate(need(!is.null(dataSel()$populationData), ''))
            displayPopulation(dataSel()$populationData, NULL)
        }
    })

    output$whichTableUI <- renderUI({
        radioButtons(ns("whichTable"), "Show data", 
                     choices = c("Events", "Demographic"), 
                     selected = "Demographic")
    })

}
