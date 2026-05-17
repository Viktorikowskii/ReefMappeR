library(testthat)
library(ReefMappeR)
library(terra)

test_that("calculate_water_quality returns SpatRaster", {
  s2  <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                 package = "ReefMappeR"))
  tss <- calculate_water_quality(s2)

  expect_s4_class(tss, "SpatRaster")
})

test_that("calculate_water_quality TSS values are non-negative", {
  s2  <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                 package = "ReefMappeR"))
  tss <- calculate_water_quality(s2)

  expect_true(terra::global(tss, "min", na.rm = TRUE)[[1]] >= 0)
})

test_that("calculate_water_quality returns layer named TSS_gm3", {
  s2  <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                 package = "ReefMappeR"))
  tss <- calculate_water_quality(s2)

  expect_equal(names(tss), "TSS_gm3")
})
