#' Shapefile to Earth Engine Polygon
#'
#' This function converts a Shapefile (.shp) to a
#' Google Earth Engine Polygon (ee.Geometry.Polygon)
#' @param shapefile Path to a .shp file
#' @return Google Earth Engine Polygon
#' @export
#' @examples
#' ee.geometry <- shpToEE(shapefile="D:/Dropbox/Science/reSense/data/hudson.shp")
#'
#'
#Shapefile to Earth Engine Geometry
shpToEE <- function(shapefile){
  shapefile.st <- sf::st_read(shapefile) #Read shapefile
  shapefile.polygon <- shapefile.st[[2]][[1]][[1]]
  shapefile.list <- split(shapefile.polygon, seq(nrow(shapefile.polygon)))
  names(shapefile.list) <- NULL
  shapefile.ee.geometry <- rgee::ee$Geometry$Polygon(shapefile.list)
  return(shapefile.ee.geometry)
}
