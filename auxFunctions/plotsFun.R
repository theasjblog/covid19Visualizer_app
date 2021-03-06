#' @title getPlotData
#' @description get plot data for the events plot
#' @param events (data.frame) events dataframe
#' @param population (data.frame) population dataframe
#' @param normBy (character) name of the column to use in population
#' @param multiplyFactor (numeric) positive integer
#' @return events data frame ready for plot 
getPlotData <- function(events, population, normBy=NULL, multiplyFactor = 1){
  # fill nas
  events <- fillNAs(events)
  # add text for plotly
  events$text <- paste0('Date: ', as.character(events$date), '\n',
                        'Country: ', events$Country, '\n',
                        str_to_title(events$variable), ': ', events$value)
  # do we normalise?
  if(!is.null(normBy)){
    # normalise
    events <- normaliseEvents(events, population,
                              normBy, multiplyFactor)
    # if we normalise, use that info as plot title
    events$normalisation <- paste0('Normalized by: ', normBy,'*',multiplyFactor)
  }
  
  return(events)
}

#' @title getText
#' @description add a column of text for plotly to a dataframe
#' @param df (dataframe)
#' @return dataframe
getText <- function(df){
  df$text <- paste0('Country: ', df$Country, '\n',
                    df$variable, ': ', round(df$value, 3), '\n',
                    'Date: ', as.character(df$date))
  
  return(df)
}

#' @title doPlot
#' @description plot events data
#' @param df (data.frame) events dataframe from getPlotData
#' @param reScale (boolean) if rescaling in the 0-1 range
#' @return ggplot 
#' @export
doPlot <- function(df, reScale = FALSE){
  df <- getText(df)
  # rescale
  if (reScale){
    df <- df %>% group_by(Country,variable) %>% 
      mutate(across(value, scales::rescale))
  }
  
  # if we ran a prediction, plot it separately
  if ('category' %in% colnames(df)){
    # separate the data
    pred_df <- df %>% filter(category %in% 'prediction')
    df <- df %>% filter(!category %in% 'prediction')
  } 
  # plot the data
  p <- ggplot(df, aes(x = date,
                      y = value,
                      group = interaction(Country, variable),
                      colour = interaction(Country, variable),
                      text = text))
  
  p <- p +
    geom_line()
  
  if ('category' %in% colnames(df)){
    # plot the predictions, if available
    p <- p +
      geom_line(data = pred_df,
                aes(x = date,
                    y = value,
                    colour = interaction(Country, variable)
                    ),
                linetype='dashed')
  } 
  
  ## style the plot
  p <- p +
    labs(x = '',
         y = '',
         title = '') +
    theme_minimal()  +
    scale_y_continuous(labels = function(x) format(x, 
                                                   big.mark = ',',
                                                   scientific = FALSE)) +
    theme(legend.position="bottom")
  if (reScale){
    # if we rescale, remove y labels as units become meaningless
    p <- p +
      theme(axis.title.y = element_blank(),
            axis.text.y = element_blank(),
            axis.ticks.y = element_blank())
  }
  
  return(p)
}

#' @title eventsPlot
#' @description plot events data
#' @param events (data.frame) events dataframe
#' @param population (data.frame) population dataframe
#' @param normBy (character) name of the column to use in population
#' @param multiplyFactor (numeric) positive integer
#' @return ggplot 
#' @export
eventsPlot <- function(events, population, normBy=NULL, multiplyFactor = 1){
  # prepare data
  df <- getPlotData(events, population, normBy, multiplyFactor)
  # get plot
  p <- doPlot(df)
  
  return(p)
}

#' @title populationPlot
#' @description plot population data
#' @param population (data.frame) population dataframe
#' @param variables (character) vector of column names to plot
#' @return ggplot 
#' @export
populationPlot <- function(population, variables){
  # columns to keep
  a <- population %>% filter(variable %in% variables)
  # the text to use in plotly tooltips
  a$text <- paste0('Country: ', a$Country, '\n',
                   a$variable, ': ', a$value)
  # variables might have massively different ranges,
  # for instance age vs population. To ensure everything
  # is visible in the plot we normalise each variable
  # in the range 0-1
  a <- split(a, a$variable)
  a <- lapply(a, function(d){
    #normalize up to 1
    d$value <- d$value/max(d$value, na.rm = TRUE)
    return(d)
  })
  a <- bind_rows(a)
  
  # the actual plot
  p <- ggplot(data=a, aes(x=variable, y=value, fill=Country, text = text)) +
    geom_bar(stat="identity", position=position_dodge()) +
    labs(title = '') +
    theme_minimal() +
    theme(axis.title.y=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks.y=element_blank(),
          axis.title.x=element_blank(),
          axis.text.x = element_text(size=8, angle=45))
  
  return(p)
}
