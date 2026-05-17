library(testthat)
library(ReefMappeR)
library(terra)

bbox   <- c(150.56, 150.80, -21.51, -21.20)
result <- set_roi(bbox = bbox)

test_that("plot_habitat_map returns ggplot object", {
  p <- plot_habitat_map(result)
  expect_true(inherits(p, "gg") || inherits(p, "patchwork"))
})

test_that("plot_habitat_map runs without error", {
  expect_no_error(plot_habitat_map(result))
})

test_that("plot_habitat_map works with smooth = FALSE", {
  expect_no_error(plot_habitat_map(result, smooth = FALSE))
})
