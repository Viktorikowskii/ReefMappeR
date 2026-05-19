#' Calculate Normalized Difference Chlorophyll Index (NDCI)
#'
#' Computes the NDCI from a Sentinel-2 image using the red (B4) and red-edge (B5)
#' bands. NDCI is a spectral index designed to highlight chlorophyll-a concentration
#' in turbid, productive coastal and inland waters. It uses the normalized difference
#' between red-edge (705 nm) and red (665 nm) reflectance where water is particularly
#' sensitive to phytoplankton chlorophyll.
#'
#' @param s2 SpatRaster Sentinel-2 image containing at least B4 (red) and B5
#'   (red-edge) bands.
#' @param red_name Character name of the red band. If NULL, auto-detects "B4",
#'   "B04", or "red".
#' @param rededge_name Character name of the red-edge band. If NULL, auto-detects
#'   "B5", "B05", or "rededge".
#' @param verbose Logical; print available band names for inspection.
#'
#' @details
#' NDCI is calculated as: \deqn{NDCI = \frac{B5 - B4}{B5 + B4}}
#'
#' Value interpretation:
#' \itemize{
#'   \item{-1 to 0: Low chlorophyll-a, clear water or non-productive conditions}
#'   \item{0 to 0.3: Moderate chlorophyll-a, typical coastal waters}
#'   \item{>0.3: High chlorophyll-a, potential eutrophication or algal blooms}
#' }
#'
#' Exact chlorophyll-a concentrations require site-specific calibration with
#' in-situ measurements.
#'
#' @references
#' Mishra, S. & Mishra, D.R. (2012). Normalized difference chlorophyll index:
#' A novel model for remote sensing of chlorophyll-a concentration in turbid
#' productive waters. \emph{Remote Sensing of Environment}, 117, 394--406.
#' \doi{10.1016/j.rse.2011.10.016}
#'
#' @return SpatRaster with single NDCI layer (values -1 to 1).
#'
#' @examples
#' \dontrun{
#' # Auto-detect bands (works with B4/B5 or B04/B05 naming)
#' ndci <- calc_ndci(s2)
#' plot(ndci)
#'
#' # Explicit band names
#' ndci <- calc_ndci(s2, red_name = "B4", rededge_name = "B5")
#' }
#'
#' @export
calc_ndci <- function(s2,
                      red_name = NULL,
                      rededge_name = NULL,
                      verbose = TRUE) {

  if (!inherits(s2, "SpatRaster")) {
    stop("Input 's2' must be a terra SpatRaster.")
  }

  s2_names <- names(s2)

  if (verbose) {
    message("Bands in 's2':")
    print(s2_names)
  }

  # Auto-detect red band
  if (is.null(red_name)) {
    if ("B04" %in% s2_names) {
      red_name <- "B04"
    } else if ("B4" %in% s2_names) {
      red_name <- "B4"
    } else if ("red" %in% s2_names) {
      red_name <- "red"
    } else {
      stop("Could not auto-detect red band (e.g. 'B4'/'B04' or 'red'). ",
           "Please provide 'red_name'.")
    }
  }

  # Auto-detect red-edge band
  if (is.null(rededge_name)) {
    if ("B05" %in% s2_names) {
      rededge_name <- "B05"
    } else if ("B5" %in% s2_names) {
      rededge_name <- "B5"
    } else if ("rededge" %in% s2_names) {
      rededge_name <- "rededge"
    } else {
      stop("Could not auto-detect red-edge band (e.g. 'B5'/'B05'). ",
           "Please provide 'rededge_name'.")
    }
  }

  red     <- s2[[red_name]]
  rededge <- s2[[rededge_name]]

  ndci <- (rededge - red) / (rededge + red)
  names(ndci) <- "NDCI"
  terra::plot(ndci, main = "NDCI (Chlorophyll-a proxy)")
  ndci
}
