#' Calculate Total Suspended Sediments (TSS) from Sentinel-2
#'
#' Estimates Total Suspended Sediments (TSS) from a Sentinel-2 Level-2A
#' surface reflectance image using a red/green band ratio algorithm.
#' A NIR-based water mask is applied to exclude land and non-water pixels.
#'
#' @param s2 A \code{terra::SpatRaster} object containing at least bands
#'   \code{"B3"} (green), \code{"B4"} (red), and \code{"B8"} (NIR) from a
#'   Sentinel-2 Level-2A product (surface reflectance, values 0--10000).
#'
#' @return A \code{SpatRaster} of estimated TSS in g/m\eqn{^3}, masked to
#'   water pixels only. The plot is displayed automatically.
#'
#' @details
#' TSS is derived from a red/green reflectance relationship of the form
#' \deqn{TSS = 1.47 \times (R_{red} / R_{green}) + 31.4 \times R_{red},}
#' where \eqn{R_{red}} and \eqn{R_{green}} are surface reflectances from
#' Sentinel-2 bands B4 and B3 respectively, scaled to 0--1.
#' Negative values are set to zero. A simple water mask is applied using
#' band B8 (NIR) with a threshold of 0.05; pixels above this threshold
#' are treated as non-water and set to \code{NA}.
#'
#' This algorithm is a generic coastal-water approximation and should be
#' locally validated and recalibrated with in-situ measurements before
#' use in quantitative analyses.
#'
#' @seealso \code{\link{calc_ndci}} for chlorophyll-a estimation.
#'
#' @examples
#' \dontrun{
#' s2 <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
#'                                package = "ReefMappeR"))
#' tss <- calc_tss(s2)
#' }
#'
#' @importFrom terra mask
#' @export
calc_tss <- function(s2) {
  B2 <- s2[["B2"]] / 10000  # Blue
  B3 <- s2[["B3"]] / 10000  # Green
  B4 <- s2[["B4"]] / 10000  # Red
  B8 <- s2[["B8"]] / 10000  # NIR

  TSS <- 1.47 * (B4 / B3) + 31.4 * B4
  TSS[TSS < 0] <- 0
  names(TSS) <- "TSS_gm3"

  water_mask <- B8 < 0.05
  TSS <- terra::mask(TSS, water_mask)
  terra::plot(TSS, main = "TSS (g/m\u00b3)")
  return(TSS)
}


