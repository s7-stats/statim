# Chained equality operator for null hypotheses

`%=%` declares that all chained population parameters are hypothesized
to be equal. Used inside
[`state_null()`](https://joshuamarie.github.io/statim/reference/null-hyp.md)
only — it is a syntactic macro and will error if called outside that
context.

## Usage

``` r
lhs %=% rhs
```

## Arguments

- lhs:

  The left-hand side population parameter.

- rhs:

  The right-hand side population parameter.

## Value

Does not return. Always throws an error when called outside
[`state_null()`](https://joshuamarie.github.io/statim/reference/null-hyp.md).

## Examples

``` r
sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(ANOVA) |>
    state_null(
        MU(extra, group == "1") %=%
        MU(extra, group == "2")
    ) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : x_by 
#> Args : extra | group 
#>     x_vars : 1 
#>     by_vars : 1 
#> 
#> == ANOVA ======================================================================= 
#> 
#> -- ANOVA Table -----------------------------------------------------------------
#> 
#> ───────────────────────────────────────────────
#>     term     df    SS      MS      F    pval   
#> ───────────────────────────────────────────────
#>     group    1   12.482  12.482  3.463  0.079  
#>   Residuals  18  64.886  3.605                 
#> ───────────────────────────────────────────────
#> 
```
