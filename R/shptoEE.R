#' Shapefile to Earth Engine Polygon
#'
#' This function converts a Shapefile (.shp) to a
#' Google Earth Engine Polygon (ee.Geometry.Polygon)
#' @param shapefile Path to a .shp file
#' @param df Generates a EE geometry from a data.frame in which the first two columns are x and y
#' @return Google Earth Engine Polygon
#' @export
#' @examples
#' ee.geometry <- shpToEE(shapefile="D:/Folder/shapefile.shp")
#'
#'
#Shapefile to Earth Engine Geometry
shpToEE <- function(shapefile,df=F){
  if(df==T){
    shapefile.polygon <- as.matrix(shapefile[,c(1,2)])
  }else{
  shapefile.st <- sf::st_read(shapefile) #Read shapefile
  shapefile.polygon <- shapefile.st[[2]][[1]][[1]]
  }
  shapefile.list <- split(shapefile.polygon, seq(nrow(shapefile.polygon)))
  names(shapefile.list) <- NULL
  shapefile.ee.geometry <- rgee::ee$Geometry$Polygon(shapefile.list)
  return(shapefile.ee.geometry)
}
