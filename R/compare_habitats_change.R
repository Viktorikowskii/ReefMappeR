#' Compare habitat layers with NDCI change
#'
#' Plots geomorphic zone, benthic habitat, and NDCI change
#' stacked vertically for visual comparison.
#'
#' @param reef_data List. Output from set_roi() containing
#'   bathymetry, benthic, and geomorph SpatRasters.
#' @param ndci_change SpatRaster. Output from assess_reef_change().
#'
#' @return Invisible NULL. Called for side effects (plot).
#' @export
#'
#' @examples
#' \dontrun{
#' change <- assess_reef_change(ndci_result_24, ndci_result_25)
#' compare_habitats_change(example_a_24, change)
#' }
compare_habitats_change <- function(reef_data, ndci_change) {

  # Layout setzen: 3 Plots übereinander
  old_par <- par(mfrow = c(3, 1))
  on.exit(par(old_par))  # nach dem Plot automatisch zurücksetzen

  terra::plot(reef_data$geomorph,
              main = "Geomorphic Zones")

  terra::plot(reef_data$benthic,
              main = "Benthic Habitat")

  terra::plot(ndci_change,
              col  = colorRampPalette(c("#2ecc71", "white", "#e74c3c"))(100),
              main = "NDCI Change (green = improvement, red = degradation)")

  return(invisible(NULL))
}
