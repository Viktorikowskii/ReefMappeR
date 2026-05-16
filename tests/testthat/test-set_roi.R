library(testthat)


test_that("set_roi returns correct structure", {
  full_bathymetry <- rast(cairns_paths$bathymetry)
  full_seagrass <- st_read(cairns_paths$seagrass)
  full_benthic <- cairns_paths$benthic

  roi_result <- set_roi(cairns_bbox, full_bathymetry, full_seagrass, full_benthic)

  expect_s4_class(roi_result$bathymetry, "SpatRaster")
  expect_s3_class(roi_result$seagrass, "sf")
  expect_s4_class(roi_result$benthic, "SpatRaster")
})

test_that("set_roi crops data correctly", {
  full_bathymetry <- rast(cairns_paths$bathymetry)
  full_seagrass <- st_read(cairns_paths$seagrass)
  full_benthic <- cairns_paths$benthic

  roi_result <- set_roi(cairns_bbox, full_bathymetry, full_seagrass, full_benthic)

  expect_true(all(ext(roi_result$bathymetry) <= ext(full_bathymetry)))
  expect_true(all(is.na(values(roi_result$benthic)[values(roi_result$benthic) == 0])))
})

test_that("set_roi stable output (snapshot)", {
  full_bathymetry <- rast(cairns_paths$bathymetry)
  full_seagrass <- st_read(cairns_paths$seagrass)
  full_benthic <- cairns_paths$benthic

  result <- set_roi(cairns_bbox, full_bathymetry, full_seagrass, full_benthic)
  expect_snapshot(result)
})

