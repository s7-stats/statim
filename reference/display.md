# Display individual results

`display()` prints the first `n` concluded models from an abstract S7
class, e.g. `multi_exec`, in full. Useful when
[`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md)
has been called on a
[`write_models()`](https://s7-stats.github.io/statim/reference/write_models.md)
pipeline and the default compressed print is not enough.

## Usage

``` r
display(x, n = 3L, ...)
```

## Arguments

- x:

  An object yield by
  [`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md).

- n:

  A positive integer. The number of models' output to display. Defaults
  to `3`.

- ...:

  Currently unused.

## Value

`x`, invisibly.

## See also

[`write_models()`](https://s7-stats.github.io/statim/reference/write_models.md),
[`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md),
[`tidy()`](https://s7-stats.github.io/statim/reference/tidy.md)

## Examples

``` r
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
    display(2)
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
```
