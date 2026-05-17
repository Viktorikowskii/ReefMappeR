# Crop datasets to a specified region of interest

Crops bathymetry (GEBCO), benthic habitats, geomorphology (Allen Coral
Atlas), and seagrass datasets to the extent of a Sentinel-2 image or
bounding box. Benthic and geomorphic data are mosaicked at native ~10 m
resolution; GEBCO bathymetry is resampled onto the ACA grid.

## Usage

``` r
set_roi(
  s2 = NULL,
  bathymetry = NULL,
  benthic = NULL,
  geomorph = NULL,
  seagrass = NULL,
  bbox = NULL
)
```

## Arguments

- s2:

  SpatRaster. Sentinel-2 image defining the ROI. Only the spatial extent
  is used. Optional, provide either `s2` or `bbox`.

- bathymetry:

  SpatRaster. If NULL, loads GEBCO_2024 from extdata.

- benthic:

  SpatRaster. If NULL, auto-loads matching Allen Coral Atlas tiles.

- geomorph:

  SpatRaster. If NULL, auto-loads matching Allen Coral Atlas tiles.

- seagrass:

  SpatVector. If NULL, loads the bundled GBR seagrass dataset.

- bbox:

  Numeric vector `c(xmin, xmax, ymin, ymax)` or an sf/sfc object
  defining the ROI. Optional, alternative to `s2`.

## Value

Named list with four elements:

- bathymetry:

  SpatRaster — bathymetry resampled to ACA grid (~10 m).

- benthic:

  SpatRaster — mosaicked benthic habitat classes (~10 m).

- geomorph:

  SpatRaster — mosaicked geomorphic classes (~10 m).

- seagrass:

  SpatVector — cropped seagrass polygons, or NULL if none intersect the
  ROI.

## Examples
