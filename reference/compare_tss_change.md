# Temporal TSS Change Classification

Classifies pixel-wise TSS change between two time points into three
categories: increase in suspended sediments, no significant change, and
decrease in suspended sediments.

## Usage

``` r
compare_tss_change(tss_change, threshold = 0.5)
```

## Arguments

- tss_change:

  SpatRaster. Output of
  [`assess_reef_change()`](https://viktorikowskii.github.io/ReefMappeR/reference/assess_reef_change.md)
  applied to two TSS rasters from
  [`calc_tss()`](https://viktorikowskii.github.io/ReefMappeR/reference/calc_tss.md).

- threshold:

  Numeric. Minimum absolute TSS change (g/m3) to be considered
  significant. Default is 0.5. See Details.

## Value

Invisible NULL. Called for side effects (plot).

## Details

TSS change is classified into three classes:

- TSS increase (change \> +threshold): Indicates increased suspended
  sediment load, potentially associated with storm events, dredging, or
  increased runoff from land.

- No significant change (\|change\| \<= threshold): Change within the
  defined threshold, interpreted as natural variability.

- TSS decrease (change \< -threshold): Indicates reduced suspended
  sediment load, potentially reflecting calmer conditions or reduced
  terrestrial input.

The default threshold of 0.5 g/m3 is an exploratory convention. No
universally established threshold exists for TSS change classification.
Users are encouraged to adjust based on local conditions and in-situ
measurements.

## References

Alvarez-Romero, J.G. et al. (2013). Quantifying the effects of
terrestrial runoff on coral reefs. *PLoS ONE*, 8(11), e78689.
[doi:10.1371/journal.pone.0078689](https://doi.org/10.1371/journal.pone.0078689)

## See also

[`calc_tss()`](https://viktorikowskii.github.io/ReefMappeR/reference/calc_tss.md),
[`assess_reef_change()`](https://viktorikowskii.github.io/ReefMappeR/reference/assess_reef_change.md)

## Examples

``` r
if (FALSE) { # \dontrun{
s2_24  <- terra::rast(system.file("extdata", "Sentinel2_2024_example.tif",
                                   package = "ReefMappeR"))
s2_25  <- terra::rast(system.file("extdata", "Sentinel2_example.tif",
                                   package = "ReefMappeR"))
tss_24 <- calc_tss(s2_24)
tss_25 <- calc_tss(s2_25)
change <- assess_reef_change(tss_24, tss_25)
compare_tss_change(change)
compare_tss_change(change, threshold = 1.0)
} # }
```
