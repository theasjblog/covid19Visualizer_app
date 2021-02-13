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
  title = appName,
  tabPanel('Main',
           # tab with the line plots
           main_tab_ui('main_tab'),),
  tabPanel('Help',
           # help tab
           includeMarkdown('vignettes/help.md'))
)