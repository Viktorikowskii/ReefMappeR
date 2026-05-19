# Assess temporal change between two rasters

Computes the pixel-wise difference between two rasters of the same
variable at different time points. Works with any SpatRaster output,
including NDCI from
[`calc_ndci()`](https://viktorikowskii.github.io/ReefMappeR/reference/calc_ndci.md)
and TSS from
[`calc_tss()`](https://viktorikowskii.github.io/ReefMappeR/reference/calc_tss.md).

## Usage

``` r
assess_reef_change(raster_t1, raster_t2)
```

## Arguments

- raster_t1:

  SpatRaster. Raster at time 1, e.g. output of
  [`calc_ndci()`](https://viktorikowskii.github.io/ReefMappeR/reference/calc_ndci.md)
  or
  [`calc_tss()`](https://viktorikowskii.github.io/ReefMappeR/reference/calc_tss.md).

- raster_t2:

  SpatRaster. Raster at time 2, e.g. output of
  [`calc_ndci()`](https://viktorikowskii.github.io/ReefMappeR/reference/calc_ndci.md)
  or
  [`calc_tss()`](https://viktorikowskii.github.io/ReefMappeR/reference/calc_tss.md).

## Value

A SpatRaster of pixel-wise difference (t2 minus t1). Positive values
indicate an increase, negative values a decrease. Pass the result to
[`compare_ndci_change()`](https://viktorikowskii.github.io/ReefMappeR/reference/compare_ndci_change.md)
or
[`compare_tss_change()`](https://viktorikowskii.github.io/ReefMappeR/reference/compare_tss_change.md)
for classification and visualisation.

## Details

The difference is calculated as: \$\$\Delta = raster\_{t2} -
raster\_{t1}\$\$

If the two rasters do not share the same geometry, raster_t2 is
automatically resampled to match raster_t1 using bilinear interpolation.
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
[`calc_tss()`](https://viktorikowskii.github.io/ReefMappeR/reference/calc_tss.md),
[`compare_ndci_change()`](https://viktorikowskii.github.io/ReefMappeR/reference/compare_ndci_change.md),
[`compare_tss_change()`](https://viktorikowskii.github.io/ReefMappeR/reference/compare_tss_change.md)

## Examples

``` r
if (FALSE) { # \dontrun{
s2_24 <- terra::rast(system.file("extdata", "Sentinel2_2024_example.tif",
                                  package = "ReefMappeR"))
s2_25 <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                  package = "ReefMappeR"))

# NDCI change
change_ndci <- assess_reef_change(calc_ndci(s2_24), calc_ndci(s2_25))
compare_ndci_change(change_ndci)

# TSS change
change_tss <- assess_reef_change(calc_tss(s2_24), calc_tss(s2_25))
compare_tss_change(change_tss)
} # }
```
