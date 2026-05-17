library(testthat)
library(ReefMappeR)
library(terra)

# ── set_roi() ─────────────────────────────────────────────────────────────────

test_that("set_roi returns correct structure with bbox", {
  bbox   <- c(150.56, 150.80, -21.51, -21.20)
  result <- set_roi(bbox = bbox)

  expect_type(result, "list")
  expect_named(result, c("bathymetry", "benthic", "geomorph", "seagrass"))
  expect_s4_class(result$bathymetry, "SpatRaster")
  expect_s4_class(result$benthic,    "SpatRaster")
  expect_s4_class(result$geomorph,   "SpatRaster")
})

test_that("set_roi crops to bbox extent", {
  bbox   <- c(150.56, 150.80, -21.51, -21.20)
  result <- set_roi(bbox = bbox)

  expect_true(terra::nrow(result$bathymetry) > 0)
  expect_true(terra::ncol(result$bathymetry) > 0)
  expect_true(terra::nrow(result$benthic) > 0)
})

test_that("set_roi works with Sentinel-2 image", {
  s2     <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                    package = "ReefMappeR"))
  result <- set_roi(s2 = s2)

  expect_type(result, "list")
  expect_s4_class(result$bathymetry, "SpatRaster")
  expect_s4_class(result$benthic,    "SpatRaster")
})

test_that("set_roi stops when neither s2 nor bbox provided", {
  expect_error(set_roi(), "Either 's2' or 'bbox' must be provided")
})

# ── calc_ndci() ───────────────────────────────────────────────────────────────

test_that("calc_ndci returns SpatRaster with values between -1 and 1", {
  s2   <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                  package = "ReefMappeR"))
  ndci <- calc_ndci(s2, verbose = FALSE)

  expect_s4_class(ndci, "SpatRaster")
  expect_equal(names(ndci), "NDCI")
  expect_true(terra::global(ndci, "max", na.rm = TRUE)[[1]] <= 1)
  expect_true(terra::global(ndci, "min", na.rm = TRUE)[[1]] >= -1)
})

# ── assess_reef_change() ──────────────────────────────────────────────────────

test_that("assess_reef_change returns SpatRaster", {
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

# ── calculate_water_quality() ─────────────────────────────────────────────────

test_that("calculate_water_quality returns SpatRaster", {
  s2  <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                 package = "ReefMappeR"))
  tss <- calculate_water_quality(s2)

  expect_s4_class(tss, "SpatRaster")
  expect_true(terra::global(tss, "min", na.rm = TRUE)[[1]] >= 0)
})
