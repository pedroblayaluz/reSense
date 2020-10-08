#' Shapefile to Earth Engine Polygon
#'
#' This function receives an Earth Engine Polygon, gets Landsat-8
#' multispectral images and calculates VIs for that location.
#' (in development) argument to choose which VIs to calculate and
#' date filtering functionalities will soon be added.
#' *Some of the VIs (AVI, EVI, SATVI and SI) might have errors and need to be reviewd.
#'
#' @param ee.geometry Google Earth Engine Object ee.Geometry.Polygon
#' @param start.date A string containing the date (YYYY-MM-DD) at which
#' to start gathering images, defaults to '2013-01-01' (beginning of Landsat-8 dataset).
#' @param end.date A string containing the date (YYYY-MM-DD) at which
#' to end gathering images, defaults to current system date.

#' @return a data.frame containing all band values and calculated VIs.
#' @export
#' @examples
#' ee.geometry <- shpToEE(shapefile="D:/Folder/shapefile.shp")
#' landsat.data.frame <- senseLandsat(ee.geometry)
senseLandsat <- function(ee.geometry,
                         start.date='2013-01-01',
                         end.date=as.character(Sys.Date())){
  #Google Earth Engine ImageCollection
  collection<- ee$ImageCollection("LANDSAT/LC08/C01/T1")$
    filterBounds(ee.geometry)$
    select('B2','B3')$
    filterDate(start.date, end.date)
  #Extract infos from ImageCollection
  geom.scale <- collection$first()$projection()$nominalScale()$getInfo() #Get ImageCollection scale
  scene.ids <- collection$aggregate_array('system:id')$getInfo() #Getting scene IDs
  raster.list <- list()
  pb <- txtProgressBar(min = 1, max = length(scene.ids), style = 3)
  for (i in 1:length(scene.ids)) {
    #Getting image
    scene.image <- ee$Image(scene.ids[[i]])
    bands.plus.indices <- cloudbandmath(scene.image)
    #Reducing image (in form of dictionary) and getting lon lat
    reduced.image.dictionary <- bands.plus.indices$
      pixelLonLat()$
      addBands(bands.plus.indices)$
      reduceRegion(reducer   = ee$Reducer$toList(),
                   geometry  = ee.geometry,
                   scale     = geom.scale)

    #Extracting information from image
    infos <- reduced.image.dictionary$getInfo()

    #Adjusting data frame
    infos.df <- as.data.frame(rlist::list.cbind(infos))

    #Renaming longitude and latitude to x and y
    names(infos.df)[names(infos.df) == 'longitude'] <- 'x'
    names(infos.df)[names(infos.df) == 'latitude'] <- 'y'

    #Creating scene_id column
    col.scene.id <- as.data.frame(rep(scene.ids[i],dim(infos.df)[1]))
    names(col.scene.id) <- 'scene_id'
    infos.df <- cbind(col.scene.id,infos.df)

    #Reordering columns
    export.data.frame <- infos.df[,c(grep('x',colnames(infos.df)), #First X
                                     grep('y',colnames(infos.df)), #Then Y
                                     (1:length(infos.df))[-c(grep('x',colnames(infos.df)),
                                                             grep('y',colnames(infos.df)))])] #Then every other one except X and Y
    setTxtProgressBar(pb, i)
    #Output to data.frame
    if(i==1){
      output.df <- export.data.frame
    }else{
      output.df <- rbind(output.df,export.data.frame)
    }
  }
  #Cloudmask
  returned.data.frame <- output.df %>% dplyr::filter(BQA %in% c(2720,2724,2728,2732))
  returned.data.frame <- datesFromNames(returned.data.frame)
  return(returned.data.frame)
}
