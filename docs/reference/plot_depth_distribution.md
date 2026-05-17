# Plot depth distributions by habitat class

Produces boxplots showing the depth distribution of benthic and
geomorphic habitat classes, and optionally a histogram for seagrass
depth, from the output of
[`set_roi()`](https://viktorikowskii.github.io/ReefMappeR/reference/set_roi.md).

## Usage

``` r
plot_depth_distribution(result)
```

## Arguments

- result:

  Named list returned by
  [`set_roi()`](https://viktorikowskii.github.io/ReefMappeR/reference/set_roi.md).

## Value

Invisibly returns a `patchwork` plot object. The plot is printed
automatically.

## See also

[`habitat_summary()`](https://viktorikowskii.github.io/ReefMappeR/reference/habitat_summary.md)
for area and depth statistics as a table.

## Examples

``` r
if (FALSE) { # \dontrun{
bbox   <- c(150.56, 151.30, -21.51, -20.77)
result <- set_roi(bbox = bbox)
plot_depth_distribution(result)
} # }
```
