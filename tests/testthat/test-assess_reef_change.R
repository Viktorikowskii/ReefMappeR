library(testthat)
library(ReefMappeR)
library(terra)

test_that("assess_reef_change returns SpatRaster named ndci_change", {
  s2_24  <- terra::rast(system.file("extdata", "Sentinel2_2024_example.tif",
                                    package = "ReefMappeR"))
  s2_25  <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                    package = "ReefMappeR"))
  ndci_24 <- calc_ndci(s2_24, verbose = FALSE)
  ndci_25 <- calc_ndci(s2_25, verbose = FALSE)
  change  <- assess_reef_change(ndci_24, ndci_25)

  expect_s4_class(change, "SpatRaster")
  expect_equal(names(change), "ndci_change")
})

test_that("assess_reef_change output has same extent as input", {
  s2_24  <- terra::rast(system.file("extdata", "Sentinel2_2024_example.tif",
                                    package = "ReefMappeR"))
  s2_25  <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                    package = "ReefMappeR"))
  ndci_24 <- calc_ndci(s2_24, verbose = FALSE)
  ndci_25 <- calc_ndci(s2_25, verbose = FALSE)
  change  <- assess_reef_change(ndci_24, ndci_25)

  expect_equal(terra::ext(change), terra::ext(ndci_24))
})

test_that("assess_reef_change difference is t2 minus t1", {
  s2_24  <- terra::rast(system.file("extdata", "Sentinel2_2024_example.tif",
                                    package = "ReefMappeR"))
  s2_25  <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                    package = "ReefMappeR"))
  ndci_24 <- calc_ndci(s2_24, verbose = FALSE)
  ndci_25 <- calc_ndci(s2_25, verbose = FALSE)
  change  <- assess_reef_change(ndci_24, ndci_25)

  expected_mean <- terra::global(ndci_25 - ndci_24, "mean", na.rm = TRUE)[[1]]
  actual_mean   <- terra::global(change, "mean", na.rm = TRUE)[[1]]
  expect_equal(actual_mean, expected_mean, tolerance = 1e-6)
})
