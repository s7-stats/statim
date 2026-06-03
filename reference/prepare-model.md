# Lazily prepare a model inference

`prepare_model()` attaches a model specification to a `def_model`
object, producing a `model_lazy` ready for optional recalibration with
[`via()`](https://joshuamarie.github.io/statim/reference/via.md) before
being executed with
[`conclude()`](https://joshuamarie.github.io/statim/reference/conclude.md).

## Usage

``` r
prepare_model(.x, .model_fn, ...)
```

## Arguments

- .x:

  A `def_model` object from
  [`define_model()`](https://joshuamarie.github.io/statim/reference/model-define-base.md).

- .model_fn:

  A model function such as
  [`LINEAR_REG()`](https://joshuamarie.github.io/statim/reference/LINEAR_REG.md).

- ...:

  Additional arguments passed to methods.

## Value

A `model_lazy` S3 object.

## See also

[`prepare_test()`](https://joshuamarie.github.io/statim/reference/prepare-test.md),
[`define_model()`](https://joshuamarie.github.io/statim/reference/model-define-base.md),
[`via()`](https://joshuamarie.github.io/statim/reference/via.md),
[`conclude()`](https://joshuamarie.github.io/statim/reference/conclude.md)

## Examples

``` r
mtcars |>
    define_model(rel(mpg, wt)) |>
    prepare_model(LINEAR_REG) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : rel 
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
#> ─────────────────────────
#>     statistic    value   
#> ─────────────────────────
#>        R²        0.753   
#>      Adj. R²     0.745   
#>       Sigma      0.494   
#>   df (residual)  30.000  
#>         n        32.000  
#>    F-statistic   91.375  
#>       F df1      1.000   
#>       F df2      30.000  
#>     F p-value    0.000   
#> ─────────────────────────
#> 
#> 
```
