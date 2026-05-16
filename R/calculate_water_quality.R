#' Calculate TSS and CDOM from Sentinel-2
#'
#' Estimates Total Suspended Sediments (TSS) and Colored Dissolved Organic Matter (CDOM)
#' from a Sentinel-2 Level-2A surface reflectance image using simple coastal water
#' algorithms based on blue, green, red and NIR bands.
#'
#' The function expects a multi-band \code{SpatRaster} with at least bands
#' \code{B2} (blue), \code{B3} (green), \code{B4} (red) and \code{B8} (NIR),
#' with values in Sentinel-2 L2A reflectance units (0–10000), which are internally
#' scaled to 0–1. TSS is computed from a red/green relationship and CDOM from
#' a blue/red ratio. Negative values are set to zero and a simple NIR-based
#' water mask is applied to remove land and bright non-water pixels.
#'
#' @param s2 A \code{terra::SpatRaster} object containing at least the bands
#'   \code{"B2"}, \code{"B3"}, \code{"B4"} and \code{"B8"} from a Sentinel-2
#'   Level-2A product (surface reflectance).
#'
#' @return A list with two \code{SpatRaster} layers:
#' \itemize{
#'   \item \code{TSS}: Estimated total suspended sediments in g/m\eqn{^3}.
#'   \item \code{CDOM}: Estimated colored dissolved organic matter in m\eqn{^{-1}}.
#' }
#'
#' @details
#' TSS is derived from a red/green reflectance relationship of the form
#' \deqn{TSS = 1.47 * (R_{red} / R_{green}) + 31.4 * R_{red},}
#' where \eqn{R_{red}} and \eqn{R_{green}} are surface reflectances from
#' Sentinel-2 bands B4 and B3 respectively. CDOM is estimated from the blue/red
#' reflectance ratio using
#' \deqn{CDOM = -3.68 * \ln(R_{blue} / R_{red}) + 0.73,}
#' where \eqn{R_{blue}} is Sentinel-2 band B2. Both TSS and CDOM are set to zero
#' where the raw estimate is negative. A simple water mask is created using
#' band B8 (NIR) with a threshold of 0.05 reflectance; pixels above this
#' threshold are treated as non-water and set to \code{NA}.
#'
#' These algorithms are generic coastal-water approximations and should be
#' locally validated and, if necessary, recalibrated with in situ measurements
#' before use in quantitative analyses.
#'
#' @seealso \code{\link[terra]{rast}}, \code{\link[terra]{mask}}
#'
#' @examples
#' \dontrun{
#' library(terra)
#'
#' # Load Sentinel-2 L2A stack with bands B1–B12
#' s2 <- rast("path/to/S2_L2A_stack.tif")
#'
#' # Calculate TSS and CDOM
#' wq <- calculate_water_quality(s2)
#'
#' # Quick visualisation
#' plot(wq$TSS, main = "TSS (g/m^3)")
#' plot(wq$CDOM, main = "CDOM (m^-1)")
#' }
#'
calculate_water_quality <- function(s2) {
  B2 <- s2[["B2"]] / 10000  # Blue
  B3 <- s2[["B3"]] / 10000  # Green
  B4 <- s2[["B4"]] / 10000  # Red
  B8 <- s2[["B8"]] / 10000  # NIR

  TSS <- 1.47 * (B4 / B3) + 31.4 * B4
  TSS[TSS < 0] <- 0
  names(TSS) <- "TSS_gm3"

  ratio <- B2 / B4
  ratio[ratio == 0] <- 0.001
  CDOM <- -3.68 * log(ratio) + 0.73
  CDOM[CDOM < 0] <- 0
  names(CDOM) <- "CDOM_m1"

  water_mask <- B8 < 0.05
  TSS <- terra::mask(TSS, water_mask)
  CDOM <- terra::mask(CDOM, water_mask)

  return(list(TSS = TSS, CDOM = CDOM))
}


