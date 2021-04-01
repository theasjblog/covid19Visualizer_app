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
  # app title from config
  title <- appName,
  # module for the chart
  tabPanel('Chart',
           main_tab_ui('main_tab')),
  # module for the map
  tabPanel('Map',
           map_tab_ui('map_tab')),
  # module for the data tables
  tabPanel('Data',
           data_tab_ui('data_tab')),
  # helper
  tabPanel('Help',
           includeMarkdown('vignettes/help.md'))
)
