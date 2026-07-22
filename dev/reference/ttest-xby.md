# T-Test: Two-Sample (`x_by`)

The `x_by` implementation performs an independent or paired two-sample
t-test. It accepts one or more grouping variables via
[`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md).

## Arguments

The following arguments are passed via `...` in
[`T_TEST()`](https://s7-stats.github.io/statim/dev/reference/T_TEST.md)
or [`via()`](https://s7-stats.github.io/statim/dev/reference/via.md):

- `.paired`:

  Logical. Whether to perform a paired t-test. Default `FALSE`.

- `.mu`:

  Numeric. Hypothesized mean difference. Default `0`.

- `.alt`:

  Direction: `"two.sided"`, `"greater"`, or `"less"`. Default
  `"two.sided"`.

- `.ci`:

  Confidence level. Default `0.95`.

- `.first_group`:

  Only if uses
  [`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md).
  Considers first term as the first order. Default is `NULL`.

## Variants

- `"boot"`:

  Bootstrap CI. Accepts `n` (reps) and `seed`.

- `"permute"`:

  Permutation test. Accepts `n` and `seed`.

- `"contrast"`:

  Welch-Satterthwaite linear contrast test. Accepts `.w`, `.mu`, `.ci`,
  `.op`.

- `"multi"`:

  Accepts multiple selected `group` variables

## Two-sample t-test default class

By default, returns a
[class_ttest_two](https://s7-stats.github.io/statim/dev/reference/class_ttest_two.md)
object. All variants that also return
[class_ttest_two](https://s7-stats.github.io/statim/dev/reference/class_ttest_two.md)
inherit
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md)
and [`print()`](https://rdrr.io/r/base/print.html) automatically.
Otherwise, to process outputs:

- [`print()`](https://rdrr.io/r/base/print.html): Write it down through
  `print` from
  [`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md).

- [`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md):
  Use
  [`making_tidy()`](https://s7-stats.github.io/statim/dev/reference/making_tidy.md)
  to register a tidy method if needed.

## Hypothesis claims

Supports [`MU()`](https://s7-stats.github.io/statim/dev/reference/MU.md)
via
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md).
The `contrast` variant performs Welch-Satterthwaite linear contrast test
and additionally accepts contrast coefficients via `.w`.

Claim order is respected: writing `MU(x, g == "a") - MU(x, g == "b")`
versus `MU(x, g == "b") - MU(x, g == "a")` flips the sign of `estimate`
and `t_stat`, since the group with coefficient `+1` in the parsed claim
becomes `x` in [`stats::t.test()`](https://rdrr.io/r/stats/t.test.html).
This is implemented via an internal `.first_group` argument resolved
from the claim — it is not meant to be set directly by users. If you
call `via("base", .first_group = ...)` or use
[`update()`](https://rdrr.io/r/stats/update.html) to override it
manually, note that it accepts a single group label (one of the two
levels of the grouping variable) and silently falls back to the data's
natural level order ([`unique()`](https://rdrr.io/r/base/unique.html) on
the grouping variable) if `NULL`, unset, or not found among the levels.

## References

Welch, B. L. (1947). The generalization of "Student's" problem when
several different population variances are involved. *Biometrika*,
34(1-2), 28-35.
[doi:10.1093/biomet/34.1-2.28](https://doi.org/10.1093/biomet/34.1-2.28)

Satterthwaite, F. E. (1946). An approximate distribution of estimates of
variance components. *Biometrics Bulletin*, 2(6), 110-114.
[doi:10.2307/3002019](https://doi.org/10.2307/3002019)

Kutner, M. H., Nachtsheim, C. J., Neter, J., & Li, W. (2004). *Applied
Linear Statistical Models* (5th ed.). McGraw-Hill/Irwin.

## See also

Other ttest-implementations:
[`ttest-formula`](https://s7-stats.github.io/statim/dev/reference/ttest-formula.md),
[`ttest-on`](https://s7-stats.github.io/statim/dev/reference/ttest-on.md),
[`ttest-pairwise`](https://s7-stats.github.io/statim/dev/reference/ttest-pairwise.md)

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

sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(T_TEST) |>
    via("boot", n = 2000) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : x_by 
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

# contrast t-test, which allows `state_null()` to have weights
# Around population parameter function `MU()` notation
# Also `%by%` is just the infixed form of `x_by()`
sleep |>
    define_model(extra %by% group) |>
    prepare_test(T_TEST) |>
    state_null(
        2 * MU(extra, group == "1") - MU(extra, group == "2") <= 0
    ) |>
    via("contrast") |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : x_by 
#> Args : extra | group 
#>     x_vars : 1 
#>     by_vars : 1 
#> 
#> == T-Test · contrast =========================================================== 
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
