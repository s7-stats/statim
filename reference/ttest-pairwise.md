# T-Test: Pairwise (`pairwise`)

The `pairwise` implementation performs pairwise t-tests across a set of
numeric variables. Each pair of variables is compared independently, and
results are presented as a matrix.

Use
[`pairwise()`](https://s7-stats.github.io/statim/reference/pairwise.md)
as the model ID to select this implementation.

## Arguments

The following arguments are passed via `...` in
[`TTEST()`](https://s7-stats.github.io/statim/reference/TTEST.md):

- `.paired`:

  Logical. Whether to perform paired comparisons. Default `FALSE`.

- `.mu`:

  Numeric. Hypothesized mean or mean difference. Length 1 (applied to
  all pairs) or one value per variable. Default `0`.

- `.alt`:

  String. One of `"two.sided"`, `"greater"`, or `"less"`. Default
  `"two.sided"`.

- `.ci`:

  Numeric. Confidence level. Default `0.95`.

## Variants

No variants are currently registered for the `pairwise` path. Use
[`add_variant()`](https://s7-stats.github.io/statim/reference/add-variant.md)
to register custom variants at the user or package level.

## Result class

Returns a
[class_ttest_pairwise](https://s7-stats.github.io/statim/reference/class_ttest_pairwise.md)
object inheriting from
[class_stat_infer](https://s7-stats.github.io/statim/reference/class_stat_infer.md).
Results are printed as a pairwise matrix via
[`tabstats::pairwise_matrix()`](https://rdrr.io/pkg/tabstats/man/pairwise_matrix.html).

## One-sample mode

When
[`pairwise()`](https://s7-stats.github.io/statim/reference/pairwise.md)
is constructed with a `direction = "eq"` argument, each variable is
tested against its own `.mu` value rather than against another variable.
The result matrix displays diagonal entries only.

## See also

Other ttest-implementations:
[`ttest-formula`](https://s7-stats.github.io/statim/reference/ttest-formula.md),
[`ttest-xby`](https://s7-stats.github.io/statim/reference/ttest-xby.md)

## Examples

``` r
iris |>
    define_model(pairwise(Sepal.Length, Sepal.Width, Petal.Length)) |>
    prepare_test(TTEST) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : pairwise 
#> Args : Sepal.Length, Sepal.Width, Petal.Length 
#>     direction : lt 
#>     n_pairs : 3 
#> 
#> == T-Test ====================================================================== 
#> 
#> 
#> ┌───────────────────────────┐
#> | Layout for Pairwise Matri |
#> ├───────────────────────────┤
#> |         < diff >          |
#> |        < t_stat >         |
#> |         < pval >          |
#> └───────────────────────────┘
#> 
#> 
#>                   Welch Two Sample t-test                   
#> ────────────────────────────────────────────────────────────
#>   Variable       Sepal.Length   Petal.Length   Sepal.Width  
#> ────────────────────────────────────────────────────────────
#>   Sepal.Length                                              
#>                                                             
#>                                                             
#> ────────────────────────────────────────────────────────────
#>   Petal.Length      -2.085                                  
#>                    -13.098                                  
#>                     <0.001                                  
#> ────────────────────────────────────────────────────────────
#>   Sepal.Width       2.786          0.701                    
#>                     36.463         4.719                    
#>                     <0.001         <0.001                   
#> ────────────────────────────────────────────────────────────
```
