# Two-panel habitat map with bathymetry, benthic habitats, geomorphic zones, and seagrass

Creates a two-panel map with GEBCO bathymetry as background and Allen
Coral Atlas benthic habitats (left) and geomorphic zones (right).
Seagrass occurrence polygons (UNEP-WCMC) are overlaid as green points on
both panels. Applies auto-aggregation to prevent RAM issues, optional
focal smoothing, and resamples to a regular grid for seamless rendering.

## Usage

``` r
plot_habitat_map(result, smooth = TRUE, agg_fact = NULL)
```

## Arguments

- result:

  Named list returned by
  [`set_roi()`](https://viktorikowskii.github.io/ReefMappeR/reference/set_roi.md),
  containing `bathymetry`, `benthic`, `geomorph`, and `seagrass`.

- smooth:

  Logical. Apply 5x5 focal mean smoothing to bathymetry before plotting?
  Default: `TRUE`.

- agg_fact:

  Positive integer or `NULL` (default). Aggregation factor applied
  before smoothing. If `NULL`, chosen automatically to keep the raster
  below ~500k pixels. Set explicitly to override.

## Value

A patchwork/ggplot2 object combining both panels.

## Details

Benthic and geomorphic classifications follow the Allen Coral Atlas
(ACA) global mapping scheme. The benthic layer covers areas shallower
than 10 m, the geomorphic layer areas shallower than 15 m.
Auto-aggregation reduces memory usage by downsampling large rasters
before plotting; categorical layers use modal aggregation to preserve
class integrity.

GEBCO bathymetry is displayed as a blue depth gradient in the background
of both panels. Seagrass occurrence polygons (UNEP-WCMC) are overlaid as
green points derived from polygon centroids. \#' @references Allen Coral
Atlas (2020). Coral reefs of the world. <https://allencoralatlas.org>

Lyons, M.B. et al. (2020). Mapping the world's coral reefs using a
global multiscale earth observation framework. *Remote Sensing in
Ecology and Conservation*, 6(4), 557–568.
[doi:10.1002/rse2.157](https://doi.org/10.1002/rse2.157)

GEBCO Compilation Group (2024). GEBCO 2024 Grid.
[doi:10.5285/1c44ce99-0a0d-5f4f-e063-7086abc0ea0f](https://doi.org/10.5285/1c44ce99-0a0d-5f4f-e063-7086abc0ea0f)

UNEP-WCMC & Short, F.T. (2021). Global distribution of seagrasses
(version 7.1).
[doi:10.34892/x6r3-d211](https://doi.org/10.34892/x6r3-d211)

## See also

[`set_roi()`](https://viktorikowskii.github.io/ReefMappeR/reference/set_roi.md),
[`habitat_summary()`](https://viktorikowskii.github.io/ReefMappeR/reference/habitat_summary.md),
[`plot_depth_distribution()`](https://viktorikowskii.github.io/ReefMappeR/reference/plot_depth_distribution.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Example 1: Using a Sentinel-2 image
s2     <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                   package = "ReefMappeR"))
result <- set_roi(s2 = s2)
plot_habitat_map(result)

# Example 2: Using a bounding box (Whitsundays region)
result <- set_roi(bbox = c(149.03, 149.08, -20.29, -20.26))
plot_habitat_map(result)

# Example 3: Using a bounding box (Lizard Island)
result <- set_roi(bbox = c(145.4, 145.6, -14.7, -14.5))
plot_habitat_map(result)
} # }
```
