# Proportion Test

`P_TEST()` performs a one-sample proportion test using either an exact
binomial test or a normal approximation. If `P_TEST` is supplied within
the lazy-loaded pipeline, supply `P_TEST` as a function within i.e.
`prepare_test(.test = P_TEST)` call.

## Usage

``` r
P_TEST(.model = NULL, .data = NULL, ...)
```

## Arguments

- .model:

  A registered model ID, e.g.
  [`prop()`](https://s7-stats.github.io/statim/reference/prop.md). When
  supplied, the test executes immediately.

- .data:

  Unused. Accepted for pipeline consistency.

- ...:

  Additional arguments passed to the implementation. See the
  **Arguments** and **Variants** sections below.

## Value

A `cld_exec` object, or a `test_spec` when `.model = NULL`. The object
stored in `cld_exec@data` is a
[class_p_test](https://s7-stats.github.io/statim/reference/class_p_test.md)
object.

## Arguments

The following arguments are passed via `...` in `P_TEST()` or
[`via()`](https://s7-stats.github.io/statim/reference/via.md):

- `.p`:

  Numeric. Hypothesized proportion under H\\\_0\\. Default `0.5`.

- `.alt`:

  Direction: `"two.sided"`, `"greater"`, or `"less"`. Default
  `"two.sided"`.

- `.ci`:

  Confidence level. Default `0.95`.

## Variants

- `"prop"`:

  Normal approximation via
  [`stats::prop.test()`](https://rdrr.io/r/stats/prop.test.html) without
  continuity correction. Accepts the same `.p`, `.alt`, `.ci` arguments
  as the default, except with `correct` addition to indicate whether
  Yates' continuity correction should be applied or not.

## Hypothesis claims

Supports [`PI()`](https://s7-stats.github.io/statim/reference/PI.md) via
[`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md):

    define_model(prop(45, 100)) |>
        prepare_test(P_TEST) |>
        state_null(PI() == 0.5) |>
        conclude()

## See also

[`prop()`](https://s7-stats.github.io/statim/reference/prop.md),
[class_p_test](https://s7-stats.github.io/statim/reference/class_p_test.md),
[`PI()`](https://s7-stats.github.io/statim/reference/PI.md),
[`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md),
[`via()`](https://s7-stats.github.io/statim/reference/via.md),
[`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md)

## Examples

``` r
P_TEST(prop(45, 100))
#> -- Summary ---------------------------------------------------------------------
#> 
#> ───────────────────────────────────────────────
#>   x    n   true_p  estimate  statistic  p_val  
#> ───────────────────────────────────────────────
#>   45  100  0.500    0.450       45      0.368  
#> ───────────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ──────────────────────
#>   lower_95  upper_95  
#> ──────────────────────
#>    0.350     0.553    
#> ──────────────────────
#> 
#> 

# piped syntax
define_model(prop(45, 100)) |>
    prepare_test(P_TEST) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : prop 
#> Args : 45 / 100 
#>     x : 45 
#>     n : 100 
#> 
#> == Proportion Test ============================================================= 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ───────────────────────────────────────────────
#>   x    n   true_p  estimate  statistic  p_val  
#> ───────────────────────────────────────────────
#>   45  100  0.500    0.450       45      0.368  
#> ───────────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ──────────────────────
#>   lower_95  upper_95  
#> ──────────────────────
#>    0.350     0.553    
#> ──────────────────────
#> 
#> 

# normal approximation
define_model(prop(45, 100)) |>
    prepare_test(P_TEST) |>
    via("prop") |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : prop 
#> Args : 45 / 100 
#>     x : 45 
#>     n : 100 
#> 
#> == Proportion Test · prop ====================================================== 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ───────────────────────────────────────────────
#>   x    n   true_p  estimate  statistic  p_val  
#> ───────────────────────────────────────────────
#>   45  100  0.500    0.450      0.810    0.368  
#> ───────────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ──────────────────────
#>   lower_95  upper_95  
#> ──────────────────────
#>    0.351     0.552    
#> ──────────────────────
#> 
#> 

# hypothesis claim
define_model(prop(45, 100)) |>
    prepare_test(P_TEST) |>
    state_null(PI() == 0.3) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : prop 
#> Args : 45 / 100 
#>     x : 45 
#>     n : 100 
#> 
#> == Proportion Test ============================================================= 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ────────────────────────────────────────────────
#>   x    n   true_p  estimate  statistic  p_val   
#> ────────────────────────────────────────────────
#>   45  100  0.300    0.450       45      <0.001  
#> ────────────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ──────────────────────
#>   lower_95  upper_95  
#> ──────────────────────
#>    0.350     0.553    
#> ──────────────────────
#> 
#> 
```
