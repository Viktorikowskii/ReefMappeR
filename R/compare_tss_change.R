#' Temporal TSS Change Classification
#'
#' Classifies pixel-wise TSS change between two time points into three
#' categories: increase in suspended sediments, no significant change, and
#' decrease in suspended sediments.
#'
#' @param tss_change SpatRaster. Output of [assess_reef_change()] applied to
#'   two TSS rasters from [calculate_water_quality()].
#' @param threshold Numeric. Minimum absolute TSS change (g/m³) to be
#'   considered significant. Default is 0.5. See Details.
#'
#' @return Invisible NULL. Called for side effects (plot).
#'
#' @details
#' TSS change is classified into three classes:
#' \itemize{
#'   \item \strong{TSS increase} (change > +threshold): Indicates increased
#'     suspended sediment load, potentially associated with storm events,
#'     dredging, or increased runoff from land.
#'   \item \strong{No significant change} (|change| <= threshold): Change
#'     within the defined threshold, interpreted as natural variability.
#'   \item \strong{TSS decrease} (change < -threshold): Indicates reduced
#'     suspended sediment load, potentially reflecting calmer conditions or
#'     reduced terrestrial input.
#' }
#'
#' The default threshold of 0.5 g/m³ is an exploratory convention. No
#' universally established threshold exists for TSS change classification.
#' Users are encouraged to adjust based on local conditions and in-situ
#' measurements.
#'
#' @references
#' Alvarez-Romero, J.G. et al. (2013). Quantifying the effects of
#' terrestrial runoff on coral reefs. \emph{PLoS ONE}, 8(11), e78689.
#' \doi{10.1371/journal.pone.0078689}
#'
#' @seealso [calculate_water_quality()], [assess_reef_change()]
#'
#' @importFrom terra classify plot
#' @export
#'
#' @examples
#' \dontrun{
#' s2_24  <- terra::rast(system.file("extdata", "Sentinel2_2024_example.tif",
#'                                    package = "ReefMappeR"))
#' s2_25  <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
#'                                    package = "ReefMappeR"))
#' tss_24 <- calculate_water_quality(s2_24)
#' tss_25 <- calculate_water_quality(s2_25)
#' change <- assess_reef_change(tss_24, tss_25)
#' compare_tss_change(change)
#' compare_tss_change(change, threshold = 1.0)
#' }
compare_tss_change <- function(tss_change, threshold = 0.5) {

  rcl <- matrix(c(
    -Inf,       -threshold, 1,
    -threshold,  threshold, 2,
    threshold,  Inf,       3
  ), ncol = 3, byrow = TRUE)

  change_class <- terra::classify(tss_change, rcl)

  terra::plot(
    change_class,
    col    = c("#2ecc71", "#f5f5f5", "#e74c3c"),
    type   = "classes",
    levels = c("TSS decrease", "No significant change", "TSS increase"),
    main   = paste0("Temporal TSS Change Classification",
                    " (threshold = \u00b1", threshold, " g/m\u00b3)")
  )

  invisible(NULL)
}
