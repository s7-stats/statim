# Write multiple model definitions from a data frame

`write_models()` evaluates named model expressions sequentially against
`.data`, so each name is available to subsequent expressions via
[`stats::update()`](https://rdrr.io/r/stats/update.html). Accepts any
valid variable mapper `<var_id>`: `<formulas>`,
[`rel()`](https://s7-stats.github.io/statim/reference/rel.md),
[`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md), or any
registered `var_id` type.

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
  [`anova()`](https://s7-stats.github.io/statim/reference/anova-mod.md)
  output and as the `model` column in
  [`tidy()`](https://s7-stats.github.io/statim/reference/tidy.md).

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
[`prepare_test()`](https://s7-stats.github.io/statim/reference/prepare-test.md),
[`anova()`](https://s7-stats.github.io/statim/reference/anova-mod.md),
[`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md),
[`display()`](https://s7-stats.github.io/statim/reference/display.md)

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

# conclude() — returns a multi_exec
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

# display() — show up to n models in full
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
#> 
#> 1. f1
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : formula 
#> Args : sr ~ 1 
#>     left_var : 1 
#>     right_var : 0 
#> 
#> == Linear Regression =========================================================== 
#> 
#> -- Coefficients ----------------------------------------------------------------
#> 
#> ──────────────┬───────────────────────────────────────────
#>   term        │  estimate  std_error  statistic  p_value  
#> ──────────────┼───────────────────────────────────────────
#>   (Intercept) │   9.671      0.634     15.263    <0.001   
#> ──────────────┴───────────────────────────────────────────
#> 
#> 
#> -- Model Fit -------------------------------------------------------------------
#> 
#> Warning: running command 'tput cols' had status 2
#> -----------------------------------------------------
#>   R Squared      :    0.00    F-statistic :     NaN
#>   Adj. R Squared :    0.00    df1         :       0
#>   Sigma          :    4.48    df2         :      49
#>   n              :      50    p-value     :     NaN
#>   df (residual)  :      49                :        
#> -----------------------------------------------------
#> 
#> 
#> 
#> 2. f2
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : formula 
#> Args : sr ~ pop15 
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
#>   (Intercept) │   17.497     2.280      7.675    <0.001   
#>   pop15       │   -0.223     0.063     -3.545    <0.001   
#> ──────────────┴───────────────────────────────────────────
#> 
#> 
#> -- Model Fit -------------------------------------------------------------------
#> 
#> Warning: running command 'tput cols' had status 2
#> ------------------------------------------------------
#>   R Squared      :    0.21    F-statistic :    12.57
#>   Adj. R Squared :    0.19    df1         :        1
#>   Sigma          :    4.03    df2         :       48
#>   n              :      50    p-value     :   <0.001
#>   df (residual)  :      48                :         
#> ------------------------------------------------------
#> 
#> 
#> 
#> 3. f3
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : formula 
#> Args : sr ~ pop15 + pop75 
#>     left_var : 1 
#>     right_var : 2 
#> 
#> == Linear Regression =========================================================== 
#> 
#> -- Coefficients ----------------------------------------------------------------
#> 
#> ──────────────┬───────────────────────────────────────────
#>   term        │  estimate  std_error  statistic  p_value  
#> ──────────────┼───────────────────────────────────────────
#>   (Intercept) │   30.628     7.409      4.134    <0.001   
#>   pop15       │   -0.471     0.147     -3.207    <0.001   
#>   pop75       │   -1.934     1.041     -1.858     0.069   
#> ──────────────┴───────────────────────────────────────────
#> 
#> 
#> -- Model Fit -------------------------------------------------------------------
#> 
#> Warning: running command 'tput cols' had status 2
#> ------------------------------------------------------
#>   R Squared      :    0.26    F-statistic :     8.33
#>   Adj. R Squared :    0.23    df1         :        2
#>   Sigma          :    3.93    df2         :       47
#>   n              :      50    p-value     :   <0.001
#>   df (residual)  :      47                :         
#> ------------------------------------------------------
#> 
#> 
#> 
#> 4. f4
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : formula 
#> Args : sr ~ pop15 + pop75 + dpi 
#>     left_var : 1 
#>     right_var : 3 
#> 
#> == Linear Regression =========================================================== 
#> 
#> -- Coefficients ----------------------------------------------------------------
#> 
#> ──────────────┬───────────────────────────────────────────
#>   term        │  estimate  std_error  statistic  p_value  
#> ──────────────┼───────────────────────────────────────────
#>   (Intercept) │   31.457     7.482      4.204    <0.001   
#>   pop15       │   -0.492     0.149     -3.302    <0.001   
#>   pop75       │   -1.568     1.121     -1.399     0.169   
#>   dpi         │   -0.001     0.001     -0.894     0.376   
#> ──────────────┴───────────────────────────────────────────
#> 
#> 
#> -- Model Fit -------------------------------------------------------------------
#> 
#> Warning: running command 'tput cols' had status 2
#> -----------------------------------------------------
#>   R Squared      :    0.27    F-statistic :    5.80
#>   Adj. R Squared :    0.23    df1         :       3
#>   Sigma          :    3.94    df2         :      46
#>   n              :      50    p-value     :    0.00
#>   df (residual)  :      46                :        
#> -----------------------------------------------------
#> 
#> 
#> 
#> 5. f5
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : formula 
#> Args : sr ~ pop15 + pop75 + dpi + ddpi 
#>     left_var : 1 
#>     right_var : 4 
#> 
#> == Linear Regression =========================================================== 
#> 
#> -- Coefficients ----------------------------------------------------------------
#> 
#> ──────────────┬───────────────────────────────────────────
#>   term        │  estimate  std_error  statistic  p_value  
#> ──────────────┼───────────────────────────────────────────
#>   (Intercept) │   28.566     7.355      3.884    <0.001   
#>   pop15       │   -0.461     0.145     -3.189    <0.001   
#>   pop75       │   -1.691     1.084     -1.561     0.126   
#>   dpi         │   0.000      0.001     -0.362     0.719   
#>   ddpi        │   0.410      0.196      2.088     0.042   
#> ──────────────┴───────────────────────────────────────────
#> 
#> 
#> -- Model Fit -------------------------------------------------------------------
#> 
#> Warning: running command 'tput cols' had status 2
#> ------------------------------------------------------
#>   R Squared      :    0.34    F-statistic :     5.76
#>   Adj. R Squared :    0.28    df1         :        4
#>   Sigma          :    3.80    df2         :       45
#>   n              :      50    p-value     :   <0.001
#>   df (residual)  :      45                :         
#> ------------------------------------------------------
#> 
#> 
```
