# Plot depth distributions by habitat class

Produces side-by-side boxplots showing the depth distribution of benthic
and geomorphic habitat classes, derived by intersecting the habitat
rasters with the GEBCO bathymetry layer from the output of
[`set_roi()`](https://viktorikowskii.github.io/ReefMappeR/reference/set_roi.md).

## Usage

``` r
plot_depth_distribution(result)
```

## Arguments

- result:

  Named list returned by
  [`set_roi()`](https://viktorikowskii.github.io/ReefMappeR/reference/set_roi.md),
  containing `bathymetry`, `benthic`, and `geomorph`.

## Value

Invisibly returns a `patchwork` plot object. The plot is printed
automatically.

## Details

Depth distributions reveal the ecological zonation of reef habitats. For
example, at what depths coral and algae occur compared to sand or
rubble, or how geomorphic zones like the reef slope compare in depth
range to the reef flat. The Y-axis is scaled dynamically to the data
range.

Bathymetry is resampled onto the benthic grid before intersection. Only
submerged pixels (depth \< 0) are included. The colour scheme follows
the official Allen Coral Atlas legend.

## References

Allen Coral Atlas (2020). Coral reefs of the world.
<https://allencoralatlas.org>

GEBCO Compilation Group (2024). GEBCO 2024 Grid.
[doi:10.5285/1c44ce99-0a0d-5f4f-e063-7086abc0ea0f](https://doi.org/10.5285/1c44ce99-0a0d-5f4f-e063-7086abc0ea0f)

## See also

[`habitat_summary()`](https://viktorikowskii.github.io/ReefMappeR/reference/habitat_summary.md)
for area and depth statistics as a table.

## Examples

``` r
if (FALSE) { # \dontrun{
# Example 1: Using a Sentinel-2 image
s2     <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                   package = "ReefMappeR"))
result <- set_roi(s2 = s2)
plot_depth_distribution(result)

# Example 2: Using a bounding box
result <- set_roi(bbox = c(149.03, 149.08, -20.29, -20.26))
plot_depth_distribution(result)
} # }
```
