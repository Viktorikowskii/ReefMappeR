# Habitat statistics summary for a region of interest

Computes per-class area and depth statistics from the output of
[`set_roi()`](https://viktorikowskii.github.io/ReefMappeR/reference/set_roi.md)
and produces a styled summary table.

## Usage

``` r
habitat_summary(result)
```

## Arguments

- result:

  Named list returned by
  [`set_roi()`](https://viktorikowskii.github.io/ReefMappeR/reference/set_roi.md).

## Value

Invisibly returns a named list with:

- table:

  A styled `gt` summary table of benthic and geomorphic habitat
  statistics.

- stats:

  A named list with data frames `benthic`, `geomorph`, and `seagrass`.

## See also

[`plot_depth_distribution()`](https://viktorikowskii.github.io/ReefMappeR/reference/plot_depth_distribution.md)
for depth distribution plots.

## Examples

``` r
if (FALSE) { # \dontrun{
bbox   <- c(150.56, 151.30, -21.51, -20.77)
result <- set_roi(bbox = bbox)
out    <- habitat_summary(result)
out$table
out$stats$benthic
} # }
```
