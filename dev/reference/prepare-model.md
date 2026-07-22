# Lazily prepare a model inference

`prepare_model()` attaches a model specification to a `<def_var>`
object, producing a `<model_lazy>` ready for optional recalibration with
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md) before
being executed with
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md).

## Usage

``` r
prepare_model(.x, .model_fn, ...)
```

## Arguments

- .x:

  An S7 object extension yielded by, e.g. `<def_var>` object from
  [`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md),
  or an `<expanded_model>` object from
  [`write_models()`](https://s7-stats.github.io/statim/dev/reference/write_models.md).

- .model_fn:

  A model function such as
  [`LINEAR_REG()`](https://s7-stats.github.io/statim/dev/reference/LINEAR_REG.md).

- ...:

  Additional arguments passed to methods.

## Value

A `<model_lazy>` S7 object.

## See also

[`prepare_test()`](https://s7-stats.github.io/statim/dev/reference/prepare-test.md),
[`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md),
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md),
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)

## Examples

``` r
mtcars |>
    define_model(rel(mpg, wt)) |>
    prepare_model(LINEAR_REG) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : rel 
#> Args : mpg ; wt 
#>     x_vars : 1 
#>     resp_vars : 1 
#> 
#> == Linear Regression =========================================================== 
#> 
#> -- Coefficients ----------------------------------------------------------------
#> 
#> ──────────────┬───────────────────────────────────────────
#>   term        │  estimate  std_error  statistic  p_value  
#> ──────────────┼───────────────────────────────────────────
#>   (Intercept) │   6.047      0.309     19.590    <0.001   
#>   mpg         │   -0.141     0.015     -9.559    <0.001   
#> ──────────────┴───────────────────────────────────────────
#> 
#> 
#> -- Model Fit -------------------------------------------------------------------
#> 
#> Warning: running command 'tput cols' had status 2
#> ------------------------------------------------------
#>   R Squared      :    0.75    F-statistic :    91.38
#>   Adj. R Squared :    0.74    df1         :        1
#>   Sigma          :    0.49    df2         :       30
#>   n              :      32    p-value     :   <0.001
#>   df (residual)  :      30                :         
#> ------------------------------------------------------
#> 
#> 
```
