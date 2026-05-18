#' Side-by-side habitat maps: benthic habitats and geomorphology
#'
#' Creates a two-panel map with bathymetry as background and Allen Coral Atlas
#' benthic habitats (left) and geomorphic zones (right). Applies auto-aggregation
#' to prevent RAM issues, optional focal smoothing, and resamples to a regular
#' grid for seamless rendering.
#'
#' @param result Named list returned by [set_roi()], containing `bathymetry`,
#'   `benthic`, `geomorph`, and `seagrass`.
#' @param smooth Logical. Apply 5x5 focal mean smoothing to bathymetry before
#'   plotting? Default: `TRUE`.
#' @param agg_fact Positive integer or `NULL` (default). Aggregation factor
#'   applied before smoothing. If `NULL`, chosen automatically to keep the
#'   raster below ~500k pixels. Set explicitly to override.
#'
#' @return A patchwork/ggplot2 object combining both panels.
#'
#'#' @details
#' Benthic and geomorphic classifications follow the Allen Coral Atlas (ACA)
#' global mapping scheme. The benthic layer covers areas shallower than 10 m,
#' the geomorphic layer areas shallower than 15 m. Auto-aggregation reduces
#' memory usage by downsampling large rasters before plotting; categorical
#' layers use modal aggregation to preserve class integrity.
#'
#' @references
#' Allen Coral Atlas (2020). Coral reefs of the world.
#' \url{https://allencoralatlas.org}
#'
#' Lyons, M.B. et al. (2020). Mapping the world's coral reefs using a global
#' multiscale earth observation framework. \emph{Remote Sensing in Ecology
#' and Conservation}, 6(4), 557--568. \doi{10.1002/rse2.157}
#'
#' @seealso [set_roi()], [habitat_summary()], [plot_depth_distribution()]
#'
#' @importFrom terra focal aggregate resample rast ext nrow ncol crs as.data.frame res
#' @importFrom sf st_as_sf
#' @import ggplot2 dplyr ggnewscale patchwork
#' @export
#'
#' @examples
#' \dontrun{
#' bbox   <- c(150.56, 151.30, -21.51, -20.77)
#' result <- set_roi(bbox = bbox)
#' plot_habitat_map(result)
#' }
plot_habitat_map <- function(result, smooth = TRUE, agg_fact = NULL) {

  # Auto-aggregation to keep ggplot2 data frame below ~500k pixels
  n_pixels      <- terra::nrow(result$benthic) * terra::ncol(result$benthic)
  target_pixels <- 500000L

  if (is.null(agg_fact)) {
    agg_fact <- max(1L, as.integer(ceiling(sqrt(n_pixels / target_pixels))))
    if (agg_fact > 1L) {
      message(sprintf(
        "Auto-aggregating by factor %d (%s pixels → target <= %s).",
        agg_fact,
        formatC(n_pixels,      format = "d", big.mark = ","),
        formatC(target_pixels, format = "d", big.mark = ",")
      ))
    }
  } else {
    agg_fact <- max(1L, as.integer(agg_fact))
  }

  # Aggregate before smoothing to reduce RAM usage
  if (agg_fact > 1L) {
    bathy_ag    <- terra::aggregate(result$bathymetry, fact = agg_fact, fun = "mean")
    benthic_ag  <- terra::aggregate(result$benthic,    fact = agg_fact, fun = "modal")
    geomorph_ag <- terra::aggregate(result$geomorph,   fact = agg_fact, fun = "modal")
  } else {
    bathy_ag    <- result$bathymetry
    benthic_ag  <- result$benthic
    geomorph_ag <- result$geomorph
  }

  # Smooth bathymetry only — two passes of 5x5 mean for a smooth depth gradient
  # Categorical layers are not smoothed as focal modal corrupts class values
  if (smooth) {
    w5         <- matrix(1 / 25, nrow = 5, ncol = 5)
    bathy_proc <- terra::focal(bathy_ag,   w = w5, fun = "mean", na.rm = TRUE)
    bathy_proc <- terra::focal(bathy_proc, w = w5, fun = "mean", na.rm = TRUE)
  } else {
    bathy_proc <- bathy_ag
  }
  benthic_proc  <- benthic_ag
  geomorph_proc <- geomorph_ag

  # Resample to a clean regular grid to fix uneven spacing in geom_raster
  res         <- terra::res(bathy_proc)[1]
  roi_vec     <- as.vector(terra::ext(bathy_proc))
  target_grid <- terra::rast(
    xmin = roi_vec[1], xmax = roi_vec[2],
    ymin = roi_vec[3], ymax = roi_vec[4],
    resolution = res,
    crs = terra::crs(bathy_proc)
  )
  bathy_proc    <- terra::resample(bathy_proc,    target_grid, method = "bilinear")
  benthic_proc  <- terra::resample(benthic_proc,  target_grid, method = "near")
  geomorph_proc <- terra::resample(geomorph_proc, target_grid, method = "near")

  # Convert to data frames — use column index [3] as layer names may be
  # temporary vrt() strings and cannot be relied on by name
  bathy_df        <- terra::as.data.frame(bathy_proc, xy = TRUE)
  names(bathy_df) <- c("x", "y", "depth")

  benthic_df        <- terra::as.data.frame(benthic_proc, xy = TRUE)
  names(benthic_df) <- c("x", "y", "benthic_class")
  benthic_df$benthic_class <- as.character(
    round(as.numeric(benthic_df$benthic_class))
  )
  benthic_df$benthic_class[
    is.na(benthic_df$benthic_class) | benthic_df$benthic_class == "0"
  ] <- NA

  geomorph_df        <- terra::as.data.frame(geomorph_proc, xy = TRUE)
  names(geomorph_df) <- c("x", "y", "geomorph_class")
  geomorph_df$geomorph_class <- as.character(
    round(as.numeric(geomorph_df$geomorph_class))
  )
  geomorph_df$geomorph_class[
    is.na(geomorph_df$geomorph_class) | geomorph_df$geomorph_class == "0"
  ] <- NA

  # Colour palettes and labels for benthic and geomorphic classes
  benthic_colors <- c(
    "11" = "#ffffbe", "12" = "#e0d05e", "13" = "#b19c3a",
    "14" = "#668438", "15" = "#ff6161", "18" = "#9bcc4f"
  )
  benthic_labels <- c(
    "11" = "Sand",     "12" = "Rubble",          "13" = "Rock",
    "14" = "Seagrass", "15" = "Coral/Algae",     "18" = "Microalgal Mats"
  )

  geomorph_colors <- c(
    "11" = "#77d0fc", "12" = "#2ca2f9", "13" = "#c5a7cb",
    "14" = "#92739d", "15" = "#614272", "16" = "#fbdefb",
    "21" = "#10bda6", "22" = "#288471", "23" = "#cd6812",
    "24" = "#befbff", "25" = "#ffba15"
  )
  geomorph_labels <- c(
    "11" = "Shallow Lagoon",       "12" = "Deep Lagoon",
    "13" = "Inner Reef Flat",      "14" = "Outer Reef Flat",
    "15" = "Reef Crest",           "16" = "Terrestrial Reef Flat",
    "21" = "Sheltered Reef Slope", "22" = "Reef Slope",
    "23" = "Plateau",              "24" = "Back Reef Slope",
    "25" = "Patch Reef"
  )

  seagrass_sf <- sf::st_as_sf(result$seagrass)

  # Shared bathymetry base layer
  bathy_base <- ggplot2::ggplot() +
    ggplot2::geom_tile(
      data    = bathy_df,
      mapping = ggplot2::aes(x = x, y = y, fill = depth)
    ) +
    ggplot2::scale_fill_gradientn(
      colours = c(
        "#081A39", "#0C2550", "#112B67", "#16317F", "#1B3796", "#203DAD",
        "#2544C4", "#2A4BDB", "#2F52F2", "#345AFA", "#3962FF", "#3E6AFF",
        "#4475FF", "#4A80FF", "#508BFF", "#5696FF", "#5CA1FF", "#62ACFF",
        "#68B7FF", "#6EC2FF", "#74CDFF", "#7BD6FF", "#82DFFF", "#89E8FF",
        "#90F1FF", "#98F5FF", "#A2F7FF", "#ACF8FF", "#B6FAFF", "#C0FBFF"
      ),
      limits = c(min(bathy_df$depth, na.rm = TRUE), 0),
      breaks = scales::pretty_breaks(n = 5),
      name   = "Depth (m)"
    ) +
    ggplot2::theme_void() +
    ggplot2::theme(legend.position = "none")

  # Shared seagrass overlay and theme
  seagrass_centroids <- sf::st_centroid(seagrass_sf)

  seagrass_layer <- ggplot2::geom_sf(
    data = seagrass_centroids,
    shape = 21,
    fill = "#668438",
    colour = "darkgreen",
    size = 2.5,      # kleiner
    stroke = 0.8,
    alpha = 0.7,     # etwas transparent
    inherit.aes = FALSE
  )

  shared_theme <- ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(
      plot.title      = ggplot2::element_text(size = 14, face = "bold"),
      legend.position = "bottom",
      axis.text.x     = ggplot2::element_text(angle = 45, hjust = 1)
    )

  # Benthic panel
  p_benthic <- bathy_base +
    ggnewscale::new_scale_fill() +
    ggplot2::geom_tile(
      data    = dplyr::filter(benthic_df, !is.na(benthic_class)),
      mapping = ggplot2::aes(x = x, y = y, fill = benthic_class),
      alpha   = 0.88
    ) +
    ggplot2::scale_fill_manual(
      values   = benthic_colors,
      labels   = benthic_labels,
      name     = "Benthic (ACA)",
      na.value = NA
    ) +
    seagrass_layer +
    ggplot2::coord_sf(expand = FALSE) +
    ggplot2::labs(title = "Benthic Habitats") +
    shared_theme

  # Geomorphology panel
  p_geomorph <- bathy_base +
    ggnewscale::new_scale_fill() +
    ggplot2::geom_tile(
      data    = dplyr::filter(geomorph_df, !is.na(geomorph_class)),
      mapping = ggplot2::aes(x = x, y = y, fill = geomorph_class),
      alpha   = 0.80
    ) +
    ggplot2::scale_fill_manual(
      values   = geomorph_colors,
      labels   = geomorph_labels,
      name     = "Geomorphology (ACA)",
      na.value = NA
    ) +
    seagrass_layer +
    ggplot2::coord_sf(expand = FALSE) +
    ggplot2::labs(title = "Geomorphology") +
    shared_theme

  # Combine panels and add ROI subtitle
  roi_coords <- round(as.vector(terra::ext(result$benthic)), 3)

  p_benthic + p_geomorph +
    patchwork::plot_layout(ncol = 2, guides = "collect") &
    ggplot2::theme(
      legend.position = "bottom",
      legend.box      = "vertical"
    ) &
    patchwork::plot_annotation(
      title    = "Great Barrier Reef Habitats \u2014 Allen Coral Atlas",
      subtitle = paste("ROI:", paste(roi_coords, collapse = " | ")),
      theme    = ggplot2::theme(
        plot.title    = ggplot2::element_text(size = 16, face = "bold", hjust = 0.5),
        plot.subtitle = ggplot2::element_text(size = 12, hjust = 0.5)
      )
    )
}
