# Lazily prepare a single test

`prepare_test()` attaches a test specification to a `<def_var>` object,
producing a `test_lazy` ready for optional recalibration with
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md) before
being executed with
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md).

## Usage

``` r
prepare_test(.x, .test, ...)
```

## Arguments

- .x:

  An S7 object extension yielded by, e.g. `<def_var>` object from
  [`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md),
  or an `<expanded_model>` object from
  [`write_models()`](https://s7-stats.github.io/statim/dev/reference/write_models.md).

- .test:

  A test function such as
  [T_TEST](https://s7-stats.github.io/statim/dev/reference/T_TEST.md)
  that carries `<test_spec>` objects when called.

- ...:

  Additional arguments passed to methods.

## Value

A `<test_lazy>` S7 object.

## See also

[`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md),
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md),
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)

## Examples

``` r
sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(T_TEST) |>
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
```
