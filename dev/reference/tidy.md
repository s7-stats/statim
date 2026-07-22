# Tidy a concluded statistical result

`tidy()` extracts a tibble of primary results from a `cld_exec` object
produced by
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md).

## Usage

``` r
tidy(.x, ...)
```

## Arguments

- .x:

  A `cld_exec` object produced by
  [`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md).

- ...:

  Passed to the dispatched method.

## Value

The statistical output in a `tibble` data frame format.

## Dispatch

Two paths are tried in order:

**Path 1:
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md)
(preferred).** When `cld_exec@data` is a
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md)
subclass,
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md)
is called directly on it. You need no registry, and S7 automatically
dispatches on the particular output class, and variants that return the
same class inherit the method automatically via the parent chain.

**Path 2:
[`making_tidy()`](https://s7-stats.github.io/statim/dev/reference/making_tidy.md)
registry (escape hatch).** When `cld_exec@data` is not a
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md)
subclass, for example, when a variant intentionally returns any data
structure e.g. just a plain list, S3, S4, or R6 object
(`check_sic_s7 = FALSE`), `tidy()` falls back to the registry populated
by
[`making_tidy()`](https://s7-stats.github.io/statim/dev/reference/making_tidy.md).
If no entry exists there either, an informative error is raised.

## See also

[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md),
[`making_tidy()`](https://s7-stats.github.io/statim/dev/reference/making_tidy.md),
[`method_tidy()`](https://s7-stats.github.io/statim/dev/reference/method_tidy.md),
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md)

## Examples

``` r
mtcars |>
    define_model(mpg ~ .) |>
    prepare_model(LINEAR_REG) |>
    conclude() |>
    tidy()
#> # A tibble: 11 × 5
#>    term        estimate std_error statistic p_value
#>    <chr>          <dbl>     <dbl>     <dbl>   <dbl>
#>  1 (Intercept)  12.3      18.7        0.657  0.518 
#>  2 cyl          -0.111     1.05      -0.107  0.916 
#>  3 disp          0.0133    0.0179     0.747  0.463 
#>  4 hp           -0.0215    0.0218    -0.987  0.335 
#>  5 drat          0.787     1.64       0.481  0.635 
#>  6 wt           -3.72      1.89      -1.96   0.0633
#>  7 qsec          0.821     0.731      1.12   0.274 
#>  8 vs            0.318     2.10       0.151  0.881 
#>  9 am            2.52      2.06       1.23   0.234 
#> 10 gear          0.655     1.49       0.439  0.665 
#> 11 carb         -0.199     0.829     -0.241  0.812 
```
