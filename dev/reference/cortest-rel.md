# Correlation Test: `rel` interface

The `rel` implementation performs a correlation test between exactly one
independent variable and one response variable.

Use [`rel()`](https://s7-stats.github.io/statim/dev/reference/rel.md) as
the variable mapper `<var_id>` to select this implementation.

## Arguments

The following arguments are passed via `...` in
[`COR_TEST()`](https://s7-stats.github.io/statim/dev/reference/COR_TEST.md):

- `.alt`:

  String. One of `"two.sided"`, `"greater"`, or `"less"`. Default
  `"two.sided"`.

- `.ci`:

  Numeric. Confidence level. Default `0.95`. Not applicable to Spearman
  and Kendall variants.

- `.rho`:

  Numeric. Hypothesized population correlation coefficient under
  H\\\_0\\. Default `0`. Only applicable to the `base` (Pearson)
  variant. When `0`, delegates to
  [`stats::cor.test()`](https://rdrr.io/r/stats/cor.test.html). When
  non-zero, uses a Fisher-z test against the specified null value.

## Variants

- `"spearman"`:

  Spearman's \\\rho\\. Uses
  [`stats::cor.test()`](https://rdrr.io/r/stats/cor.test.html) with
  `method = "spearman"`. No confidence interval is returned. Does not
  support
  [`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md).

- `"kendall"`:

  Kendall's \\\tau\\. Uses
  [`stats::cor.test()`](https://rdrr.io/r/stats/cor.test.html) with
  `method = "kendall"`. No confidence interval is returned. Does not
  support
  [`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md).

## Correlation test default class

By default, it returns a
[class_corr_two](https://s7-stats.github.io/statim/dev/reference/class_corr_two.md)
object inheriting from
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md).
All variants that also return
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

For the `base` variant, `df`, `lower_ci`, and `upper_ci` are always
populated. For `spearman` and `kendall`, those slots are `numeric(0)`
and are omitted from the printed output.

## Hypothesis claims

Supports
[`RHO()`](https://s7-stats.github.io/statim/dev/reference/RHO.md) via
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md).
Only available on the `base` (Pearson) variant. The claim is parsed as
follows:

- The operator maps to `.alt`: `==` and `!=` become `"two.sided"`, `>=`
  and `>` become `"less"`, `<=` and `<` become `"greater"`.

- The scalar maps to `.rho`: `RHO(x, y) == 0.9`, not `0.9 == RHO(x, y)`,
  is handled correctly via
  [`claim_scalar()`](https://s7-stats.github.io/statim/dev/reference/claim_scalar.md).

## References

Fisher, R. A. (1915). Frequency distribution of the values of the
correlation coefficient in samples from an indefinitely large
population. *Biometrika*, **10**(4), 507–521.
[doi:10.2307/2331838](https://doi.org/10.2307/2331838)

Fisher, R. A. (1921). On the "probable error" of a coefficient of
correlation deduced from a small sample. *Metron*, **1**, 3–32.

Zar, J. H. (2010). *Biostatistical Analysis* (5th ed.). Pearson. Section
19.3.

## See also

Other cortest-implementations:
[`cortest-formula`](https://s7-stats.github.io/statim/dev/reference/cortest-formula.md)

## Examples

``` r
# base (Pearson)
cars |>
    define_model(rel(speed, dist)) |>
    prepare_test(COR_TEST) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : rel 
#> Args : speed ; dist 
#>     x_vars : 1 
#>     resp_vars : 1 
#> 
#> == Correlation Test ============================================================ 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ─────────────────────────────────────────────────
#>       pair      estimate  statistic  df  p_val   
#> ─────────────────────────────────────────────────
#>   dist ~ speed   0.807      9.464    48  <0.001  
#> ─────────────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ────────────────────────────────────
#>       pair      lower_95  upper_95  
#> ────────────────────────────────────
#>   dist ~ speed   0.682     0.886    
#> ────────────────────────────────────
#> 
#> 

# Spearman
suppressWarnings({
    cars |>
        define_model(rel(speed, dist)) |>
        prepare_test(COR_TEST) |>
        via("spearman") |>
        conclude()
})
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : rel 
#> Args : speed ; dist 
#>     x_vars : 1 
#>     resp_vars : 1 
#> 
#> == Correlation Test · spearman ================================================= 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ─────────────────────────────────────────────
#>       pair      estimate  statistic  p_val   
#> ─────────────────────────────────────────────
#>   dist ~ speed   0.830    3532.819   <0.001  
#> ─────────────────────────────────────────────
#> 
#> 

# Kendall
suppressWarnings({
    cars |>
        define_model(rel(speed, dist)) |>
        prepare_test(COR_TEST) |>
        via("kendall") |>
        conclude()
})
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : rel 
#> Args : speed ; dist 
#>     x_vars : 1 
#>     resp_vars : 1 
#> 
#> == Correlation Test · kendall ================================================== 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ─────────────────────────────────────────────
#>       pair      estimate  statistic  p_val   
#> ─────────────────────────────────────────────
#>   dist ~ speed   0.669      6.665    <0.001  
#> ─────────────────────────────────────────────
#> 
#> 

# hypothesis claim: two-sided against zero
cars |>
    define_model(rel(speed, dist)) |>
    prepare_test(COR_TEST) |>
    state_null(RHO(speed, dist) == 0) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : rel 
#> Args : speed ; dist 
#>     x_vars : 1 
#>     resp_vars : 1 
#> 
#> == Correlation Test ============================================================ 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ─────────────────────────────────────────────────
#>       pair      estimate  statistic  df  p_val   
#> ─────────────────────────────────────────────────
#>   dist ~ speed   0.807      9.464    48  <0.001  
#> ─────────────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ────────────────────────────────────
#>       pair      lower_95  upper_95  
#> ────────────────────────────────────
#>   dist ~ speed   0.682     0.886    
#> ────────────────────────────────────
#> 
#> 

# hypothesis claim: non-zero null, one-sided
cars |>
    define_model(rel(speed, dist)) |>
    prepare_test(COR_TEST) |>
    state_null(RHO(speed, dist) >= 0.8) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : rel 
#> Args : speed ; dist 
#>     x_vars : 1 
#>     resp_vars : 1 
#> 
#> == Correlation Test ============================================================ 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ────────────────────────────────────────────
#>       pair      estimate  statistic  p_val  
#> ────────────────────────────────────────────
#>   dist ~ speed   0.807      0.133    0.553  
#> ────────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ────────────────────────────────────
#>       pair      lower_95  upper_95  
#> ────────────────────────────────────
#>   dist ~ speed     -1      0.876    
#> ────────────────────────────────────
#> 
#> 
```
