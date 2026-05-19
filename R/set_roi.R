#' Crop datasets to a specified region of interest
#'
#' Crops bathymetry (GEBCO), benthic habitats, geomorphology (Allen Coral Atlas),
#' and seagrass datasets to the extent of a Sentinel-2 image or bounding box.
#' Benthic and geomorphic data are mosaicked at native ~10 m resolution;
#' GEBCO bathymetry is resampled onto the ACA grid.
#'
#' @param s2 SpatRaster. Sentinel-2 image defining the ROI. Only the spatial
#'   extent is used. Optional, provide either `s2` or `bbox`.
#' @param bbox Numeric vector `c(xmin, xmax, ymin, ymax)` or an sf/sfc object
#'   defining the ROI. Optional, alternative to `s2`.
#' @param bathymetry SpatRaster. If NULL, loads GEBCO_2024 from extdata.
#' @param benthic SpatRaster. If NULL, auto-loads matching Allen Coral Atlas tiles.
#' @param geomorph SpatRaster. If NULL, auto-loads matching Allen Coral Atlas tiles.
#' @param seagrass SpatVector. If NULL, loads the bundled GBR seagrass dataset.
#'
#' @return Named list with four elements:
#' \describe{
#'   \item{bathymetry}{SpatRaster. GEBCO bathymetry cropped and resampled to ACA grid (~10 m).}
#'   \item{benthic}{SpatRaster. Allen Coral Atlas benthic habitat classes cropped to ROI.}
#'   \item{geomorph}{SpatRaster. Allen Coral Atlas geomorphic zones cropped to ROI.}
#'   \item{seagrass}{SpatVector. UNEP-WCMC seagrass polygons clipped to ROI.}
#' }
#'
#' @importFrom terra rast crop ext project resample vrt sources sprc vect crs
#' @importFrom sf st_bbox
#' @export
#'
#' @examples
#' bbox <- c(150.56, 151.30, -21.51, -20.77)
#' result <- set_roi(bbox = bbox)
#' plot(result$benthic)
#'
#' \dontrun{
#' s2_img <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
#'                                    package = "ReefMappeR"))
#' result  <- set_roi(s2 = s2_img)
#' plot(result$benthic)
#' }

set_roi <- function(
    s2         = NULL,
    bathymetry = NULL,
    benthic    = NULL,
    geomorph   = NULL,
    seagrass   = NULL,
    bbox       = NULL
) {

  # Define ROI extent
  if (!is.null(s2)) {
    if (terra::crs(s2, describe = TRUE)$code != "4326") {
      message("Extracting ROI extent from s2 (reprojecting template only)...")
      s2_template <- terra::project(
        terra::rast(terra::ext(s2), nrows = 1L, ncols = 1L, crs = terra::crs(s2)),
        "EPSG:4326"
      )
      roi_ext <- terra::ext(s2_template)
    } else {
      roi_ext <- terra::ext(s2)
    }

  } else if (!is.null(bbox)) {
    if (inherits(bbox, "sf") || inherits(bbox, "sfc")) {
      roi_ext <- terra::ext(sf::st_bbox(bbox))

    } else if (is.numeric(bbox) && length(bbox) == 4) {
      if (bbox[1] >= bbox[2] || bbox[3] >= bbox[4]) {
        stop("bbox must be c(xmin, xmax, ymin, ymax) with xmin < xmax and ymin < ymax.")
      }
      roi_ext <- terra::ext(bbox[1], bbox[2], bbox[3], bbox[4])

    } else {
      stop("bbox must be a numeric vector of length 4 or an sf/sfc object.")
    }

  } else {
    stop("Either 's2' or 'bbox' must be provided.")
  }

  # Load bathymetry from extdata, with fallback for devtools::load_all()
  if (is.null(bathymetry)) {
    bathy_file <- system.file("extdata", "bathymetry_gbr.tif", package = "ReefMappeR")

    if (!file.exists(bathy_file)) {
      dev_path <- file.path("inst", "extdata", "bathymetry_gbr.tif")
      if (file.exists(dev_path)) {
        bathy_file <- dev_path
        message("DEV: Using inst/extdata/bathymetry_gbr.tif")
      } else {
        stop("bathymetry_gbr.tif not found in inst/extdata/.")
      }
    }

    bathymetry <- terra::rast(bathy_file)
    message("Loaded: ", basename(bathy_file))
  }

  # Crop bathymetry early to keep memory use low
  bathymetry <- terra::crop(bathymetry, roi_ext)

  # Load seagrass from extdata, with fallback for devtools::load_all()
  if (is.null(seagrass)) {
    seagrass_file <- system.file("extdata", "seagrass_gbr.shp", package = "ReefMappeR")

    if (!file.exists(seagrass_file)) {
      dev_path <- file.path("inst", "extdata", "seagrass_gbr.shp")
      if (file.exists(dev_path)) {
        seagrass_file <- dev_path
        message("DEV: Using inst/extdata/seagrass_gbr.shp")
      } else {
        stop("seagrass_gbr.shp not found in inst/extdata/.")
      }
    }

    seagrass <- terra::vect(seagrass_file)
    terra::crs(seagrass) <- "EPSG:4326"
  }

  # Crop seagrass to ROI
  seagrass_roi <- tryCatch(
    terra::crop(seagrass, roi_ext),
    error = function(e) {
      warning("Seagrass crop failed: ", e$message)
      seagrass
    }
  )

  # Find overlapping benthic and geomorphic tiles
  if (is.null(benthic)) {
    benthic_files <- find_overlapping_files("benthic_gbr_", ".tif", roi_ext)
    if (length(benthic_files) > 0) {
      benthic <- lapply(benthic_files, terra::rast)
      message("Loaded ", length(benthic), " benthic tile(s).")
    } else {
      benthic <- list()
    }
  }

  if (is.null(geomorph)) {
    geomorph_files <- find_overlapping_files("geomorph_gbr_", ".tif", roi_ext)
    if (length(geomorph_files) > 0) {
      geomorph <- lapply(geomorph_files, terra::rast)
      message("Loaded ", length(geomorph), " geomorphic tile(s).")
    } else {
      geomorph <- list()
    }
  }

  # Build virtual mosaics — reads only ROI pixels, avoids loading all tiles into RAM
  message("Building virtual mosaic for ", length(benthic), " benthic tile(s)...")
  benthic_vrt <- terra::vrt(unlist(lapply(benthic, terra::sources)))
  benthic     <- terra::crop(benthic_vrt, roi_ext)

  message("Building virtual mosaic for ", length(geomorph), " geomorphic tile(s)...")
  geomorph_vrt <- terra::vrt(unlist(lapply(geomorph, terra::sources)))
  geomorph     <- terra::crop(geomorph_vrt, roi_ext)

  # Resample bathymetry onto ACA grid to preserve native ~10 m resolution
  message("Resampling bathymetry to ACA grid...")
  bathymetry <- terra::resample(bathymetry, benthic, method = "bilinear")

  list(
    bathymetry = bathymetry,
    benthic    = benthic,
    geomorph   = geomorph,
    seagrass   = seagrass_roi
  )
}


# ── Internal helper ───────────────────────────────────────────────────────────

#' Find package data files whose spatial extent overlaps the ROI
#'
#' @param prefix Character. Filename prefix to match (e.g. "benthic_gbr_").
#' @param ext Character. File extension to match (e.g. ".tif").
#' @param roi_ext SpatExtent. Region of interest used for spatial filtering.
#'
#' @return Character vector of matching file paths that overlap the ROI.
#' @noRd
find_overlapping_files <- function(prefix, ext, roi_ext) {

  search_paths <- c(
    file.path("inst", "extdata"),
    system.file("extdata", package = "ReefMappeR")
  )

  # Collect all files matching prefix and extension
  all_files <- unique(unlist(lapply(search_paths, function(p) {
    if (dir.exists(p)) {
      list.files(p, pattern = paste0(prefix, ".*", ext, "$"), full.names = TRUE)
    } else {
      character(0)
    }
  })))

  if (!length(all_files)) return(character(0))

  roi_vec <- as.vector(roi_ext)

  # Keep only tiles whose extent intersects the ROI (header-only read)
  overlapping <- Filter(function(f) {
    tile_ext <- tryCatch(
      as.vector(terra::ext(terra::rast(f))),
      error = function(e) NULL
    )
    if (is.null(tile_ext)) return(FALSE)
    tile_ext[1] <= roi_vec[2] &&
      tile_ext[2] >= roi_vec[1] &&
      tile_ext[3] <= roi_vec[4] &&
      tile_ext[4] >= roi_vec[3]
  }, all_files)

  # Deduplicate by filename to avoid loading the same tile twice
  overlapping <- overlapping[!duplicated(basename(overlapping))]

  message(sprintf(
    "Found %d/%d file(s) with prefix '%s' overlapping ROI (%.4f, %.4f, %.4f, %.4f).",
    length(overlapping), length(all_files), prefix,
    roi_vec[1], roi_vec[2], roi_vec[3], roi_vec[4]
  ))

  overlapping
}

