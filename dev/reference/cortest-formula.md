# Correlation Test: Formula interface

The formula implementation performs pairwise correlation tests between a
single response variable (LHS) and one or more independent variables
(RHS).

1.  `y ~ x`: one independent variable, one correlation test.

2.  `y ~ x1 + x2`: multiple independent variables, one test per RHS
    term.

Use a formula directly as the model ID to select this implementation.

## Arguments

The following arguments are passed via `...` in
[`COR_TEST()`](https://s7-stats.github.io/statim/dev/reference/COR_TEST.md):

- `.cor_type`:

  String. One of `"pearson"`, `"spearman"`, or `"kendall"`. Default
  `"pearson"`.

- `.alt`:

  String. One of `"two.sided"`, `"greater"`, or `"less"`. Default
  `"two.sided"`.

- `.ci`:

  Numeric. Confidence level. Default `0.95`. Only used for Pearson;
  silently ignored for Kendall and Spearman.

## Correlation test default class

As detailed by
[cortest-rel](https://s7-stats.github.io/statim/dev/reference/cortest-rel.md),
it returns a
[class_corr_two](https://s7-stats.github.io/statim/dev/reference/class_corr_two.md)
object inheriting from
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md)
by default. You need to process outputs by:

- [`print()`](https://rdrr.io/r/base/print.html): Write it down through
  `print` from
  [`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md).

- [`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md):
  Use
  [`making_tidy()`](https://s7-stats.github.io/statim/dev/reference/making_tidy.md)
  to register a tidy method if needed.

if the variants from this method pipeline doesn't return a
[class_corr_two](https://s7-stats.github.io/statim/dev/reference/class_corr_two.md)
object.

## Hypothesis claims

Not supported. Use
[`rel()`](https://s7-stats.github.io/statim/dev/reference/rel.md) with
the `base` variant for
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md)
with [`RHO()`](https://s7-stats.github.io/statim/dev/reference/RHO.md).

## See also

Other cortest-implementations:
[`cortest-rel`](https://s7-stats.github.io/statim/dev/reference/cortest-rel.md)

## Examples

``` r
cars |>
    define_model(dist ~ speed) |>
    prepare_test(COR_TEST) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : formula 
#> Args : dist ~ speed 
#>     left_var : 1 
#>     right_var : 1 
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

# multiple independent variables
mtcars |>
    define_model(mpg ~ wt + hp) |>
    prepare_test(COR_TEST) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : formula 
#> Args : mpg ~ wt + hp 
#>     left_var : 1 
#>     right_var : 2 
#> 
#> == Correlation Test ============================================================ 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ─────────────────────────────────────────────
#>     pair    estimate  statistic  df  p_val   
#> ─────────────────────────────────────────────
#>   mpg ~ wt   -0.868    -9.559    30  <0.001  
#>   mpg ~ hp   -0.776    -6.742    30  <0.001  
#> ─────────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ────────────────────────────────
#>     pair    lower_95  upper_95  
#> ────────────────────────────────
#>   mpg ~ wt   -0.934    -0.744   
#>   mpg ~ hp   -0.885    -0.586   
#> ────────────────────────────────
#> 
#> 
```
