# Write multiple model definitions from a data frame

`write_models()` evaluates named model expressions sequentially against
`.data`, so each name is available to subsequent expressions via
[`stats::update()`](https://rdrr.io/r/stats/update.html). Accepts any
valid model ID: formulas,
[`rel()`](https://s7-stats.github.io/statim/reference/rel.md),
[`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md), or any
registered `model_id` type.

## Usage

``` r
write_models(.data, ...)
```

## Arguments

- .data:

  A data frame.

- ...:

  Named model expressions. Each must evaluate to a formula or a
  `model_id` object. Names are used as row labels in
  [`anova()`](https://s7-stats.github.io/statim/reference/anova-mod.md)
  output.

## Value

An `expanded_model` object.

## Details

Sits between a data frame and
[`prepare_model()`](https://s7-stats.github.io/statim/reference/prepare-model.md)
or
[`prepare_test()`](https://s7-stats.github.io/statim/reference/prepare-test.md)
in the pipeline.

## See also

[`prepare_model()`](https://s7-stats.github.io/statim/reference/prepare-model.md),
[`anova()`](https://s7-stats.github.io/statim/reference/anova-mod.md)

## Examples

``` r
# explicit formulas
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
#>    f1      49    983.628                                   
#>    f2      48    779.511   1   204.118   14.116   <0.001   
#>    f3      47    726.168   1    53.343    3.689    0.061   
#>    f4      46    713.767   1    12.401    0.858    0.359   
#>    f5      45    650.713   1    63.054    4.360    0.042   
#> ───────────────────────────────────────────────────────────
#> 
#> 

# update() chain
LifeCycleSavings |>
    write_models(
        f1 = sr ~ 1,
        f2 = update(f1, ~. + pop15),
        f3 = update(f2, ~. + pop75),
        f4 = update(f3, ~. + dpi),
        f5 = update(f4, ~. + ddpi)
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
#>    f1      49    983.628                                   
#>    f2      48    779.511   1   204.118   14.116   <0.001   
#>    f3      47    726.168   1    53.343    3.689    0.061   
#>    f4      46    713.767   1    12.401    0.858    0.359   
#>    f5      45    650.713   1    63.054    4.360    0.042   
#> ───────────────────────────────────────────────────────────
#> 
#> 

# mixed model_id types
LifeCycleSavings |>
    write_models(
        mod0 = rel(pop15, sr),
        f1 = sr ~ 1,
        f2 = update(f1, ~. + pop15)
    ) |>
    prepare_model(LINEAR_REG) |>
    anova()
#> Warning: NaNs produced
#> 
#> == ANOVA · F =================================================================== 
#> 
#> -- ANOVA Table -----------------------------------------------------------------
#> 
#> ───────────────────────────────────────────────────────────
#>   model  res_df  deviance  df  dev_diff  f_value  p_value  
#> ───────────────────────────────────────────────────────────
#>   mod0     48    779.511                                   
#>    f1      49    983.628   -1  -204.118  12.569            
#>    f2      48    779.511   1   204.118   12.569   <0.001   
#> ───────────────────────────────────────────────────────────
#> 
#> 
```
