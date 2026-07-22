# Recalibrate arguments from the main pipeline

[`update()`](https://rdrr.io/r/stats/update.html) modifies the arguments
of a lazy test pipeline without changing the method variant or engine.

## Arguments

- object:

  A `test_lazy` object.

- ...:

  Named arguments to update.

## Value

The modified `test_lazy` object.

## Examples

``` r
sleep |>
    define_model(extra ~ group) |>
    prepare_test(T_TEST) |>
    update(.ci = 0.9) |>
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
#>   groups     type     lower_90  upper_90  
#> ──────────────────────────────────────────
#>   group   two sample   -3.053    -0.107   
#> ──────────────────────────────────────────
#> 
#> 
```
