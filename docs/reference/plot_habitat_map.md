# Side-by-side habitat maps: benthic habitats and geomorphology

Creates a two-panel map with bathymetry as background and Allen Coral
Atlas benthic habitats (left) and geomorphic zones (right). Applies
auto-aggregation to prevent RAM issues, optional focal smoothing, and
resamples to a regular grid for seamless rendering.

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

\#' @details Benthic and geomorphic classifications follow the Allen
Coral Atlas (ACA) global mapping scheme. The benthic layer covers areas
shallower than 10 m, the geomorphic layer areas shallower than 15 m.
Auto-aggregation reduces memory usage by downsampling large rasters
before plotting; categorical layers use modal aggregation to preserve
class integrity.

## References

Allen Coral Atlas (2020). Coral reefs of the world.
<https://allencoralatlas.org>

Lyons, M.B. et al. (2020). Mapping the world's coral reefs using a
global multiscale earth observation framework. *Remote Sensing in
Ecology and Conservation*, 6(4), 557–568.
[doi:10.1002/rse2.157](https://doi.org/10.1002/rse2.157)

## See also

[`set_roi()`](https://viktorikowskii.github.io/ReefMappeR/reference/set_roi.md),
[`habitat_summary()`](https://viktorikowskii.github.io/ReefMappeR/reference/habitat_summary.md),
[`plot_depth_distribution()`](https://viktorikowskii.github.io/ReefMappeR/reference/plot_depth_distribution.md)

## Examples

``` r
if (FALSE) { # \dontrun{
bbox   <- c(150.56, 151.30, -21.51, -20.77)
result <- set_roi(bbox = bbox)
plot_habitat_map(result)
} # }
```
