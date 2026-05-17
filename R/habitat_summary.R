#' Habitat statistics summary for a region of interest
#'
#' Computes per-class area and depth statistics from the output of [set_roi()]
#' and produces a styled summary table.
#'
#' @param result Named list returned by [set_roi()].
#'
#' @return Invisibly returns a named list with:
#' \describe{
#'   \item{table}{A styled `gt` summary table of benthic and geomorphic habitat statistics.}
#'   \item{stats}{A named list with data frames `benthic`, `geomorph`, and `seagrass`.}
#' }
#'
#' @seealso [plot_depth_distribution()] for depth distribution plots.
#'
#' @importFrom terra resample as.data.frame cellSize ext extract
#' @importFrom dplyr left_join group_by summarise mutate arrange n filter
#'   select desc bind_rows relocate
#' @importFrom gt gt tab_header tab_style cell_fill cell_text cells_body
#'   cells_column_labels cells_title cells_row_groups cells_column_spanners
#'   cols_align data_color fmt_number tab_options tab_spanner pct px
#' @export
#'
#' @examples
#' \dontrun{
#' bbox   <- c(150.56, 151.30, -21.51, -20.77)
#' result <- set_roi(bbox = bbox)
#' out    <- habitat_summary(result)
#' out$table
#' out$stats$benthic
#' }
habitat_summary <- function(result) {

  message("Computing habitat statistics...")

  # Resample bathymetry onto benthic grid for pixel-wise depth extraction
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

  # Compute pixel area in km²
  area_df <- terra::as.data.frame(terra::cellSize(result$benthic, unit = "km"), xy = TRUE)
  names(area_df) <- c("x", "y", "area_km2")

  # Merge with depth and area, filter to submerged pixels only
  benthic_combined <- benthic_df |>
    dplyr::left_join(depth_df, by = c("x", "y")) |>
    dplyr::left_join(area_df,  by = c("x", "y")) |>
    dplyr::filter(depth < 0)

  geomorph_combined <- geomorph_df |>
    dplyr::left_join(depth_df, by = c("x", "y")) |>
    dplyr::left_join(area_df,  by = c("x", "y")) |>
    dplyr::filter(depth < 0)

  # ── Class labels ──────────────────────────────────────────────────────────
  benthic_labels <- c(
    "11" = "Sand",     "12" = "Rubble",      "13" = "Rock",
    "14" = "Seagrass", "15" = "Coral/Algae", "18" = "Microalgal Mats"
  )

  geomorph_labels <- c(
    "11" = "Shallow Lagoon",       "12" = "Deep Lagoon",
    "13" = "Inner Reef Flat",      "14" = "Outer Reef Flat",
    "15" = "Reef Crest",           "16" = "Terrestrial Reef Flat",
    "21" = "Sheltered Reef Slope", "22" = "Reef Slope",
    "23" = "Plateau",              "24" = "Back Reef Slope",
    "25" = "Patch Reef"
  )

  benthic_combined$class_label  <- benthic_labels[benthic_combined$class_id]
  geomorph_combined$class_label <- geomorph_labels[geomorph_combined$class_id]

  # ── Summary statistics ────────────────────────────────────────────────────
  benthic_stats <- benthic_combined |>
    dplyr::filter(!is.na(class_id)) |>
    dplyr::group_by(class_id, class_label) |>
    dplyr::summarise(
      area_km2   = round(sum(area_km2,  na.rm = TRUE), 3),
      mean_depth = round(mean(depth,    na.rm = TRUE), 1),
      min_depth  = round(min(depth,     na.rm = TRUE), 1),
      max_depth  = round(max(depth,     na.rm = TRUE), 1),
      n_pixels   = dplyr::n(),
      .groups    = "drop"
    ) |>
    dplyr::mutate(pct_cover = round(area_km2 / sum(area_km2) * 100, 1)) |>
    dplyr::arrange(dplyr::desc(area_km2))

  geomorph_stats <- geomorph_combined |>
    dplyr::filter(!is.na(class_id)) |>
    dplyr::group_by(class_id, class_label) |>
    dplyr::summarise(
      area_km2   = round(sum(area_km2,  na.rm = TRUE), 3),
      mean_depth = round(mean(depth,    na.rm = TRUE), 1),
      min_depth  = round(min(depth,     na.rm = TRUE), 1),
      max_depth  = round(max(depth,     na.rm = TRUE), 1),
      n_pixels   = dplyr::n(),
      .groups    = "drop"
    ) |>
    dplyr::mutate(pct_cover = round(area_km2 / sum(area_km2) * 100, 1)) |>
    dplyr::arrange(dplyr::desc(area_km2))

  # Extract depth at seagrass locations
  seagrass_depth <- terra::extract(bathy_aligned, result$seagrass)
  names(seagrass_depth) <- c("id", "depth")
  seagrass_depth <- seagrass_depth |>
    dplyr::filter(!is.na(depth), depth < 0)

  # ── gt summary table ──────────────────────────────────────────────────────
  roi_coords <- round(as.vector(terra::ext(result$benthic)), 3)

  combined_table <- dplyr::bind_rows(
    benthic_stats |>
      dplyr::select(
        Class        = class_label,
        `Area (km²)` = area_km2,
        `Cover (%)`  = pct_cover,
        `Mean (m)`   = mean_depth,
        `Min (m)`    = min_depth,
        `Max (m)`    = max_depth
      ) |>
      dplyr::mutate(Type = "Benthic"),
    geomorph_stats |>
      dplyr::select(
        Class        = class_label,
        `Area (km²)` = area_km2,
        `Cover (%)`  = pct_cover,
        `Mean (m)`   = mean_depth,
        `Min (m)`    = min_depth,
        `Max (m)`    = max_depth
      ) |>
      dplyr::mutate(Type = "Geomorphic")
  ) |>
    dplyr::relocate(Type)

  p_table <- combined_table |>
    gt::gt(groupname_col = "Type") |>
    gt::tab_header(
      title    = "Habitat statistics",
      subtitle = paste("ROI:", paste(roi_coords, collapse = " | "))
    ) |>
    gt::tab_spanner(
      label   = "Depth",
      columns = c(`Mean (m)`, `Min (m)`, `Max (m)`)
    ) |>
    gt::tab_spanner(
      label   = "Coverage",
      columns = c(`Area (km²)`, `Cover (%)`)
    ) |>
    gt::tab_style(
      style = list(
        gt::cell_fill(color = "#2c3e50"),
        gt::cell_text(color = "white", weight = "bold")
      ),
      locations = gt::cells_column_labels()
    ) |>
    gt::tab_style(
      style = list(
        gt::cell_fill(color = "#34495e"),
        gt::cell_text(color = "white", weight = "bold")
      ),
      locations = gt::cells_row_groups()
    ) |>
    gt::tab_style(
      style = list(
        gt::cell_fill(color = "#1a252f"),
        gt::cell_text(color = "white", weight = "bold")
      ),
      locations = gt::cells_column_spanners()
    ) |>
    gt::tab_style(
      style     = gt::cell_fill(color = "#f5f5f5"),
      locations = gt::cells_body(rows = seq(1, nrow(combined_table), 2))
    ) |>
    gt::tab_style(
      style     = gt::cell_text(weight = "bold", size = gt::px(14)),
      locations = gt::cells_title(groups = "title")
    ) |>
    gt::tab_style(
      style     = gt::cell_text(color = "grey50", size = gt::px(11)),
      locations = gt::cells_title(groups = "subtitle")
    ) |>
    gt::cols_align(align = "left",   columns = Class) |>
    gt::cols_align(align = "center", columns = -Class) |>
    gt::data_color(
      columns = `Cover (%)`,
      palette = c("#ffffff", "#9bcc4f"),
      domain  = c(0, 100)
    ) |>
    gt::data_color(
      columns = `Mean (m)`,
      palette = c("#2F52F2", "#C0FBFF"),
      domain  = c(min(c(benthic_stats$mean_depth, geomorph_stats$mean_depth)), 0)
    ) |>
    gt::fmt_number(columns = `Area (km²)`, decimals = 2) |>
    gt::fmt_number(
      columns  = c(`Cover (%)`, `Mean (m)`, `Min (m)`, `Max (m)`),
      decimals = 1
    ) |>
    gt::tab_options(
      table.font.size             = gt::px(12),
      table.width                 = gt::pct(100),
      column_labels.padding       = gt::px(8),
      data_row.padding            = gt::px(6),
      heading.border.bottom.color = "#2c3e50",
      table.border.top.color      = "#2c3e50",
      row_group.padding           = gt::px(6)
    )

  print(p_table)

  invisible(list(
    table = p_table,
    stats = list(
      benthic  = benthic_stats,
      geomorph = geomorph_stats,
      seagrass = seagrass_depth
    )
  ))
}
