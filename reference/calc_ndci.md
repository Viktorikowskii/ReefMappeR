# Calculate Normalized Difference Chlorophyll Index (NDCI)

Computes the NDCI from a Sentinel-2 image using the red (B4) and
red-edge (B5) bands. NDCI is a spectral index designed to highlight
chlorophyll-a concentration in turbid, productive coastal and inland
waters. It uses the normalized difference between red-edge (705 nm) and
red (665 nm) reflectance where water is particularly sensitive to
phytoplankton chlorophyll.

## Usage

``` r
calc_ndci(s2, red_name = NULL, rededge_name = NULL, verbose = TRUE)
```

## Arguments

- s2:

  SpatRaster Sentinel-2 image containing at least B4 (red) and B5
  (red-edge) bands.

- red_name:

  Character name of the red band. If NULL, auto-detects "B4", "B04", or
  "red".

- rededge_name:

  Character name of the red-edge band. If NULL, auto-detects "B5",
  "B05", or "rededge".

- verbose:

  Logical; print available band names for inspection.

## Value

SpatRaster with single NDCI layer (values -1 to 1).

## Details

NDCI is calculated as: \$\$NDCI = \frac{B5 - B4}{B5 + B4}\$\$

Value interpretation:

- -1 to 0: Low chlorophyll-a, clear water or non-productive conditions

- 0 to 0.3: Moderate chlorophyll-a, typical coastal waters

- \>0.3: High chlorophyll-a, potential eutrophication or algal blooms

Exact chlorophyll-a concentrations require site-specific calibration
with in-situ measurements.

## References

Mishra, S. & Mishra, D.R. (2012). Normalized difference chlorophyll
index: A novel model for remote sensing of chlorophyll-a concentration
in turbid productive waters. *Remote Sensing of Environment*, 117,
394–406.
[doi:10.1016/j.rse.2011.10.016](https://doi.org/10.1016/j.rse.2011.10.016)

## Examples

``` r
if (FALSE) { # \dontrun{
# Auto-detect bands (works with B4/B5 or B04/B05 naming)
ndci <- calc_ndci(s2)
plot(ndci)

# Explicit band names
ndci <- calc_ndci(s2, red_name = "B4", rededge_name = "B5")
} # }
```
