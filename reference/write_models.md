# Write multiple model definitions from a data frame

`write_models()` evaluates named model expressions sequentially against
`.data`, so each name is available to subsequent expressions via
[`stats::update()`](https://rdrr.io/r/stats/update.html). Accepts any
valid model ID: formulas,
[`rel()`](https://joshuamarie.github.io/statim/reference/rel.md),
[`x_by()`](https://joshuamarie.github.io/statim/reference/x_by.md), or
any registered `model_id` type.

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
  [`anova()`](https://joshuamarie.github.io/statim/reference/anova-mod.md)
  output.

## Value

An `expanded_model` object.

## Details

Sits between a data frame and
[`prepare_model()`](https://joshuamarie.github.io/statim/reference/prepare-model.md)
or
[`prepare_test()`](https://joshuamarie.github.io/statim/reference/prepare-test.md)
in the pipeline.

## See also

[`prepare_model()`](https://joshuamarie.github.io/statim/reference/prepare-model.md),
[`anova()`](https://joshuamarie.github.io/statim/reference/anova-mod.md)

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
#>     1      49    983.628                                   
#>     2      48    779.511   1   204.118   14.116   <0.001   
#>     3      47    726.168   1    53.343    3.689    0.061   
#>     4      46    713.767   1    12.401    0.858    0.359   
#>     5      45    650.713   1    63.054    4.360    0.042   
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
#>     1      49    983.628                                   
#>     2      48    779.511   1   204.118   14.116   <0.001   
#>     3      47    726.168   1    53.343    3.689    0.061   
#>     4      46    713.767   1    12.401    0.858    0.359   
#>     5      45    650.713   1    63.054    4.360    0.042   
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
#>     1      48    779.511                                   
#>     2      49    983.628   -1  -204.118  12.569            
#>     3      48    779.511   1   204.118   12.569   <0.001   
#> ───────────────────────────────────────────────────────────
#> 
#> 
```
