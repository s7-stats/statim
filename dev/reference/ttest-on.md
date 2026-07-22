# T-Test: One-Sample and Two-Sample (`on`)

The `on` implementation performs a one-sample t-test for one or more
variables via
[`on()`](https://s7-stats.github.io/statim/dev/reference/on.md), or a
two-sample t-test (independent or paired) when exactly two variables are
supplied and `via("two_sample")` is used. The one-sample default tests
each variable independently against a hypothesized mean. The
`two_sample` variant instead compares the two variables to each other,
without requiring the value/group layout
[`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md)
expects.

## Arguments

The following arguments are passed via `...` in
[`T_TEST()`](https://s7-stats.github.io/statim/dev/reference/T_TEST.md)
or [`via()`](https://s7-stats.github.io/statim/dev/reference/via.md):

- `.mu`:

  Numeric. Hypothesized mean (one-sample) or mean difference/contrast
  (`two_sample`). Default `0`.

- `.alt`:

  Direction: `"two.sided"`, `"greater"`, or `"less"`. Default
  `"two.sided"`.

- `.ci`:

  Confidence level. Default `0.95`.

- `.true_mu`:

  One-sample only. Only meaningful via
  [`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md).
  Carries the scalar as written in the claim, purely for display in
  `true_mu`. Default `NULL`, falling back to `.mu`. Not intended to be
  set directly.

## Variants

- `"multi"`:

  Performs independent one-sample t-tests across selected variables
  supplied via
  [`on()`](https://s7-stats.github.io/statim/dev/reference/on.md).
  Accepts the same `.mu`, `.alt`, `.ci` arguments as the default.
  However, `.mu` is recycled across all variables or must match their
  count.

- `"two_sample"`:

  Compares exactly two variables supplied via
  [`on()`](https://s7-stats.github.io/statim/dev/reference/on.md).
  Accepts `.paired` (logical, default `FALSE`), `.var_equal` (logical,
  default `FALSE`, ignored when `.paired = TRUE`), and `.w` (a named
  numeric vector of contrast weights, one per variable, default `NULL`
  falling back to `c(1, -1)` in the order the variables were supplied).

## One-sample t-test default class

Applied on the default `ttest-on` and its variant `"multi"`. By default,
returns a
[class_ttest_one](https://s7-stats.github.io/statim/dev/reference/class_ttest_one.md)
object. All variants that also return
[class_ttest_one](https://s7-stats.github.io/statim/dev/reference/class_ttest_one.md)
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

## Two-sample t-test class

Only applied on `via("two_sample")`. By default, it returns a
[class_ttest_two](https://s7-stats.github.io/statim/dev/reference/class_ttest_two.md)
object — the same class produced by
[ttest-xby](https://s7-stats.github.io/statim/dev/reference/ttest-xby.md)'s
implementation. `group` holds a synthesized label (e.g.
`"1*x1 + -1*x2"`) rather than a grouping variable name, since
[`on()`](https://s7-stats.github.io/statim/dev/reference/on.md) has no
grouping column to name.

## Hypothesis claims

Supports [`MU()`](https://s7-stats.github.io/statim/dev/reference/MU.md)
via
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md):

    define_model(on(x), <data>) |>
        prepare_test(T_TEST) |>
        state_null(MU(x) >= 1) |>
        conclude()

Scaled claims are supported: `2 * MU(x) == 4` tests `MU(x) == 2`.
`true_mu` in the output shows the right-hand scalar as written (`4`),
while the test runs on the solved value (`2`).

For `two_sample`, both variables from
[`on()`](https://s7-stats.github.io/statim/dev/reference/on.md) must
appear in the claim, and referenced by the same names given to (or
auto-generated for) each variable:

    define_model(on(x1, x2), <data>) |>
        prepare_test(T_TEST) |>
        via("two_sample") |>
        state_null(MU(x1) - MU(x2) == 0) |>
        conclude()

Arbitrary linear contrasts are supported, including scaled terms and
constants on either side:

    state_null(2 * MU(oj) + 1 == MU(vc) - 3)

`estimate` always reflects the sample contrast
(`a * mean(x1) + b * mean(x2)`) and does not change when only the
hypothesized scalar changes, only `t_stat`, `p_val`, and where the CI
sits relative to the hypothesis shift with it. This matches
[`stats::t.test()`](https://rdrr.io/r/stats/t.test.html)'s own
convention of reporting the same `estimate` regardless of `mu`.

A variable omitted from a `two_sample` claim, or a zero coefficient on
either variable, is an error rather than a silent one-sample reduction —
use `on(<single variable>)` with the default variant instead.

## See also

[ttest-xby](https://s7-stats.github.io/statim/dev/reference/ttest-xby.md)
for the value/group layout,
[class_ttest_two](https://s7-stats.github.io/statim/dev/reference/class_ttest_two.md),
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md)

Other ttest-implementations:
[`ttest-formula`](https://s7-stats.github.io/statim/dev/reference/ttest-formula.md),
[`ttest-pairwise`](https://s7-stats.github.io/statim/dev/reference/ttest-pairwise.md),
[`ttest-xby`](https://s7-stats.github.io/statim/dev/reference/ttest-xby.md)

## Examples

``` r
# single variable
sleep |>
    define_model(on(extra)) |>
    prepare_test(T_TEST) |>
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
    prepare_test(T_TEST) |>
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
    prepare_test(T_TEST) |>
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

# two-sample, wide-format columns, unpaired (Welch by default)
vc = ToothGrowth$len[ToothGrowth$supp == "VC"]
oj = ToothGrowth$len[ToothGrowth$supp == "OJ"]

define_model(on(vc, oj)) |>
    prepare_test(T_TEST) |>
    via("two_sample") |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : on 
#> Args : vc, oj 
#> 
#> == T-Test · two_sample ========================================================= 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ─────────────────────────────────────────────────
#>      group      estimate  t_stat    df    p_val  
#> ─────────────────────────────────────────────────
#>   1*vc + -1*oj   -3.700   -1.915  55.310  0.061  
#> ─────────────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ────────────────────────────────────
#>      group      lower_95  upper_95  
#> ────────────────────────────────────
#>   1*vc + -1*oj   -7.571    0.171    
#> ────────────────────────────────────
#> 
#> 

# two-sample, paired
# You can use the `I()` and `with()` call
# To refer the columns as a local environment
# Containing the data
ToothGrowth |>
    with(define_model(on(
        I(d1 = len[supp == "OJ" & dose == 1]),
        I(d2 = len[supp == "VC" & dose == 1])
    ))) |>
    prepare_test(T_TEST) |>
    via("two_sample", .paired = TRUE) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : on 
#> Args : <inline>, <inline> 
#> 
#> == T-Test · two_sample ========================================================= 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ──────────────────────────────────────────────
#>      group      estimate  t_stat  df  p_val   
#> ──────────────────────────────────────────────
#>   1*d1 + -1*d2   5.930    3.372   9   <0.001  
#> ──────────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ────────────────────────────────────
#>      group      lower_95  upper_95  
#> ────────────────────────────────────
#>   1*d1 + -1*d2   1.952     9.908    
#> ────────────────────────────────────
#> 
#> 

# two-sample with a weighted contrast hypothesis
ToothGrowth |>
    with(define_model(on(I(oj = len[supp == "OJ"]), I(vc = len[supp == "VC"])))) |>
    prepare_test(T_TEST) |>
    via("two_sample") |>
    state_null(2 * MU(oj) - MU(vc) == 5) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : on 
#> Args : <inline>, <inline> 
#> 
#> == T-Test · two_sample ========================================================= 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ──────────────────────────────────────────────────
#>      group      estimate  t_stat    df    p_val   
#> ──────────────────────────────────────────────────
#>   2*oj + -1*vc   24.363   6.806   48.690  <0.001  
#> ──────────────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ────────────────────────────────────
#>      group      lower_95  upper_95  
#> ────────────────────────────────────
#>   2*oj + -1*vc   18.645    30.082   
#> ────────────────────────────────────
#> 
#> 
```
