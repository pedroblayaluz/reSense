#Utils

#' This function contains formulas for calculating Vegatation indices from Landsat-8
#' @param multispectral.image A ee.Image object from which calculations will be made
#' @noRd
cloudbandmath <- function(multispectral.image){
  #AVI
  avi <- multispectral.image$expression('((NIR+65536) * (65536-RED) * (NIR-RED))' ,
                                        list('NIR'=multispectral.image$select('B5'),
                                             'RED'=multispectral.image$select('B4')))
  avi <- avi$abs()$pow(1/3)
  avi <- avi$rename('avi')
  #BSI
  bsi <- multispectral.image$expression(' ((RED+SWIR1) - (NIR+BLUE)) / ((RED+SWIR1) + (NIR+BLUE))',
                                        list('BLUE'=multispectral.image$select('B2'),
                                             'RED'=multispectral.image$select('B4'),
                                             'NIR'=multispectral.image$select('B5'),
                                             'SWIR1'=multispectral.image$select('B6')))
  bsi <- bsi$rename('bsi')
  #EVI
  evi <- multispectral.image$expression('163840 * ((NIR - RED) / (NIR + 393216 * RED - 491520 * BLUE))', #$'2.5 * ((NIR - RED) / (NIR + 6 * RED - 7.5 * BLUE))',
                                        list('NIR'=multispectral.image$select('B5'),
                                             'RED'=multispectral.image$select('B4'),
                                             'BLUE'=multispectral.image$select('B2')))
  evi <- evi$rename('evi')
  #MSAVI2
  msavi2 <- multispectral.image$expression('(2 * NIR + 1 - sqrt(pow((2 * NIR + 1), 2) - 8 * (NIR - RED)) ) / 2',
                                           list('NIR'=multispectral.image$select('B5'),
                                                'RED'=multispectral.image$select('B4')))
  msavi2 <- msavi2$rename('msavi2')
  #NDMI
  #ndmi<- multispectral.image$normalizedDifference(c('B5', 'B6'))
  ndmi <- multispectral.image$expression('(NIR-SWIR1) / (NIR+SWIR1)',
                                         list('NIR'=multispectral.image$select('B5'),
                                              'SWIR1'=multispectral.image$select('B6')))
  ndmi <- ndmi$rename('ndmi')
  #NDVI
  ndvi<-multispectral.image$normalizedDifference(c('B5', 'B4'))
  ndvi <- ndvi$rename('ndvi')
  #NDWI
  ndwi<- multispectral.image$normalizedDifference(c('B3', 'B5'))
  ndwi <- ndwi$rename('ndwi')
  #OSAVI
  osavi <- multispectral.image$expression('(NIR-RED) / (NIR+RED+0.16)',
                                          list('NIR'=multispectral.image$select('B5'),
                                               'RED'=multispectral.image$select('B4')))
  osavi <- osavi$rename('osavi')
  #SATVI
  satvi <- multispectral.image$expression('(SWIR2 - RED)/(SWIR1 + RED + 0.5) * (1 + 0.5) - (SWIR2/2)',
                                          list('RED'=multispectral.image$select('B4'),
                                               'NIR'=multispectral.image$select('B5'),
                                               'SWIR1'=multispectral.image$select('B6'),
                                               'SWIR2'=multispectral.image$select('B7')))
  satvi <- satvi$rename('satvi')
  #SI
  si <- multispectral.image$expression('( (65536 - RED) * (65536 - GREEN) * (65536 - BLUE) )',
                                       list('BLUE'=multispectral.image$select('B2'),
                                            'GREEN'=multispectral.image$select('B3'),
                                            'RED'=multispectral.image$select('B4')))
  si <- si$abs()$pow(1/3)
  si <- si$rename('si')
  #Returning all bands + indices
  stacked <- multispectral.image$
    addBands(avi)$addBands(bsi)$addBands(evi)$
    addBands(msavi2)$addBands(ndmi)$addBands(ndvi)$
    addBands(ndwi)$addBands(osavi)$addBands(satvi)$
    addBands(si)
  return(stacked)
}

#' Gets Dates for Landsat Scene Names
#' @param input Either a data.frame or a list containing Rasters.
#' @noRd
datesFromNames <- function(input){
  if(class(input) == 'list'){
    #Get dates from raster.list names
    dates <- as.Date(lastletters(names(input),8),"%Y%m%d")
    #Apply to all elements
    for (i in length(input)) {
      input[[i]] <- setZ(x=input[[i]],
                         z=rep(x=dates[i],times=nlayers(input[[i]])))
    }
  } else if(class(input) == 'data.frame'){
    input$date <- as.Date(lastletters(input$scene_id,8),"%Y%m%d")
  }else message('Object class not supported')
  return(input)
}

#Extract last letters from strings
#' @noRd
lastletters <- function(x, n){
  substr(x, nchar(x)-n+1, nchar(x))
}
