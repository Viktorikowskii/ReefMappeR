# Habitat statistics summary for a region of interest

Computes per-class area (km2), percentage cover, and depth statistics
for benthic and geomorphic habitat classes from the output of
[`set_roi()`](https://viktorikowskii.github.io/ReefMappeR/reference/set_roi.md),
and produces a styled summary table.

## Usage

``` r
habitat_summary(result)
```

## Arguments

- result:

  Named list returned by
  [`set_roi()`](https://viktorikowskii.github.io/ReefMappeR/reference/set_roi.md).

## Value

Invisibly returns a named list with:

- table:

  A styled `gt` summary table of benthic and geomorphic habitat
  statistics.

- stats:

  A named list with data frames `benthic` and `geomorph`.

## Details

For each habitat class the function computes area in km2 from pixel size
at native resolution (~10 m), percentage cover relative to total
classified area within the ROI, and mean, minimum, and maximum depth
derived by intersecting the habitat raster with the aligned GEBCO
bathymetry layer. Results are presented as a styled gt table printed
automatically to the RStudio Viewer, and returned as raw data frames for
further analysis.

## References

Allen Coral Atlas (2020). Coral reefs of the world.
<https://allencoralatlas.org>

GEBCO Compilation Group (2024). GEBCO 2024 Grid.
[doi:10.5285/1c44ce99-0a0d-5f4f-e063-7086abc0ea0f](https://doi.org/10.5285/1c44ce99-0a0d-5f4f-e063-7086abc0ea0f)

## See also

[`plot_depth_distribution()`](https://viktorikowskii.github.io/ReefMappeR/reference/plot_depth_distribution.md)
for depth distribution plots.

## Examples

``` r
if (FALSE) { # \dontrun{
# Example 1: Using a Sentinel-2 image
s2     <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                   package = "ReefMappeR"))
result <- set_roi(s2 = s2)
out    <- habitat_summary(result)
out$table
out$stats$benthic

# Example 2: Using a bounding box
result <- set_roi(bbox = c(149.03, 149.08, -20.29, -20.26))
out    <- habitat_summary(result)
out$table
} # }
```
