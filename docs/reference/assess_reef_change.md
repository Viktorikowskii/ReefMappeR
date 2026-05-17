# Assess reef change between two NDCI rasters

Computes pixel-wise NDCI difference between two time points to detect
temporal changes in chlorophyll-a concentration over reef areas.

## Usage

``` r
assess_reef_change(ndci_t1, ndci_t2)
```

## Arguments

- ndci_t1:

  SpatRaster. NDCI at time 1, output of
  [`calc_ndci()`](https://viktorikowskii.github.io/ReefMappeR/reference/calc_ndci.md).

- ndci_t2:

  SpatRaster. NDCI at time 2, output of
  [`calc_ndci()`](https://viktorikowskii.github.io/ReefMappeR/reference/calc_ndci.md).

## Value

A SpatRaster of pixel-wise NDCI difference (t2 minus t1). Positive
values indicate increased chlorophyll-a, negative values indicate
decreased chlorophyll-a. Pass the result to
[`compare_habitats_change()`](https://viktorikowskii.github.io/ReefMappeR/reference/compare_habitats_change.md)
for visualisation.

## Details

The NDCI difference is calculated as: \$\$\Delta NDCI = NDCI\_{t2} -
NDCI\_{t1}\$\$

If the two rasters do not share the same geometry, `ndci_t2` is
automatically resampled to match `ndci_t1` using bilinear interpolation.
For meaningful change detection, both images should be from the same
season to minimise phenological differences, and pre-processed to
surface reflectance (Sentinel-2 Level-2A).

## References

Mishra, S. & Mishra, D.R. (2012). Normalized difference chlorophyll
index: A novel model for remote sensing of chlorophyll-a concentration
in turbid productive waters. *Remote Sensing of Environment*, 117,
394–406.
[doi:10.1016/j.rse.2011.10.016](https://doi.org/10.1016/j.rse.2011.10.016)

## See also

[`calc_ndci()`](https://viktorikowskii.github.io/ReefMappeR/reference/calc_ndci.md),
[`compare_habitats_change()`](https://viktorikowskii.github.io/ReefMappeR/reference/compare_habitats_change.md)

## Examples

``` r
if (FALSE) { # \dontrun{
s2_24  <- terra::rast(system.file("extdata", "Sentinel2_2024_example.tif",
                                   package = "ReefMappeR"))
s2_25  <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                   package = "ReefMappeR"))
change <- assess_reef_change(calc_ndci(s2_24), calc_ndci(s2_25))
compare_habitats_change(change)
} # }
```
