library(testthat)
library(ReefMappeR)
library(terra)

test_that("calc_ndci returns SpatRaster named NDCI", {
  s2   <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                  package = "ReefMappeR"))
  ndci <- calc_ndci(s2, verbose = FALSE)

  expect_s4_class(ndci, "SpatRaster")
  expect_equal(names(ndci), "NDCI")
})

test_that("calc_ndci values are between -1 and 1", {
  s2   <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                  package = "ReefMappeR"))
  ndci <- calc_ndci(s2, verbose = FALSE)

  expect_true(terra::global(ndci, "max", na.rm = TRUE)[[1]] <= 1)
  expect_true(terra::global(ndci, "min", na.rm = TRUE)[[1]] >= -1)
})

test_that("calc_ndci stops with wrong input", {
  expect_error(calc_ndci("not_a_raster"), "must be a terra SpatRaster")
})

test_that("calc_ndci auto-detects B4 and B5 bands", {
  s2   <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                  package = "ReefMappeR"))
  expect_no_error(calc_ndci(s2, verbose = FALSE))
})
