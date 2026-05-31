# Automatically tidy a statistical result

A generic fallback tidier for S7 result objects produced by `{statim}`
pipelines. Called automatically by
[`tidy()`](https://joshuamarie.github.io/statim/reference/tidy.md) when
no method has been registered via
[`making_tidy()`](https://joshuamarie.github.io/statim/reference/making_tidy.md).
Can also be called directly.

## Usage

``` r
auto_tidy(x, ...)
```

## Arguments

- x:

  A statistical result object, such as
  [lm_object](https://joshuamarie.github.io/statim/reference/lm_object.md)
  or
  [glm_object](https://joshuamarie.github.io/statim/reference/glm_object.md).

- ...:

  Currently unused. Passed to the dispatched method.

## Value

A tibble of coefficients or other primary results, depending on the
class of `x`.

## Details

Dispatch is based on the class of `x`, typically the object stored in
`cld_exec@data`. When multiple stat functions share the same result
class (e.g. both `LINEAR_REG` and a variant producing an
[lm_object](https://joshuamarie.github.io/statim/reference/lm_object.md)),
they share the same `auto_tidy()` output without needing separate
registrations.

## See also

[`tidy()`](https://joshuamarie.github.io/statim/reference/tidy.md),
[`making_tidy()`](https://joshuamarie.github.io/statim/reference/making_tidy.md),
[`method_tidy()`](https://joshuamarie.github.io/statim/reference/method_tidy.md)

## Examples

``` r
fit = cars |>
    define_model(dist ~ speed) |>
    prepare_model(LINEAR_REG) |>
    conclude()

# called directly
auto_tidy(fit@data)
#> # A tibble: 2 × 5
#>   term        estimate std_error statistic  p_value
#>   <chr>          <dbl>     <dbl>     <dbl>    <dbl>
#> 1 (Intercept)   -17.6      6.76      -2.60 1.23e- 2
#> 2 speed           3.93     0.416      9.46 1.49e-12

# called implicitly via tidy() when no method is registered
tidy(fit)
#> ℹ No tidy method registered for "linear_reg_formula".
#> ℹ Register one with `making_tidy(<stat_fn>, <model_type>) %<-%
#>   method_tidy(...)` for a custom tidy.
#> ℹ Falling back to `auto_tidy()`.
#> # A tibble: 2 × 5
#>   term        estimate std_error statistic  p_value
#>   <chr>          <dbl>     <dbl>     <dbl>    <dbl>
#> 1 (Intercept)   -17.6      6.76      -2.60 1.23e- 2
#> 2 speed           3.93     0.416      9.46 1.49e-12
```
