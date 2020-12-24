library(dplyr)
library(stringr)
saveAllData <- function(branchName = 'master'){
# remove old version of covid19Visualizer ---------------------------------
  listFiles <- list.files('./auxFunctions')
  for (i in listFiles){
    if (i != 'refreshApp.R'){
      file.remove(paste0('./auxFunctions/', i))
    }
  }

# get newest version of covid19Visualizer ---------------------------------
  # ideally we deploy installing the package,
  # but shinyapps.io fails to do that
  download.file(url = paste0("https://github.com/theasjblog/covid19_package/archive/",branchName,".zip")
                , destfile = "covid19Package.zip")
  unzip(zipfile = "covid19Package.zip")
  
  listFiles <- list.files(paste0('./covid19_package-',branchName,'/R'))
  for (i in listFiles){
    file.copy(from = paste0('./covid19_package-', branchName, '/R/', i), 
              to = paste0('./auxFunctions/', i), 
              overwrite = TRUE)
  }
  
  # get net JHU data --------------------------------------------------------
  listFiles <- list.files('./auxFunctions')
  for (i in listFiles){
    source(paste0('./auxFunctions/', i))
  }
  refreshJHU()
  allData <- getJHU()
  saveRDS(allData, './data/allData.rds')
  

# clean up ----------------------------------------------------------------
  file.remove('covid19Package.zip')
  unlink(paste0('./covid19_package-', branchName),
         recursive=TRUE)
  file.remove('JHUData-master.zip')
  unlink('./COVID-19-master',
         recursive=TRUE)
}
