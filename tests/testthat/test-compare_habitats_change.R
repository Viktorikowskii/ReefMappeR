library(testthat)
library(ReefMappeR)
library(terra)

s2_24  <- terra::rast(system.file("extdata", "Sentinel2_2024_example.tif",
                                  package = "ReefMappeR"))
s2_25  <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                  package = "ReefMappeR"))
ndci_24 <- calc_ndci(s2_24, verbose = FALSE)
ndci_25 <- calc_ndci(s2_25, verbose = FALSE)
change  <- assess_reef_change(ndci_24, ndci_25)

test_that("compare_habitats_change runs without error", {
  expect_no_error(compare_habitats_change(change))
})

test_that("compare_habitats_change works with custom threshold", {
  expect_no_error(compare_habitats_change(change, threshold = 0.05))
})

test_that("compare_habitats_change returns invisible NULL", {
  result <- compare_habitats_change(change)
  expect_null(result)
})
