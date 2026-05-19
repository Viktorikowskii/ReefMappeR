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

  SpatRaster. GEBCO bathymetry cropped and resampled to ACA grid (~10
  m).

- benthic:

  SpatRaster. Allen Coral Atlas benthic habitat classes cropped to ROI.

- geomorph:

  SpatRaster. Allen Coral Atlas geomorphic zones cropped to ROI.

- seagrass:

  SpatVector. UNEP-WCMC seagrass polygons clipped to ROI.

## Examples

``` r
bbox <- c(150.56, 151.30, -21.51, -20.77)
result <- set_roi(bbox = bbox)
#> Loaded: bathymetry_gbr.tif
#> Found 5/99 file(s) with prefix 'benthic_gbr_' overlapping ROI (150.5600, 151.3000, -21.5100, -20.7700).
#> Loaded 5 benthic tile(s).
#> Found 5/100 file(s) with prefix 'geomorph_gbr_' overlapping ROI (150.5600, 151.3000, -21.5100, -20.7700).
#> Loaded 5 geomorphic tile(s).
#> Building virtual mosaic for 5 benthic tile(s)...
#> Building virtual mosaic for 5 geomorphic tile(s)...
#> Resampling bathymetry to ACA grid...
#> |---------|---------|---------|---------|=========================================                                          
plot(result$benthic)

#> Error in plot.xy(xy, type, ...): invalid type passed to graphics function

if (FALSE) { # \dontrun{
s2_img <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                   package = "ReefMappeR"))
result  <- set_roi(s2 = s2_img)
plot(result$benthic)
} # }
```
