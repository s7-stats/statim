# Write multiple model definitions from a data frame

`write_models()` evaluates named model expressions sequentially against
`.data`, so each name is available to subsequent expressions via
[`stats::update()`](https://rdrr.io/r/stats/update.html). Accepts any
valid variable mapper `<var_id>`: `<formulas>`,
[`rel()`](https://s7-stats.github.io/statim/dev/reference/rel.md),
[`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md), or
any registered `var_id` type.

## Usage

``` r
write_models(.data, ...)
```

## Arguments

- .data:

  A data frame.

- ...:

  Named model expressions. Each must evaluate to a formula or a `var_id`
  object. Names are used as row labels in
  [`anova()`](https://s7-stats.github.io/statim/dev/reference/anova-mod.md)
  output and as the `model` column in
  [`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md).

## Value

An `expanded_model` object.

## Details

Sits between a data frame and
[`prepare_model()`](https://s7-stats.github.io/statim/dev/reference/prepare-model.md)
or
[`prepare_test()`](https://s7-stats.github.io/statim/dev/reference/prepare-test.md)
in the pipeline.

## See also

[`prepare_model()`](https://s7-stats.github.io/statim/dev/reference/prepare-model.md),
[`prepare_test()`](https://s7-stats.github.io/statim/dev/reference/prepare-test.md),
[`anova()`](https://s7-stats.github.io/statim/dev/reference/anova-mod.md),
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md),
[`display()`](https://s7-stats.github.io/statim/dev/reference/display.md)

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

# update() chain (formulas only)
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

# conclude() -> returns a multi_exec
LifeCycleSavings |>
    write_models(
        f1 = sr ~ 1,
        f2 = sr ~ pop15,
        f3 = sr ~ pop15 + pop75
    ) |>
    prepare_model(LINEAR_REG) |>
    conclude()
#> 
#> ── 3 models · Linear Regression ──────────────────────────────────────────────── 
#> 
#> f1 : <cld_exec>
#> f2 : <cld_exec>
#> f3 : <cld_exec>
#> 
#> Use display() to inspect individual results.
#> 

if (FALSE) { # \dontrun{
# display() -> show up to n models in full
LifeCycleSavings |>
    write_models(
        f1 = sr ~ 1,
        f2 = sr ~ pop15,
        f3 = sr ~ pop15 + pop75,
        f4 = sr ~ pop15 + pop75 + dpi,
        f5 = sr ~ pop15 + pop75 + dpi + ddpi
    ) |>
    prepare_model(LINEAR_REG) |>
    conclude() |>
    display(5)
} # }

# via rel()
mtcars |>
    define_model(rel(wt, mpg)) |>
    prepare_model(LINEAR_REG) |>
    anova()
#> 
#> == ANOVA · Type I ============================================================== 
#> 
#> -- ANOVA Table -----------------------------------------------------------------
#> 
#> ─────────────────────────────────────────────────────
#>     term     df    ss       ms     f_value  p_value  
#> ─────────────────────────────────────────────────────
#>      wt      1   847.725  847.725  91.375   <0.001   
#>   Residuals  30  278.322   9.277                     
#> ─────────────────────────────────────────────────────
#> 
#> 
mtcars |>
    write_models(
        m1 = rel(wt, mpg),
        m2 = rel(hp, mpg)
    ) |>
    prepare_model(LINEAR_REG) |>
    anova()
#> Warning: ! 1 non-nested model pair(s) detected.
#> ℹ The incremental F-test is undefined for models with equal complexity.
#> ℹ Affected rows will show empty test statistics, as in `stats::anova()`.
#> ℹ Non-nested positions: 1.
#> 
#> == ANOVA · F =================================================================== 
#> 
#> -- ANOVA Table -----------------------------------------------------------------
#> 
#> ───────────────────────────────────────────────────────────
#>   model  res_df  deviance  df  dev_diff  f_value  p_value  
#> ───────────────────────────────────────────────────────────
#>    m1      30    278.322                                   
#>    m2      30    447.674   0   -169.352                    
#> ───────────────────────────────────────────────────────────
#> 
#> 

# mixed var_id types in a single write_models() call
suppressWarnings({
    mtcars |>
        write_models(
            null = mpg ~ 1,
            m1 = rel(wt, mpg),
            m2 = rel(hp, mpg)
        ) |>
        prepare_model(LINEAR_REG) |>
        conclude()
})
#> 
#> ── 3 models · Linear Regression ──────────────────────────────────────────────── 
#> 
#> null : <cld_exec>
#> m1 : <cld_exec>
#> m2 : <cld_exec>
#> 
#> Use display() to inspect individual results.
#> 

# via prepare_test()
mtcars |>
    write_models(
        by_am = x_by(mpg, am),
        by_vs = x_by(mpg, vs)
    ) |>
    prepare_test(T_TEST) |>
    conclude()
#> 
#> ── 2 models · T-Test ─────────────────────────────────────────────────────────── 
#> 
#> by_am : <cld_exec>
#> by_vs : <cld_exec>
#> 
#> Use display() to inspect individual results.
#> 
```
