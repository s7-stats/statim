# T-Test: Formula interface

The formula implementation performs one-sample or two-sample t-tests
specified via a standard R formula. The response variable is taken from
the left-hand side; the right-hand side determines the test type:

1.  `y ~ group`: two-sample t-test, one test per grouping variable.

2.  `y ~ 1`: one-sample t-test against `.mu`.

3.  `y ~ group + 1`" both tests in a single call.

Use a formula directly as the variable mapper `<var_id>` to select this
implementation.

## Arguments

The following arguments are passed via `...` in
[`T_TEST()`](https://s7-stats.github.io/statim/dev/reference/T_TEST.md):

- `.mu`:

  Numeric. Hypothesized mean or mean difference. Default `0`.

- `.alt`:

  String. One of `"two.sided"`, `"greater"`, or `"less"`. Default
  `"two.sided"`.

- `.ci`:

  Numeric. Confidence level. Default `0.95`.

## Variants

No variants are currently registered for the formula path. Use
[`add_variant()`](https://s7-stats.github.io/statim/dev/reference/add-variant.md)
to register custom variants at the user or package level.

## Formula-based t-test class

Returns a tibble with columns `type`, `group`, and `ttest` (a
list-column of [`stats::t.test()`](https://rdrr.io/r/stats/t.test.html)
objects). This path does not currently return a
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md)
subclass. Otherwise, to process outputs:

- [`print()`](https://rdrr.io/r/base/print.html): Write it down through
  `print` from
  [`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md).

- [`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md):
  Use
  [`making_tidy()`](https://s7-stats.github.io/statim/dev/reference/making_tidy.md)
  to register a tidy method if needed.

## See also

Other ttest-implementations:
[`ttest-on`](https://s7-stats.github.io/statim/dev/reference/ttest-on.md),
[`ttest-pairwise`](https://s7-stats.github.io/statim/dev/reference/ttest-pairwise.md),
[`ttest-xby`](https://s7-stats.github.io/statim/dev/reference/ttest-xby.md)

## Examples

``` r
sleep |>
    define_model(extra ~ group) |>
    prepare_test(T_TEST) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : formula 
#> Args : extra ~ group 
#>     left_var : 1 
#>     right_var : 1 
#> 
#> == T-Test ====================================================================== 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ───────────────────────────────────────────────────────
#>   groups     type     est_type   est    t-stat  pval   
#> ───────────────────────────────────────────────────────
#>   group   two sample  mu_diff   -1.580  -1.861  0.079  
#> ───────────────────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ──────────────────────────────────────────
#>   groups     type     lower_95  upper_95  
#> ──────────────────────────────────────────
#>   group   two sample   -3.365    0.205    
#> ──────────────────────────────────────────
#> 
#> 

# one-sample
sleep |>
    define_model(extra ~ 1) |>
    prepare_test(T_TEST) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : formula 
#> Args : extra ~ 1 
#>     left_var : 1 
#>     right_var : 0 
#> 
#> == T-Test ====================================================================== 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ───────────────────────────────────────────────────────
#>   groups     type     est_type   est   t-stat   pval   
#> ───────────────────────────────────────────────────────
#>     1     one sample     mu     1.540  3.413   <0.001  
#> ───────────────────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ──────────────────────────────────────────
#>   groups     type     lower_95  upper_95  
#> ──────────────────────────────────────────
#>     1     one sample   0.596     2.484    
#> ──────────────────────────────────────────
#> 
#> 

# both in one call
sleep |>
    define_model(extra ~ group + 1) |>
    prepare_test(T_TEST) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : formula 
#> Args : extra ~ group + 1 
#>     left_var : 1 
#>     right_var : 1 
#> 
#> == T-Test ====================================================================== 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ────────────────────────────────────────────────────────
#>   groups     type     est_type   est    t-stat   pval   
#> ────────────────────────────────────────────────────────
#>   group   two sample  mu_diff   -1.580  -1.861  0.079   
#>     1     one sample     mu     1.540   3.413   <0.001  
#> ────────────────────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ──────────────────────────────────────────
#>   groups     type     lower_95  upper_95  
#> ──────────────────────────────────────────
#>   group   two sample   -3.365    0.205    
#>     1     one sample   0.596     2.484    
#> ──────────────────────────────────────────
#> 
#> 
```
