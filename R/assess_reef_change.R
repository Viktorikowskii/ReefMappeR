#' Assess reef change between two NDCI rasters
#'
#' Computes pixel-wise NDCI difference between two time points to detect
#' temporal changes in chlorophyll-a concentration over reef areas.
#'
#' @param ndci_t1 SpatRaster. NDCI at time 1, output of [calc_ndci()].
#' @param ndci_t2 SpatRaster. NDCI at time 2, output of [calc_ndci()].
#'
#' @return A SpatRaster of pixel-wise NDCI difference (t2 minus t1).
#'   Positive values indicate increased chlorophyll-a, negative values
#'   indicate decreased chlorophyll-a. Pass the result to
#'   [compare_habitats_change()] for visualisation.
#'
#' @details
#' The NDCI difference is calculated as:
#' \deqn{\Delta NDCI = NDCI_{t2} - NDCI_{t1}}
#'
#' If the two rasters do not share the same geometry, \code{ndci_t2} is
#' automatically resampled to match \code{ndci_t1} using bilinear
#' interpolation. For meaningful change detection, both images should be
#' from the same season to minimise phenological differences, and
#' pre-processed to surface reflectance (Sentinel-2 Level-2A).
#'
#' @references
#' Mishra, S. & Mishra, D.R. (2012). Normalized difference chlorophyll index:
#' A novel model for remote sensing of chlorophyll-a concentration in turbid
#' productive waters. \emph{Remote Sensing of Environment}, 117, 394--406.
#' \doi{10.1016/j.rse.2011.10.016}
#'
#' @seealso [calc_ndci()], [compare_habitats_change()]
#'
#' @importFrom terra compareGeom resample
#' @export
#'
#' @examples
#' \dontrun{
#' s2_24  <- terra::rast(system.file("extdata", "Sentinel2_2024_example.tif",
#'                                    package = "ReefMappeR"))
#' s2_25  <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
#'                                    package = "ReefMappeR"))
#' change <- assess_reef_change(calc_ndci(s2_24), calc_ndci(s2_25))
#' compare_habitats_change(change)
#' }
assess_reef_change <- function(ndci_t1, ndci_t2) {

  if (!terra::compareGeom(ndci_t1, ndci_t2, stopOnError = FALSE)) {
    message("Resampling ndci_t2 to match ndci_t1...")
    ndci_t2 <- terra::resample(ndci_t2, ndci_t1)
  }

  change <- ndci_t2 - ndci_t1
  names(change) <- "ndci_change"

  change
}
