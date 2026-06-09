# ANOVA

`ANOVA()` performs an analysis of variance for one-way, two-way, or
formula-based comparisons. If `ANOVA` is supplied within the lazy-loaded
pipeline, supply `ANOVA` as a function within i.e.
`prepare_test(.test = ANOVA)` call.

## Usage

``` r
ANOVA(.model = NULL, .data = NULL, ...)
```

## Arguments

- .model:

  A model ID from
  [`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md) or a
  formula. When supplied, the test executes immediately.

- .data:

  A data frame. Only used on the standalone path.

- ...:

  Additional arguments passed to the implementation.

## Value

A `cld_exec` object (pipeline), or a `test_spec` object.

## Supported model IDs

- [`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md):
  one-way or two-way ANOVA

- formula: standard [`aov()`](https://rdrr.io/r/stats/aov.html) formula
  interface

## Examples

``` r
# pipeline — one-way
npk |>
    define_model(x_by(yield, block)) |>
    prepare_test(ANOVA) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : x_by 
#> Args : yield | block 
#>     x_vars : 1 
#>     by_vars : 1 
#> 
#> == ANOVA ======================================================================= 
#> 
#> -- ANOVA Table -----------------------------------------------------------------
#> 
#> ────────────────────────────────────────────────
#>     term     df    SS       MS      F    pval   
#> ────────────────────────────────────────────────
#>     block    5   343.295  68.659  2.318  0.086  
#>   Residuals  18  533.070  29.615                
#> ────────────────────────────────────────────────
#> 

# pipeline — two-way
npk |>
    define_model(x_by(yield, c(block, N))) |>
    prepare_test(ANOVA) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : x_by 
#> Args : yield | block, N 
#>     x_vars : 1 
#>     by_vars : 2 
#> 
#> == ANOVA ======================================================================= 
#> 
#> -- ANOVA Table -----------------------------------------------------------------
#> 
#> ──────────────────────────────────────────────────
#>     term     df    SS       MS       F     pval   
#> ──────────────────────────────────────────────────
#>     block    5   343.295  68.659   3.395  0.026   
#>       N      1   189.282  189.282  9.360  <0.001  
#>   Residuals  17  343.788  20.223                  
#> ──────────────────────────────────────────────────
#> 

# formula interface
npk |>
    define_model(yield ~ block + N) |>
    prepare_test(ANOVA) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : formula 
#> Args : yield ~ block + N 
#>     left_var : 1 
#>     right_var : 2 
#> 
#> == ANOVA ======================================================================= 
#> 
#> -- ANOVA Table -----------------------------------------------------------------
#> 
#> ──────────────────────────────────────────────────
#>     term     df    SS       MS       F     pval   
#> ──────────────────────────────────────────────────
#>     block    5   343.295  68.659   3.395  0.026   
#>       N      1   189.282  189.282  9.360  <0.001  
#>   Residuals  17  343.788  20.223                  
#> ──────────────────────────────────────────────────
#> 

# with hypothesis
npk |>
    define_model(x_by(yield, block)) |>
    prepare_test(ANOVA) |>
    state_null(
        MU(yield, block == "1") %=%
        MU(yield, block == "2") %=%
        MU(yield, block == "3")
    ) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : x_by 
#> Args : yield | block 
#>     x_vars : 1 
#>     by_vars : 1 
#> 
#> == ANOVA ======================================================================= 
#> 
#> -- ANOVA Table -----------------------------------------------------------------
#> 
#> ────────────────────────────────────────────────
#>     term     df    SS       MS      F    pval   
#> ────────────────────────────────────────────────
#>     block    5   343.295  68.659  2.318  0.086  
#>   Residuals  18  533.070  29.615                
#> ────────────────────────────────────────────────
#> 
```
