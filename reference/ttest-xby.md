# T-Test: Two-Sample (`x_by`)

The `x_by` implementation performs an independent or paired two-sample
t-test. It accepts one or more grouping variables via
[`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md).

## Arguments

The following arguments are passed via `...` in
[`TTEST()`](https://s7-stats.github.io/statim/reference/TTEST.md) or
[`via()`](https://s7-stats.github.io/statim/reference/via.md):

- `.paired`:

  Logical. Whether to perform a paired t-test. Default `FALSE`.

- `.mu`:

  Numeric. Hypothesized mean difference. Default `0`.

- `.alt`:

  Direction: `"two.sided"`, `"greater"`, or `"less"`. Default
  `"two.sided"`.

- `.ci`:

  Confidence level. Default `0.95`.

## Variants

- `"boot"`:

  Bootstrap CI. Accepts `n` (reps) and `seed`.

- `"permute"`:

  Permutation test. Accepts `n` and `seed`.

- `"weighted"`:

  Weighted contrast. Accepts `.w`, `.mu`, `.ci`, `.op`.

## Result class

Returns a
[class_ttest_two](https://s7-stats.github.io/statim/reference/class_ttest_two.md)
object. All variants that also return
[class_ttest_two](https://s7-stats.github.io/statim/reference/class_ttest_two.md)
inherit
[`auto_tidy()`](https://s7-stats.github.io/statim/reference/auto_tidy.md)
and [`print()`](https://rdrr.io/r/base/print.html) automatically.

## Hypothesis claims

Supports [`MU()`](https://s7-stats.github.io/statim/reference/MU.md) via
[`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md).
The `weighted` variant additionally accepts contrast coefficients via
`.w`.

## See also

Other ttest-implementations:
[`ttest-formula`](https://s7-stats.github.io/statim/reference/ttest-formula.md),
[`ttest-pairwise`](https://s7-stats.github.io/statim/reference/ttest-pairwise.md)

## Examples

``` r
sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(TTEST) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : x_by 
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

sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(TTEST) |>
    via("boot", n = 2000) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : x_by 
#> Args : extra | group 
#>     x_vars : 1 
#>     by_vars : 1 
#> 
#> == T-Test · boot =============================================================== 
#> 
#> ============================== Bootstrapped T-test =============================
#> 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> Warning: running command 'tput cols' had status 2
#> -------------------------------
#>   CI     :   [-3.11, -0.0798]
#>   n_reps :               2000
#> -------------------------------
#> 
#> 

# Weighted t-test, which allows `state_null()` to have weights
# Around population parameter function `MU()` notation
# Also `%by%` is just the infixed form of `x_by()`
sleep |>
    define_model(extra %by% group) |>
    prepare_test(TTEST) |>
    state_null(
        2 * MU(extra, group == "1") - MU(extra, group == "2") <= 0
    ) |>
    via("weighted") |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : x_by 
#> Args : extra | group 
#>     x_vars : 1 
#>     by_vars : 1 
#> 
#> == T-Test · weighted =========================================================== 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ──────────────────────────────────────────
#>   group  estimate  t_stat    df    p_val  
#> ──────────────────────────────────────────
#>   group   -0.830   -0.640  14.130  0.734  
#> ──────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ─────────────────────────────
#>   group  lower_95  upper_95  
#> ─────────────────────────────
#>   group   -3.112     Inf     
#> ─────────────────────────────
#> 
#> 
```
