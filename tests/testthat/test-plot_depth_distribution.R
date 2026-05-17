library(testthat)
library(ReefMappeR)
library(terra)

bbox   <- c(150.56, 150.80, -21.51, -21.20)
result <- set_roi(bbox = bbox)

test_that("plot_depth_distribution returns patchwork object", {
  p <- plot_depth_distribution(result)
  expect_true(inherits(p, "patchwork") || inherits(p, "gg"))
})

test_that("plot_depth_distribution runs without error", {
  expect_no_error(plot_depth_distribution(result))
})
