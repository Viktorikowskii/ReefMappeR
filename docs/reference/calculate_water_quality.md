# Calculate Total Suspended Sediments (TSS) from Sentinel-2

Estimates Total Suspended Sediments (TSS) from a Sentinel-2 Level-2A
surface reflectance image using a red/green band ratio algorithm. A
NIR-based water mask is applied to exclude land and non-water pixels.

## Usage

``` r
calculate_water_quality(s2)
```

## Arguments

- s2:

  A
  [`terra::SpatRaster`](https://rspatial.github.io/terra/reference/SpatRaster-class.html)
  object containing at least bands `"B3"` (green), `"B4"` (red), and
  `"B8"` (NIR) from a Sentinel-2 Level-2A product (surface reflectance,
  values 0–10000).

## Value

A `SpatRaster` of estimated TSS in g/m\\^3\\, masked to water pixels
only. The plot is displayed automatically.

## Details

TSS is derived from a red/green reflectance relationship of the form
\$\$TSS = 1.47 \times (R\_{red} / R\_{green}) + 31.4 \times
R\_{red},\$\$ where \\R\_{red}\\ and \\R\_{green}\\ are surface
reflectances from Sentinel-2 bands B4 and B3 respectively, scaled to
0–1. Negative values are set to zero. A simple water mask is applied
using band B8 (NIR) with a threshold of 0.05; pixels above this
threshold are treated as non-water and set to `NA`.

This algorithm is a generic coastal-water approximation and should be
locally validated and recalibrated with in-situ measurements before use
in quantitative analyses.

## See also

[`calc_ndci`](https://viktorikowskii.github.io/ReefMappeR/reference/calc_ndci.md)
for chlorophyll-a estimation.

## Examples

``` r
if (FALSE) { # \dontrun{
s2 <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                               package = "ReefMappeR"))
tss <- calculate_water_quality(s2)
} # }
```
