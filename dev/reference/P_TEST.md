# Proportion Test

`P_TEST()` performs a one-sample proportion test using either an exact
binomial test or a normal approximation. If `P_TEST` is supplied within
the lazy-loaded pipeline, supply `P_TEST` as a function within i.e.
`prepare_test(.test = P_TEST)` call.

## Usage

``` r
P_TEST(.var_id = NULL, .data = NULL, ...)
```

## Arguments

- .var_id:

  A registered variable mapper `<var_id>`, e.g.
  [`prop()`](https://s7-stats.github.io/statim/dev/reference/prop.md).
  When supplied, the test executes immediately.

- .data:

  Unused. Accepted for pipeline consistency.

- ...:

  Additional arguments passed to the implementation. See the
  **Arguments** and **Variants** sections below.

## Value

A `cld_exec` object, or a `test_spec` when `.var_id = NULL`. The object
stored in `cld_exec@data` is a
[class_p_test](https://s7-stats.github.io/statim/dev/reference/class_p_test.md)
object.

## Arguments

The following arguments are passed via `...` in `P_TEST()` or
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md):

- `.p`:

  Numeric. Hypothesized proportion under H\\\_0\\, used directly in
  [`stats::binom.test()`](https://rdrr.io/r/stats/binom.test.html) /
  [`stats::prop.test()`](https://rdrr.io/r/stats/prop.test.html).
  Default `0.5`. When a hypothesis is stated via
  [`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md)
  with a scaled claim like `c * PI() == k`, `.p` is resolved to the
  solved value `k / c`, since `c * PI() == k` and `PI() == k / c` are
  the same hypothesis (the binomial likelihood is invariant under this
  linear reparameterization).

- `.alt`:

  Direction: `"two.sided"`, `"greater"`, or `"less"`. Default
  `"two.sided"`.

- `.ci`:

  Confidence level. Default `0.95`.

- `.true_p`:

  Only meaningful via
  [`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md).
  Carries the hypothesis's scalar value *as written* (unsolved), purely
  for display in `true_p`. Default `NULL`, in which case `true_p` falls
  back to `.p`. Not intended to be set directly by users.

## Variants

- `"prop"`:

  Normal approximation via
  [`stats::prop.test()`](https://rdrr.io/r/stats/prop.test.html) without
  continuity correction. Accepts the same `.p`, `.alt`, `.ci` arguments
  as the default, except with `correct` addition to indicate whether
  Yates' continuity correction should be applied or not.

## Hypothesis claims

Supports [`PI()`](https://s7-stats.github.io/statim/dev/reference/PI.md)
via
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md):

    define_model(prop(45, 100)) |>
        prepare_test(P_TEST) |>
        state_null(PI() == 0.5) |>
        conclude()

Scaled claims are also supported, e.g. `2 * PI() == 0.3`. The test
itself solves for
[`PI()`](https://s7-stats.github.io/statim/dev/reference/PI.md)
(`.p = 0.15`) and runs exactly via
[`stats::binom.test()`](https://rdrr.io/r/stats/binom.test.html) or
[`stats::prop.test()`](https://rdrr.io/r/stats/prop.test.html) — no
approximation is introduced by the scaling, since testing
`c * PI() == k` is mathematically identical to testing `PI() == k / c`.
`true_p` in the printed/tidied output instead shows the scalar as
written on the right-hand side of the claim (`0.3`, not the solved
`0.15`), so the displayed hypothesis matches what was typed even though
the underlying test operates on the solved proportion.

## See also

[`prop()`](https://s7-stats.github.io/statim/dev/reference/prop.md),
[class_p_test](https://s7-stats.github.io/statim/dev/reference/class_p_test.md),
[`PI()`](https://s7-stats.github.io/statim/dev/reference/PI.md),
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md),
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md),
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)

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
#> Variable Mapper : prop 
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
#> Variable Mapper : prop 
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
#> Variable Mapper : prop 
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

# scaled hypothesis claim
define_model(prop(45, 100)) |>
    prepare_test(P_TEST) |>
    state_null(2 * PI() == 0.3) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : prop 
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
