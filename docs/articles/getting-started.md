# Getting Started with ReefMappeR

``` r
library(ReefMappeR)
library(terra)
#> Warning: package 'terra' was built under R version 4.4.3
```

## Overview

ReefMappeR provides a streamlined workflow for mapping and analysing
reef habitats at the Great Barrier Reef using satellite remote sensing
and open marine datasets. This vignette walks through a complete
analysis of Tongue Reef, GBR, using two Sentinel-2 images from summer
2024 and 2025.

The workflow consists of three stages:

1.  **Habitat mapping** — load spatial data, visualise and summarise
    habitats
2.  **Water quality** — estimate chlorophyll-a and suspended sediments
3.  **Change detection** — compare two time points to detect NDCI change

------------------------------------------------------------------------

## 1. Define a Region of Interest

[`set_roi()`](https://viktorikowskii.github.io/ReefMappeR/reference/set_roi.md)
is the entry point of every ReefMappeR workflow. It automatically loads
and crops all bundled datasets to your area of interest. You can define
the ROI either by a bounding box or a Sentinel-2 image:

``` r
# Using a Sentinel-2 image
s2     <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                   package = "ReefMappeR"))
result <- set_roi(s2 = s2)
```

The result is a named list with four elements: `bathymetry`, `benthic`,
`geomorph`, and `seagrass`.

------------------------------------------------------------------------

## 2. Visualise Habitat Maps

[`plot_habitat_map()`](https://viktorikowskii.github.io/ReefMappeR/reference/plot_habitat_map.md)
creates a two-panel map with bathymetry as background and Allen Coral
Atlas benthic habitats and geomorphic zones overlaid:

``` r
plot_habitat_map(result)
```

![Two-panel habitat map of Tongue Reef showing benthic habitats (left)
and geomorphic zones (right) with bathymetry as
background.](../reference/figures/habitat_map.png)

Two-panel habitat map of Tongue Reef showing benthic habitats (left) and
geomorphic zones (right) with bathymetry as background.

------------------------------------------------------------------------

## 3. Summarise Habitat Statistics

[`habitat_summary()`](https://viktorikowskii.github.io/ReefMappeR/reference/habitat_summary.md)
computes per-class area and depth statistics and produces a styled
summary table:

``` r
out <- habitat_summary(result)
out$table          # styled gt table
out$stats$benthic  # raw statistics
```

![Summary table showing area, depth and cover statistics for benthic and
geomorphic habitat
classes.](../reference/figures/habitat_summary_table.png)

Summary table showing area, depth and cover statistics for benthic and
geomorphic habitat classes.

[`plot_depth_distribution()`](https://viktorikowskii.github.io/ReefMappeR/reference/plot_depth_distribution.md)
visualises the depth distribution of each habitat class as boxplots:

``` r
plot_depth_distribution(result)
```

![Boxplots showing depth distributions for benthic and geomorphic
habitat classes at Tongue
Reef.](../reference/figures/depth_distribution.png)

Boxplots showing depth distributions for benthic and geomorphic habitat
classes at Tongue Reef.

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

![NDCI map of Tongue Reef (August 2025). Values range from -1 to +1;
higher values indicate elevated
chlorophyll-a.](../reference/figures/ndci.png)

NDCI map of Tongue Reef (August 2025). Values range from -1 to +1;
higher values indicate elevated chlorophyll-a.

[`calculate_water_quality()`](https://viktorikowskii.github.io/ReefMappeR/reference/calculate_water_quality.md)
estimates Total Suspended Sediments (TSS):

``` r
tss <- calculate_water_quality(s2)
```

![TSS map of Tongue Reef (August 2025). Higher values indicate more
suspended sediments in the water column.](../reference/figures/tss.png)

TSS map of Tongue Reef (August 2025). Higher values indicate more
suspended sediments in the water column.

------------------------------------------------------------------------

## 5. Detect Temporal Change

To detect change in chlorophyll-a between two dates, load two Sentinel-2
images and compute NDCI for each:

``` r
s2_24  <- terra::rast(system.file("extdata", "Sentinel2_2024_example.tif",
                                   package = "ReefMappeR"))
s2_25  <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                   package = "ReefMappeR"))

change <- assess_reef_change(calc_ndci(s2_24), calc_ndci(s2_25))
compare_habitats_change(change)
```

![Temporal NDCI Change Classification for Tongue Reef (2024–2025). Red =
Chl-a increase, white = no significant change, green = Chl-a
decrease.](../reference/figures/ndci_change.png)

Temporal NDCI Change Classification for Tongue Reef (2024–2025). Red =
Chl-a increase, white = no significant change, green = Chl-a decrease.

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
