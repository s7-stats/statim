# Correlation Test

`CORTEST()` performs a correlation test for one-to-one or many-to-one
variable relationships. If `CORTEST` is supplied within the lazy-loaded
pipeline, supply `CORTEST` as a function i.e.
`prepare_test(.test = CORTEST)` call.

## Usage

``` r
CORTEST(.model = NULL, .data = NULL, ...)
```

## Arguments

- .model:

  A registered model ID for `CORTEST()`, e.g.
  [`rel()`](https://s7-stats.github.io/statim/reference/rel.md). When
  supplied, the test executes immediately.

- .data:

  A data frame. Only used on the standalone path.

- ...:

  Additional arguments passed to the implementation: `.cor_type`,
  `.alt`, `.ci` for the classical path.

## Value

An `htest_spec` object (standalone or eager), or a `test_spec` object
(pipeline).

## Supported model IDs

- [`rel()`](https://s7-stats.github.io/statim/reference/rel.md) —
  many-to-one correlation test

## Examples

``` r
# eager
CORTEST(rel(speed, dist), cars)
#> -- Summary ---------------------------------------------------------------------
#> 
#> ─────────────────────────────────────────
#>       pair      estimate  stat    pval   
#> ─────────────────────────────────────────
#>   dist ~ speed   0.807    9.464  <0.001  
#> ─────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ────────────────────────────────────
#>       pair      lower_95  upper_95  
#> ────────────────────────────────────
#>   dist ~ speed   0.682     0.886    
#> ────────────────────────────────────
#> 
#> 

# pipeline
cars |>
    define_model(rel(speed, dist)) |>
    prepare_test(CORTEST) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : rel 
#> Args : speed ; dist 
#>     x_vars : 1 
#>     resp_vars : 1 
#> 
#> == Correlation Test ============================================================ 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ─────────────────────────────────────────
#>       pair      estimate  stat    pval   
#> ─────────────────────────────────────────
#>   dist ~ speed   0.807    9.464  <0.001  
#> ─────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ────────────────────────────────────
#>       pair      lower_95  upper_95  
#> ────────────────────────────────────
#>   dist ~ speed   0.682     0.886    
#> ────────────────────────────────────
#> 
#> 
```
