#' Assess reef change between two NDCI rasters
#'
#' @param ndci_t1 SpatRaster. NDCI at time 1 (e.g. Summer 2024).
#' @param ndci_t2 SpatRaster. NDCI at time 2 (e.g. Summer 2025).
#'
#' @return A SpatRaster with pixel-wise NDCI difference (t2 minus t1).
#'   Positive values indicate increased chlorophyll (degradation),
#'   negative values indicate decreased chlorophyll (improvement).
#' @export
assess_reef_change <- function(ndci_t1, ndci_t2) {

  if (!terra::compareGeom(ndci_t1, ndci_t2, stopOnError = FALSE)) {
    message("Resampling ndci_t2 to match ndci_t1...")
    ndci_t2 <- terra::resample(ndci_t2, ndci_t1)
  }

  change <- ndci_t2 - ndci_t1
  names(change) <- "ndci_change"

  # Plot mit divergierender Farbskala
  terra::plot(change,
              col = colorRampPalette(c("#2ecc71", "white", "#e74c3c"))(100),
              main = "NDCI Change (green = improvement, red = degradation)"
  )

  return(invisible(change))
}
