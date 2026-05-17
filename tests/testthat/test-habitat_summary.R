library(testthat)
library(ReefMappeR)
library(terra)

# Use a small bbox to keep tests fast
bbox   <- c(150.56, 150.80, -21.51, -21.20)
result <- set_roi(bbox = bbox)

test_that("habitat_summary returns correct structure", {
  out <- habitat_summary(result)

  expect_type(out, "list")
  expect_named(out, c("table", "stats"))
  expect_named(out$stats, c("benthic", "geomorph", "seagrass"))
})

test_that("habitat_summary stats are data frames", {
  out <- habitat_summary(result)

  expect_s3_class(out$stats$benthic,  "data.frame")
  expect_s3_class(out$stats$geomorph, "data.frame")
})

test_that("habitat_summary benthic stats have correct columns", {
  out <- habitat_summary(result)

  expect_true("area_km2"   %in% names(out$stats$benthic))
  expect_true("pct_cover"  %in% names(out$stats$benthic))
  expect_true("mean_depth" %in% names(out$stats$benthic))
})

test_that("habitat_summary pct_cover sums to 100", {
  out <- habitat_summary(result)

  expect_equal(sum(out$stats$benthic$pct_cover), 100, tolerance = 0.1)
  expect_equal(sum(out$stats$geomorph$pct_cover), 100, tolerance = 0.1)
})
