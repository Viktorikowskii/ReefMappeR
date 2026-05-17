# Getting Started with ReefMappeR

``` r
library(ReefMappeR)
library(terra)
#> Warning: package 'terra' was built under R version 4.4.3
#> terra 1.8.60
```

## Overview

ReefMappeR provides a streamlined workflow for mapping and analysing
reef habitats at the Great Barrier Reef using satellite remote sensing
and open marine datasets. This vignette walks through a complete
analysis from defining a region of interest to detecting temporal change
in water quality.

The workflow consists of three stages:

1.  **Habitat mapping** — load spatial data, visualise and summarise
    habitats
2.  **Water quality** — estimate chlorophyll-a and suspended sediments
    from Sentinel-2
3.  **Change detection** — compare two time points to detect NDCI change

------------------------------------------------------------------------

## 1. Define a Region of Interest

[`set_roi()`](https://viktorikowskii.github.io/ReefMappeR/reference/set_roi.md)
is the entry point of every ReefMappeR workflow. It automatically loads
and crops all bundled datasets — bathymetry, benthic habitat tiles,
geomorphic zone tiles, and seagrass polygons — to your area of interest.

You can define the ROI either by a bounding box or a Sentinel-2 image:

``` r
# Option A: bounding box (xmin, xmax, ymin, ymax)
bbox   <- c(150.56, 150.80, -21.51, -21.20)
result <- set_roi(bbox = bbox)

# Option B: Sentinel-2 image extent
s2     <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                   package = "ReefMappeR"))
result <- set_roi(s2 = s2)
```

The result is a named list with four elements: `bathymetry`, `benthic`,
`geomorph`, and `seagrass`. All subsequent functions accept this list as
input.

------------------------------------------------------------------------

## 2. Visualise Habitat Maps

[`plot_habitat_map()`](https://viktorikowskii.github.io/ReefMappeR/reference/plot_habitat_map.md)
creates a two-panel map with bathymetry as background and Allen Coral
Atlas benthic habitats and geomorphic zones overlaid:

``` r
plot_habitat_map(result)
```

The function automatically aggregates large rasters to prevent memory
issues, applies focal smoothing to bathymetry, and uses the official
Allen Coral Atlas colour scheme for habitat classes.

------------------------------------------------------------------------

## 3. Summarise Habitat Statistics

[`habitat_summary()`](https://viktorikowskii.github.io/ReefMappeR/reference/habitat_summary.md)
computes per-class area and depth statistics and produces a styled
summary table:

``` r
out <- habitat_summary(result)
out$table          # styled gt table
out$stats$benthic  # raw benthic statistics
out$stats$geomorph # raw geomorphic statistics
```

[`plot_depth_distribution()`](https://viktorikowskii.github.io/ReefMappeR/reference/plot_depth_distribution.md)
visualises the depth distribution of each habitat class as boxplots:

``` r
plot_depth_distribution(result)
```

------------------------------------------------------------------------

## 4. Water Quality from Sentinel-2

[`calc_ndci()`](https://viktorikowskii.github.io/ReefMappeR/reference/calc_ndci.md)
computes the Normalized Difference Chlorophyll Index (NDCI) from
Sentinel-2 bands B4 and B5. NDCI is a proxy for chlorophyll-a
concentration in coastal waters (Mishra & Mishra, 2012):

``` r
s2   <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                 package = "ReefMappeR"))
ndci <- calc_ndci(s2)
```

NDCI values range from -1 to 1. Values above 0.3 indicate high
chlorophyll-a, potentially associated with eutrophication or algal
blooms.

[`calculate_water_quality()`](https://viktorikowskii.github.io/ReefMappeR/reference/calculate_water_quality.md)
estimates Total Suspended Sediments (TSS) from Sentinel-2 bands B3, B4
and B8:

``` r
tss <- calculate_water_quality(s2)
```

------------------------------------------------------------------------

## 5. Detect Temporal Change

To detect change in chlorophyll-a between two dates, load two Sentinel-2
images from the same season and compute NDCI for each:

``` r
s2_24 <- terra::rast(system.file("extdata", "Sentinel2_2024_example.tif",
                                  package = "ReefMappeR"))
s2_25 <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                  package = "ReefMappeR"))

ndci_24 <- calc_ndci(s2_24)
ndci_25 <- calc_ndci(s2_25)
```

[`assess_reef_change()`](https://viktorikowskii.github.io/ReefMappeR/reference/assess_reef_change.md)
computes the pixel-wise NDCI difference:

``` r
change <- assess_reef_change(ndci_24, ndci_25)
```

[`compare_habitats_change()`](https://viktorikowskii.github.io/ReefMappeR/reference/compare_habitats_change.md)
classifies the change into three categories and visualises the result.
The default threshold of 0.1 can be adjusted:

``` r
compare_habitats_change(change)
compare_habitats_change(change, threshold = 0.05)
```

------------------------------------------------------------------------

## References

Allen Coral Atlas (2020). Coral reefs of the world.
<https://allencoralatlas.org>

Lyons, M.B. et al. (2020). Mapping the world’s coral reefs using a
global multiscale earth observation framework. *Remote Sensing in
Ecology and Conservation*, 6(4), 557–568.

Mishra, S. & Mishra, D.R. (2012). Normalized difference chlorophyll
index: A novel model for remote sensing of chlorophyll-a concentration
in turbid productive waters. *Remote Sensing of Environment*, 117,
394–406.
