# Prepare a lazy inference pipeline

`prepare()` attaches a spec function produced from
[`STAT_CONSTRUCTOR()`](https://s7-stats.github.io/statim/dev/reference/STAT_CONSTRUCTOR.md)
to a `<def_var>` object and dispatches to
[`prepare_test()`](https://s7-stats.github.io/statim/dev/reference/prepare-test.md)
or
[`prepare_model()`](https://s7-stats.github.io/statim/dev/reference/prepare-model.md)
depending on whether `.fn` returns a `<test_spec>` or a `<model_spec>`.
The result is a lazy pipeline object ready for optional recalibration
with [`via()`](https://s7-stats.github.io/statim/dev/reference/via.md)
before execution with
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md).

## Usage

``` r
prepare(.x, .fn, ...)
```

## Arguments

- .x:

  A `<def_var>` object from
  [`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md),
  or an `<expanded_model>` object from
  [`write_models()`](https://s7-stats.github.io/statim/dev/reference/write_models.md).

- .fn:

  A stat function built with
  [`STAT_CONSTRUCTOR()`](https://s7-stats.github.io/statim/dev/reference/STAT_CONSTRUCTOR.md)
  that returns a `<test_spec>` (e.g.
  [T_TEST](https://s7-stats.github.io/statim/dev/reference/T_TEST.md))
  or a `<model_spec>` (e.g.
  [LINEAR_REG](https://s7-stats.github.io/statim/dev/reference/LINEAR_REG.md)).

- ...:

  Additional arguments passed to the dispatched `prepare_*()` function.

## Value

A `<test_lazy>` object if `.fn` returns a `<test_spec>`, or a
`<model_lazy>` object if `.fn` returns a `<model_spec>`.

## See also

[`prepare_test()`](https://s7-stats.github.io/statim/dev/reference/prepare-test.md),
[`prepare_model()`](https://s7-stats.github.io/statim/dev/reference/prepare-model.md),
[`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md),
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md),
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)

## Examples

``` r
sleep |>
    define_model(x_by(extra, group)) |>
    prepare(T_TEST) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : x_by 
#> Args : extra | group 
#>     x_vars : 1 
#>     by_vars : 1 
#> 
#> == T-Test ====================================================================== 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ──────────────────────────────────────────
#>   group  estimate  t_stat    df    p_val  
#> ──────────────────────────────────────────
#>   group   -1.580   -1.861  17.780  0.079  
#> ──────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ─────────────────────────────
#>   group  lower_95  upper_95  
#> ─────────────────────────────
#>   group   -3.365    0.206    
#> ─────────────────────────────
#> 
#> 

mtcars |>
    define_model(mpg ~ .) |>
    prepare(LINEAR_REG) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : formula 
#> Args : mpg ~ . 
#>     left_var : 1 
#>     right_var : 10 
#> 
#> == Linear Regression =========================================================== 
#> 
#> -- Coefficients ----------------------------------------------------------------
#> 
#> ──────────────┬───────────────────────────────────────────
#>   term        │  estimate  std_error  statistic  p_value  
#> ──────────────┼───────────────────────────────────────────
#>   (Intercept) │   12.303    18.718      0.657     0.518   
#>   cyl         │   -0.111     1.045     -0.107     0.916   
#>   disp        │   0.013      0.018      0.747     0.463   
#>   hp          │   -0.021     0.022     -0.987     0.335   
#>   drat        │   0.787      1.635      0.481     0.635   
#>   wt          │   -3.715     1.894     -1.961     0.063   
#>   qsec        │   0.821      0.731      1.123     0.274   
#>   vs          │   0.318      2.105      0.151     0.881   
#>   am          │   2.520      2.057      1.225     0.234   
#>   gear        │   0.655      1.493      0.439     0.665   
#>   carb        │   -0.199     0.829     -0.241     0.812   
#> ──────────────┴───────────────────────────────────────────
#> 
#> 
#> -- Model Fit -------------------------------------------------------------------
#> 
#> Warning: running command 'tput cols' had status 2
#> ------------------------------------------------------
#>   R Squared      :    0.87    F-statistic :    13.93
#>   Adj. R Squared :    0.81    df1         :       10
#>   Sigma          :    2.65    df2         :       21
#>   n              :      32    p-value     :   <0.001
#>   df (residual)  :      21                :         
#> ------------------------------------------------------
#> 
#> 
```
