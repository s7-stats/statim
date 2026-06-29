# T-Test: One-Sample (`on`)

The `on` implementation performs a one-sample t-test for one or more
variables via
[`on()`](https://s7-stats.github.io/statim/reference/on.md). Each
variable is tested independently against a hypothesized mean.

## Arguments

The following arguments are passed via `...` in
[`TTEST()`](https://s7-stats.github.io/statim/reference/TTEST.md) or
[`via()`](https://s7-stats.github.io/statim/reference/via.md):

- `.mu`:

  Numeric. Hypothesized mean under H\\\_0\\. Default `0`.

- `.alt`:

  Direction: `"two.sided"`, `"greater"`, or `"less"`. Default
  `"two.sided"`.

- `.ci`:

  Confidence level. Default `0.95`.

- `.true_mu`:

  Only meaningful via
  [`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md).
  Carries the scalar as written in the claim, purely for display in
  `true_mu`. Default `NULL`, falling back to `.mu`. Not intended to be
  set directly.

## Variants

- `"multi"`:

  Tests multiple variables supplied via
  [`on()`](https://s7-stats.github.io/statim/reference/on.md). Accepts
  the same `.mu`, `.alt`, `.ci` arguments as the default. `.mu` is
  recycled across all variables or must match their count.

## One-sample t-test default class

By default, returns a
[class_ttest_one](https://s7-stats.github.io/statim/reference/class_ttest_one.md)
object. All variants that also return
[class_ttest_one](https://s7-stats.github.io/statim/reference/class_ttest_one.md)
inherit
[`auto_tidy()`](https://s7-stats.github.io/statim/reference/auto_tidy.md)
and [`print()`](https://rdrr.io/r/base/print.html) automatically.
Otherwise, to process outputs:

- [`print()`](https://rdrr.io/r/base/print.html): Write it down through
  `print` from
  [`variant()`](https://s7-stats.github.io/statim/reference/variant.md).

- [`tidy()`](https://s7-stats.github.io/statim/reference/tidy.md): Use
  [`making_tidy()`](https://s7-stats.github.io/statim/reference/making_tidy.md)
  to register a tidy method if needed.

## Hypothesis claims

Supports [`MU()`](https://s7-stats.github.io/statim/reference/MU.md) via
[`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md):

    define_model(on(x), <data>) |>
        prepare_test(TTEST) |>
        state_null(MU(x) >= 1) |>
        conclude()

Scaled claims are supported: `2 * MU(extra) == 4` tests
`MU(extra) == 2`. `true_mu` in the output shows the right-hand scalar as
written (`4`), while the test runs on the solved value (`2`).

## See also

Other ttest-implementations:
[`ttest-formula`](https://s7-stats.github.io/statim/reference/ttest-formula.md),
[`ttest-pairwise`](https://s7-stats.github.io/statim/reference/ttest-pairwise.md),
[`ttest-xby`](https://s7-stats.github.io/statim/reference/ttest-xby.md)

## Examples

``` r
# single variable
sleep |>
    define_model(on(extra)) |>
    prepare_test(TTEST) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : on 
#> Args : extra 
#> 
#> == T-Test ====================================================================== 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ────────────────────────────────────────────
#>   term   estimate  true_mu  t_stat  p_val   
#> ────────────────────────────────────────────
#>   extra   1.540       0     3.413   <0.001  
#> ────────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ─────────────────────────────
#>   term   lower_95  upper_95  
#> ─────────────────────────────
#>   extra   0.596     2.484    
#> ─────────────────────────────
#> 
#> 

# null hypothesis expression
sleep |>
    define_model(on(extra)) |>
    prepare_test(TTEST) |>
    state_null(MU(extra) >= 1) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : on 
#> Args : extra 
#> 
#> == T-Test ====================================================================== 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ───────────────────────────────────────────
#>   term   estimate  true_mu  t_stat  p_val  
#> ───────────────────────────────────────────
#>   extra   1.540       1     1.197   0.877  
#> ───────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ─────────────────────────────
#>   term   lower_95  upper_95  
#> ─────────────────────────────
#>   extra    -Inf     2.320    
#> ─────────────────────────────
#> 
#> 

# multiple variables
iris |>
    define_model(on(where(is.numeric))) |>
    prepare_test(TTEST) |>
    via("multi") |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : on 
#> Args : where(is.numeric) 
#> 
#> == T-Test · multi ============================================================== 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ───────────────────────────────────────────────────
#>       term      estimate  true_mu  t_stat  p_val   
#> ───────────────────────────────────────────────────
#>   Sepal.Length   5.843       0     86.425  <0.001  
#>   Sepal.Width    3.057       0     85.908  <0.001  
#>   Petal.Length   3.758       0     26.073  <0.001  
#>   Petal.Width    1.199       0     19.271  <0.001  
#> ───────────────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ────────────────────────────────────
#>       term      lower_95  upper_95  
#> ────────────────────────────────────
#>   Sepal.Length   5.710     5.977    
#>   Sepal.Width    2.987     3.128    
#>   Petal.Length   3.473     4.043    
#>   Petal.Width    1.076     1.322    
#> ────────────────────────────────────
#> 
#> 
```
