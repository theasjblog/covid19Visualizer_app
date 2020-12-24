# load dependencies
source('dependencies.R')
# load general app configuration i.e. app name and version
source('config.R')
# source supporting functions. These should be an independent package
for (i in list.files('./auxFunctions')) {
  source(paste0('./auxFunctions/', i))
}

# source modules
for (i in list.files('./modules')) {
  source(paste0('./modules/', i))
}

# define ui of the main app
ui <- navbarPage(
  title = appName,
  tabPanel('Main',
           # tab with the line plots
           main_tab_ui('main_tab'),),
  tabPanel('Maps',
           # tab with maps
           maps_tab_ui('maps_tab')),
  tabPanel('Help',
           # help tab
           includeMarkdown('vignettes/help.md'))
)