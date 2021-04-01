# load dependencies
source('dependencies.R')
# source supporting functions. These should be an independent package
for (i in list.files('./auxFunctions')) {
  source(paste0('./auxFunctions/', i))
}
# load general app configuration i.e. app name and version
source('config.R')

# source modules
for (i in list.files('./modules')) {
  source(paste0('./modules/', i))
}

# define ui of the main app
ui <- navbarPage(
  title <- appName,
  
  mainPanel(
    tabsetPanel(tabPanel('Chart',
                         main_tab_ui('main_tab')),
                tabPanel('Map',
                         map_tab_ui('map_tab')),
                tabPanel('Data',
                         data_tab_ui('data_tab')),
                tabPanel('Help',
                         includeMarkdown('vignettes/help.md'))
                ))
)