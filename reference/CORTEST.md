# Correlation Test

`CORTEST()` performs a correlation test for one-to-one variable
relationships. If `CORTEST` is supplied within the lazy-loaded pipeline,
supply `CORTEST` as a function i.e. `prepare_test(.test = CORTEST)`
call.

## Usage

``` r
CORTEST(.model = NULL, .data = NULL, ...)
```

## Arguments

- .model:

  A model ID for `CORTEST()`, e.g.
  [`rel()`](https://s7-stats.github.io/statim/reference/rel.md). When
  supplied, the test executes immediately.

- .data:

  A data frame. Only used on the standalone path.

- ...:

  Additional arguments passed to the implementation. See the
  **Arguments** section of each implementation page.

## Value

A `cld_exec` object (in
[`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md)),
or a `test_spec` object when `.model = NULL`. The default correlation
test class for most paths is
[class_corr_two](https://s7-stats.github.io/statim/reference/class_corr_two.md).

## Supported model IDs

Each model ID routes to a separate implementation. See the linked pages
for full argument lists, variants, and correlation test class details:

- [`rel()`](https://s7-stats.github.io/statim/reference/rel.md):
  one-to-one correlation test. See
  [cortest-rel](https://s7-stats.github.io/statim/reference/cortest-rel.md).

- `<formula>`: one-to-many correlation test. See
  [cortest-formula](https://s7-stats.github.io/statim/reference/cortest-formula.md).

## Arguments

The following arguments are passed via `...` in `CORTEST()`:

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
  [`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md).

- `"kendall"`:

  Kendall's \\\tau\\. Uses
  [`stats::cor.test()`](https://rdrr.io/r/stats/cor.test.html) with
  `method = "kendall"`. No confidence interval is returned. Does not
  support
  [`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md).

## Correlation test default class

Returns a
[class_corr_two](https://s7-stats.github.io/statim/reference/class_corr_two.md)
object inheriting from
[class_stat_infer](https://s7-stats.github.io/statim/reference/class_stat_infer.md).

For the `base` variant, `df`, `lower_ci`, and `upper_ci` are always
populated. For `spearman` and `kendall`, those slots are `numeric(0)`
and are omitted from the printed output.

## Hypothesis claims

Supports [`RHO()`](https://s7-stats.github.io/statim/reference/RHO.md)
via
[`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md).
Only available on the `base` (Pearson) variant. The claim is parsed as
follows:

- The operator maps to `.alt`: `==` and `!=` become `"two.sided"`, `>=`
  and `>` become `"less"`, `<=` and `<` become `"greater"`.

- The scalar maps to `.rho`: `RHO(x, y) == 0.9`, not `0.9 == RHO(x, y)`,
  is handled correctly via
  [`claim_scalar()`](https://s7-stats.github.io/statim/reference/claim_scalar.md).

## See also

[cortest-rel](https://s7-stats.github.io/statim/reference/cortest-rel.md),
[cortest-formula](https://s7-stats.github.io/statim/reference/cortest-formula.md)
for per-implementation details.
[class_corr_two](https://s7-stats.github.io/statim/reference/class_corr_two.md)
for correlation test class slots.
[`via()`](https://s7-stats.github.io/statim/reference/via.md),
[`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md),
[`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md),
[`auto_tidy()`](https://s7-stats.github.io/statim/reference/auto_tidy.md).

## Examples

``` r
# eager
CORTEST(rel(speed, dist), cars)
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

# grammatical syntax
cars |>
    define_model(rel(speed, dist)) |>
    prepare_test(CORTEST) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : rel 
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
        prepare_test(CORTEST) |>
        via("spearman") |>
        conclude()
})
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : rel 
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

# Custom Hypothesis Expression
cars |>
    define_model(rel(speed, dist)) |>
    prepare_test(CORTEST) |>
    state_null(RHO(speed, dist) >= 0.8) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : rel 
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
