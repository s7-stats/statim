# Generalized linear model

A modified GLM for `{statim}` pipeline passed through
[`stats::glm()`](https://rdrr.io/r/stats/glm.html).

## Usage

``` r
GLM(.var_id = NULL, .data = NULL, ...)
```

## Arguments

- .var_id:

  A variable mapper `<var_id>` from
  [`define_model()`](https://s7-stats.github.io/statim/reference/layout-define-base.md),
  or `NULL` to return a `model_spec` for use in
  [`prepare_model()`](https://s7-stats.github.io/statim/reference/prepare-model.md).

- .data:

  A data frame. Used when `.var_id` is supplied directly.

- ...:

  Additional arguments passed to
  [`stats::glm()`](https://rdrr.io/r/stats/glm.html).

## Value

A `cld_exec` object in a `class_glm_object`, or a `model_spec` when
`.var_id = NULL`.

## Details

Additional arguments are passed to
[`stats::glm()`](https://rdrr.io/r/stats/glm.html). The most important
is `family`, which controls the error distribution and link function
(e.g. [`stats::binomial()`](https://rdrr.io/r/stats/family.html),
[`stats::poisson()`](https://rdrr.io/r/stats/family.html)). Defaults to
[`stats::gaussian()`](https://rdrr.io/r/stats/family.html) when omitted.

## Examples

``` r
# logistic regression
mtcars |>
    define_model(am ~ wt + hp) |>
    prepare_model(GLM) |>
    update(family = binomial()) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : formula 
#> Args : am ~ wt + hp 
#>     left_var : 1 
#>     right_var : 2 
#> 
#> == Generalized Linear Model ==================================================== 
#> 
#> -- Coefficients ----------------------------------------------------------------
#> 
#> ──────────────┬───────────────────────────────────────────
#>   term        │  estimate  std_error  statistic  p_value  
#> ──────────────┼───────────────────────────────────────────
#>   (Intercept) │   18.866     7.444      2.535     0.011   
#>   wt          │   -8.083     3.069     -2.634    <0.001   
#>   hp          │   0.036      0.018      2.044     0.041   
#> ──────────────┴───────────────────────────────────────────
#> 
#> 
#> -- Model Fit -------------------------------------------------------------------
#> 
#> ────────────────────────────────────────────────────────────────────────
#>    family   link   null_deviance  deviance  df_residual   aic    n_obs  
#> ────────────────────────────────────────────────────────────────────────
#>   binomial  logit     43.230       10.059       29       16.059   32    
#> ────────────────────────────────────────────────────────────────────────
#> 
#> 

if (FALSE) { # \dontrun{
# model comparison via anova()
mod1 = mtcars |>
    define_model(am ~ 1) |>
    prepare_model(GLM) |>
    update(family = binomial()) |>
    conclude()
mod2 = mtcars |>
    define_model(am ~ wt) |>
    prepare_model(GLM) |>
    update(family = binomial()) |>
    conclude()
mod3 = mtcars |>
    define_model(am ~ wt + hp) |>
    prepare_model(GLM) |>
    update(family = binomial()) |>
    conclude()

anova(mod1, mod2, mod3)
} # }
```
