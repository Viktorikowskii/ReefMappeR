# ReefMappeR

An R package for mapping and analysing reef habitats at the Great
Barrier Reef using satellite remote sensing and open marine datasets.

## Overview

ReefMappeR provides a streamlined workflow for researchers and students
working with reef ecosystem data. Starting from a bounding box or a
Sentinel-2 satellite image, the package automatically loads and crops
bathymetry, benthic habitat, geomorphology, and seagrass data to your
area of interest — and produces publication-ready maps and summary
statistics.

## Installation

``` r
# Install from GitHub
# install.packages("devtools")
devtools::install_github("Viktorikowskii/ReefMappeR")
```

## Data Requirements

ReefMappeR ships with bundled datasets for the Great Barrier Reef:

| Dataset                     | Source            | Bundled                 |
|-----------------------------|-------------------|-------------------------|
| Bathymetry (GBR)            | GEBCO 2024        | ✅ `bathymetry_gbr.tif` |
| Benthic habitat tiles (GBR) | Allen Coral Atlas | ✅ `benthic_gbr_*.tif`  |
| Geomorphic zone tiles (GBR) | Allen Coral Atlas | ✅ `geomorph_gbr_*.tif` |
| Seagrass polygons (GBR)     | UNEP-WCMC         | ✅ `seagrass_gbr.shp`   |

> **Note:** The bundled datasets cover the Great Barrier Reef region.
> For other regions, users need to supply their own data files.

## Workflow

    set_roi()  ──►  plot_habitat_map()
               └──►  habitat_summary()
               └──►  plot_depth_distribution()
               └──►  calc_ndci()  ──►  assess_reef_change()  ──►  compare_habitats_change()
                     calculate_water_quality()

## Basic Usage

### 1. Define your region of interest

``` r
library(ReefMappeR)

# Using a bounding box (xmin, xmax, ymin, ymax)
bbox   <- c(150.56, 151.30, -21.51, -20.77)
result <- set_roi(bbox = bbox)

# Or using a Sentinel-2 image
s2     <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                   package = "ReefMappeR"))
result <- set_roi(s2 = s2)
```

### 2. Visualise habitat maps

``` r
plot_habitat_map(result)
```

![Habitat map showing benthic habitats and geomorphic zones over Tongue
Reef, GBR](reference/figures/habitat_map.png)

Habitat map showing benthic habitats and geomorphic zones over Tongue
Reef, GBR

### 3. Summarise habitat statistics

``` r
out <- habitat_summary(result)
out$table          # styled gt summary table
out$stats$benthic  # raw benthic statistics
```

![Habitat summary table](reference/figures/habitat_summary_table.png)

Habitat summary table

``` r
plot_depth_distribution(result)
```

![Depth distributions by habitat
class](reference/figures/depth_distribution.png)

Depth distributions by habitat class

### 4. Analyse water quality from Sentinel-2

``` r
s2   <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                 package = "ReefMappeR"))

# NDCI — Chlorophyll-a indicator
ndci <- calc_ndci(s2)
```

![NDCI map of Tongue Reef, GBR](reference/figures/ndci.png)

NDCI map of Tongue Reef, GBR

``` r
# Total Suspended Sediments
tss <- calculate_water_quality(s2)
```

![TSS map of Tongue Reef, GBR](reference/figures/tss.png)

TSS map of Tongue Reef, GBR

### 5. Detect reef change over time

``` r
s2_24  <- terra::rast(system.file("extdata", "Sentinel2_2024_example.tif",
                                   package = "ReefMappeR"))
s2_25  <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                   package = "ReefMappeR"))

change <- assess_reef_change(calc_ndci(s2_24), calc_ndci(s2_25))
compare_habitats_change(change)
```

![Temporal NDCI Change
Classification](reference/figures/ndci_change.png)

Temporal NDCI Change Classification

## Functions

| Function | Description |
|----|----|
| [`set_roi()`](https://viktorikowskii.github.io/ReefMappeR/reference/set_roi.md) | Crop all datasets to a bounding box or Sentinel-2 extent |
| [`plot_habitat_map()`](https://viktorikowskii.github.io/ReefMappeR/reference/plot_habitat_map.md) | Two-panel map of benthic habitats and geomorphic zones |
| [`habitat_summary()`](https://viktorikowskii.github.io/ReefMappeR/reference/habitat_summary.md) | Area statistics and depth distributions as a table |
| [`plot_depth_distribution()`](https://viktorikowskii.github.io/ReefMappeR/reference/plot_depth_distribution.md) | Depth distributions per habitat class as boxplots |
| [`calc_ndci()`](https://viktorikowskii.github.io/ReefMappeR/reference/calc_ndci.md) | Calculate NDCI from Sentinel-2 bands B4/B5 |
| [`calculate_water_quality()`](https://viktorikowskii.github.io/ReefMappeR/reference/calculate_water_quality.md) | Estimate TSS from Sentinel-2 |
| [`assess_reef_change()`](https://viktorikowskii.github.io/ReefMappeR/reference/assess_reef_change.md) | Compute pixel-wise NDCI difference between two dates |
| [`compare_habitats_change()`](https://viktorikowskii.github.io/ReefMappeR/reference/compare_habitats_change.md) | Classify and visualise NDCI change |

## Dependencies

ReefMappeR depends on: `terra`, `sf`, `ggplot2`, `ggnewscale`, `dplyr`,
`patchwork`, `gt`, `stringr`.

## License

MIT © 2025 Viktoria Veith
