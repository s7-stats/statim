# ANOVA table for linear model comparisons

`anova()` computes an incremental F-test across two or more fitted
linear models. It dispatches on four input types:

## Usage

``` r
anova(object, ..., test = "F")
```

## Format

An object of class `S7_external_generic` of length 4.

## Arguments

- object:

  A `multi_lazy`, `anova_lazy`, `model_lazy`, or `cld_exec` object.

- ...:

  Additional `model_lazy` or `cld_exec` objects.

- test:

  A string. One of `"F"` (default), `"LRT"`, or `"Chisq"`.

## Value

A `cld_anova` object, invisibly.

## Details

- A `multi_lazy` from `write_models() |> prepare_model()`.

- An `anova_lazy` from `write_models() |> prepare_model()` (legacy path,
  kept for backward compatibility).

- One or more `model_lazy` objects from
  [`prepare_model()`](https://s7-stats.github.io/statim/dev/reference/prepare-model.md).

- One or more `cld_exec` objects from
  [`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md).

## See also

[`write_models()`](https://s7-stats.github.io/statim/dev/reference/write_models.md),
[`prepare_model()`](https://s7-stats.github.io/statim/dev/reference/prepare-model.md),
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)

## Examples

``` r
# via write_models()
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

# via model_lazy
mod1 = LifeCycleSavings |> define_model(sr ~ 1) |> prepare_model(LINEAR_REG)
mod2 = LifeCycleSavings |> define_model(sr ~ pop15) |> prepare_model(LINEAR_REG)

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

# via conclude()
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
anova(mod1, mod2, test = "LRT")
#> 
#> == ANOVA · LRT ================================================================= 
#> 
#> -- ANOVA Table -----------------------------------------------------------------
#> 
#> ───────────────────────────────────────────────────────────────
#>   model  res_df  deviance  df  dev_diff  chisq_value  p_value  
#> ───────────────────────────────────────────────────────────────
#>     1      49    983.628                                       
#>     2      48    779.511   1   204.118     12.569     <0.001   
#> ───────────────────────────────────────────────────────────────
#> 
#> 
```
