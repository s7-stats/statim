# Linear regression

Fits an ordinary least squares linear regression model. Accepts
[`rel()`](https://joshuamarie.github.io/statim/reference/rel.md) or a
formula as the model ID.

## Usage

``` r
LINEAR_REG(.model = NULL, .data = NULL, ...)
```

## Arguments

- .model:

  A model ID from
  [`define_model()`](https://joshuamarie.github.io/statim/reference/model-define-base.md),
  or `NULL` to return a `model_spec` for use in
  [`prepare_model()`](https://joshuamarie.github.io/statim/reference/prepare-model.md).

- .data:

  A data frame. Used when `.model` is supplied directly.

- ...:

  Currently unused.

## Value

A `cld_exec` object containing a
[class_lm_object](https://joshuamarie.github.io/statim/reference/class_lm_object.md),
or a `model_spec` when `.model = NULL`.

## Details

The result is an
[class_lm_object](https://joshuamarie.github.io/statim/reference/class_lm_object.md),
which satisfies the
[`anova()`](https://joshuamarie.github.io/statim/reference/anova-mod.md)
protocol and prints coefficients and model fit universally across all
engines and variants.

## Examples

``` r
# via rel()
cars |>
    define_model(rel(speed, dist)) |>
    prepare_model(LINEAR_REG) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : rel 
#> Args : speed ; dist 
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
#>   (Intercept) │  -17.579     6.758     -2.601     0.012   
#>   speed       │   3.932      0.416      9.464    <0.001   
#> ──────────────┴───────────────────────────────────────────
#> 
#> 
#> -- Model Fit -------------------------------------------------------------------
#> 
#> ─────────────────────────
#>     statistic    value   
#> ─────────────────────────
#>        R²        0.651   
#>      Adj. R²     0.644   
#>       Sigma      15.380  
#>   df (residual)  48.000  
#>         n        50.000  
#>    F-statistic   89.567  
#>       F df1      1.000   
#>       F df2      48.000  
#>     F p-value    0.000   
#> ─────────────────────────
#> 
#> 

# via formula
cars |>
    define_model(dist ~ speed) |>
    prepare_model(LINEAR_REG) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : formula 
#> Args : dist ~ speed 
#>     left_var : 1 
#>     right_var : 1 
#> 
#> == Linear Regression =========================================================== 
#> 
#> -- Coefficients ----------------------------------------------------------------
#> 
#> ──────────────┬───────────────────────────────────────────
#>   term        │  estimate  std_error  statistic  p_value  
#> ──────────────┼───────────────────────────────────────────
#>   (Intercept) │  -17.579     6.758     -2.601     0.012   
#>   speed       │   3.932      0.416      9.464    <0.001   
#> ──────────────┴───────────────────────────────────────────
#> 
#> 
#> -- Model Fit -------------------------------------------------------------------
#> 
#> ─────────────────────────
#>     statistic    value   
#> ─────────────────────────
#>        R²        0.651   
#>      Adj. R²     0.644   
#>       Sigma      15.380  
#>   df (residual)  48.000  
#>         n        50.000  
#>    F-statistic   89.567  
#>       F df1      1.000   
#>       F df2      48.000  
#>     F p-value    0.000   
#> ─────────────────────────
#> 
#> 

# write_models() pipeline
LifeCycleSavings |>
    write_models(
        f1 = sr ~ 1,
        f2 = sr ~ pop15,
        f3 = sr ~ pop15 + pop75,
        f4 = sr ~ pop15 + pop75 + dpi,
        f5 = sr ~ pop15 + pop75 + dpi + ddpi
    ) |>
    prepare_model(LINEAR_REG) |>
    anova()
#> 
#> == ANOVA · F =================================================================== 
#> 
#> -- ANOVA Table -----------------------------------------------------------------
#> 
#> ───────────────────────────────────────────────────────────
#>   model  res_df  deviance  df  dev_diff  f_value  p_value  
#> ───────────────────────────────────────────────────────────
#>     1      49    983.628                                   
#>     2      48    779.511   1   204.118   14.116   <0.001   
#>     3      47    726.168   1    53.343    3.689    0.061   
#>     4      46    713.767   1    12.401    0.858    0.359   
#>     5      45    650.713   1    63.054    4.360    0.042   
#> ───────────────────────────────────────────────────────────
#> 
#> 

# individual conclude(), compare after
mod1 = LifeCycleSavings |> define_model(sr ~ 1) |> prepare_model(LINEAR_REG) |> conclude()
mod2 = LifeCycleSavings |> define_model(sr ~ pop15) |> prepare_model(LINEAR_REG) |> conclude()

anova(mod1, mod2)
#> 
#> == ANOVA · F =================================================================== 
#> 
#> -- ANOVA Table -----------------------------------------------------------------
#> 
#> ───────────────────────────────────────────────────────────
#>   model  res_df  deviance  df  dev_diff  f_value  p_value  
#> ───────────────────────────────────────────────────────────
#>     1      49    983.628                                   
#>     2      48    779.511   1   204.118   12.569   <0.001   
#> ───────────────────────────────────────────────────────────
#> 
#> 
```
