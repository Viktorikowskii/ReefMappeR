#' Plot depth distributions by habitat class
#'
#' Produces side-by-side boxplots showing the depth distribution of benthic
#' and geomorphic habitat classes, derived by intersecting the habitat rasters
#' with the GEBCO bathymetry layer from the output of [set_roi()].
#'
#' @param result Named list returned by [set_roi()], containing `bathymetry`,
#'   `benthic`, and `geomorph`.
#'
#' @return Invisibly returns a `patchwork` plot object. The plot is printed
#'   automatically.
#'
#' @details
#' Depth distributions reveal the ecological zonation of reef habitats.
#' For example, at what depths coral and algae occur compared to sand or rubble,
#' or how geomorphic zones like the reef slope compare in depth range to the
#' reef flat. The Y-axis is scaled dynamically to the data range.
#'
#' Bathymetry is resampled onto the benthic grid before intersection. Only
#' submerged pixels (depth < 0) are included. The colour scheme follows the
#' official Allen Coral Atlas legend.
#'
#' @references
#' Allen Coral Atlas (2020). Coral reefs of the world.
#' \url{https://allencoralatlas.org}
#'
#' GEBCO Compilation Group (2024). GEBCO 2024 Grid.
#' \doi{10.5285/1c44ce99-0a0d-5f4f-e063-7086abc0ea0f}
#'
#' @seealso [habitat_summary()] for area and depth statistics as a table.
#'
#' @importFrom terra resample as.data.frame ext
#' @importFrom dplyr left_join filter mutate
#' @importFrom stringr str_wrap
#' @import ggplot2 patchwork
#' @export
#'
#' @examples
#' \dontrun{
#' # Example 1: Using a Sentinel-2 image
#' s2     <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
#'                                    package = "ReefMappeR"))
#' result <- set_roi(s2 = s2)
#' plot_depth_distribution(result)
#'
#' # Example 2: Using a bounding box
#' result <- set_roi(bbox = c(149.03, 149.08, -20.29, -20.26))
#' plot_depth_distribution(result)
#' }
plot_depth_distribution <- function(result) {

  # Resample bathymetry onto benthic grid
  bathy_aligned <- terra::resample(result$bathymetry, result$benthic, method = "bilinear")

  # Convert rasters to data frames
  benthic_df <- terra::as.data.frame(result$benthic, xy = TRUE)
  names(benthic_df) <- c("x", "y", "class_id")
  benthic_df$class_id <- as.character(round(as.numeric(benthic_df$class_id)))
  benthic_df$class_id[benthic_df$class_id == "0"] <- NA

  geomorph_df <- terra::as.data.frame(result$geomorph, xy = TRUE)
  names(geomorph_df) <- c("x", "y", "class_id")
  geomorph_df$class_id <- as.character(round(as.numeric(geomorph_df$class_id)))
  geomorph_df$class_id[geomorph_df$class_id == "0"] <- NA

  depth_df <- terra::as.data.frame(bathy_aligned, xy = TRUE)
  names(depth_df) <- c("x", "y", "depth")

  # ── Class labels and colours ──────────────────────────────────────────────
  benthic_labels <- c(
    "11" = "Sand",     "12" = "Rubble",      "13" = "Rock",
    "14" = "Seagrass", "15" = "Coral/Algae", "18" = "Microalgal Mats"
  )
  benthic_colors <- c(
    "11" = "#ffffbe", "12" = "#e0d05e", "13" = "#b19c3a",
    "14" = "#668438", "15" = "#ff6161", "18" = "#9bcc4f"
  )

  geomorph_labels <- c(
    "11" = "Shallow Lagoon",       "12" = "Deep Lagoon",
    "13" = "Inner Reef Flat",      "14" = "Outer Reef Flat",
    "15" = "Reef Crest",           "16" = "Terrestrial Reef Flat",
    "21" = "Sheltered Reef Slope", "22" = "Reef Slope",
    "23" = "Plateau",              "24" = "Back Reef Slope",
    "25" = "Patch Reef"
  )
  geomorph_colors <- c(
    "11" = "#77d0fc", "12" = "#2ca2f9", "13" = "#c5a7cb",
    "14" = "#92739d", "15" = "#614272", "16" = "#fbdefb",
    "21" = "#10bda6", "22" = "#288471", "23" = "#cd6812",
    "24" = "#befbff", "25" = "#ffba15"
  )

  # Merge with depth, filter to submerged pixels only
  benthic_combined <- benthic_df |>
    dplyr::left_join(depth_df, by = c("x", "y")) |>
    dplyr::filter(depth < 0) |>
    dplyr::mutate(class_label = benthic_labels[class_id])

  geomorph_combined <- geomorph_df |>
    dplyr::left_join(depth_df, by = c("x", "y")) |>
    dplyr::filter(depth < 0) |>
    dplyr::mutate(class_label = geomorph_labels[class_id])

  roi_coords <- round(as.vector(terra::ext(result$benthic)), 3)

  # ── Benthic depth boxplot ─────────────────────────────────────────────────
  p_benthic <- ggplot2::ggplot(
    benthic_combined |> dplyr::filter(!is.na(class_id), !is.na(depth), !is.na(class_label)),
    ggplot2::aes(x = class_label, y = depth, fill = class_id)
  ) +
    ggplot2::geom_boxplot(
      outlier.shape = NA,
      colour        = "grey20",
      linewidth     = 0.3
    ) +
    ggplot2::scale_fill_manual(values = benthic_colors, guide = "none") +
    ggplot2::scale_y_continuous(
      limits = NULL,
      breaks       = scales::pretty_breaks(n = 5),
      minor_breaks = NULL
    ) +
    ggplot2::scale_x_discrete(labels = function(x) stringr::str_wrap(x, width = 10)) +
    ggplot2::labs(title = "Benthic classes", x = NULL, y = "Depth (m)") +
    ggplot2::theme_minimal(base_size = 10) +
    ggplot2::theme(
      plot.title  = ggplot2::element_text(face = "bold"),
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1, size = 8)
    )

  # ── Geomorphic depth boxplot ──────────────────────────────────────────────
  p_geomorph <- ggplot2::ggplot(
    geomorph_combined |> dplyr::filter(!is.na(class_id), !is.na(depth), !is.na(class_label)),
    ggplot2::aes(x = class_label, y = depth, fill = class_id)
  ) +
    ggplot2::geom_boxplot(
      outlier.shape = NA,
      colour        = "grey20",
      linewidth     = 0.3
    ) +
    ggplot2::scale_fill_manual(values = geomorph_colors, guide = "none") +
    ggplot2::scale_y_continuous(
      limits = NULL,
      breaks       = scales::pretty_breaks(n = 5),
      minor_breaks = NULL
    ) +
    ggplot2::scale_x_discrete(labels = function(x) stringr::str_wrap(x, width = 10)) +
    ggplot2::labs(title = "Geomorphic classes", x = NULL, y = "Depth (m)") +
    ggplot2::theme_minimal(base_size = 10) +
    ggplot2::theme(
      plot.title  = ggplot2::element_text(face = "bold"),
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1, size = 8)
    )
  p_out <- (p_benthic | p_geomorph) +
    patchwork::plot_annotation(
      title    = "Depth distributions by habitat class",
      subtitle = paste("ROI:", paste(roi_coords, collapse = " | ")),
      theme    = ggplot2::theme(
        plot.title    = ggplot2::element_text(size = 13, face = "bold", hjust = 0.5),
        plot.subtitle = ggplot2::element_text(size = 9,  colour = "grey50", hjust = 0.5)
      )
    )


  print(p_out)
  invisible(p_out)
}
