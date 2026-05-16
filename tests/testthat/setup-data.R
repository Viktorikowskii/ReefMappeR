library(terra)
library(sf)

# Shared Cairns data paths
cairns_paths <- list(
  bathymetry = "/Volumes/Crucial X9/EAGLE Master/Introduction_to_Programming_1/Data_Ocean/gebco_2024/GEBCO_2024.nc",
  seagrass = "/Volumes/Crucial X9/EAGLE Master/Introduction_to_Programming_1/Data_Ocean/Seagrass2021_v7_1/01_Data/WCMC013_014_Seagrasses_Py_v7_1.shp",
  benthic = "/Volumes/Crucial X9/EAGLE Master/Introduction_to_Programming_1/Data_Ocean/Cairns_benthic.tif"
)

cairns_bbox <- st_bbox(c(xmin=145.4, ymin=-17.2, xmax=146.1, ymax=-16.6), crs=4326)


set_roi(cairns_bbox, bathymetry = bathymetry, seagrass, benthic)
