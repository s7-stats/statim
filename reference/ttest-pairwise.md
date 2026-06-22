# T-Test: Pairwise (`pairwise`)

The `pairwise` implementation performs pairwise t-tests across a set of
numeric variables. Each pair of variables is compared independently, and
results are presented as a matrix.

Use
[`pairwise()`](https://s7-stats.github.io/statim/reference/pairwise.md)
as the variable mapper `<var_id>` to select this implementation.

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

## Pairwise t-test class

By default, it returns a
[class_ttest_pairwise](https://s7-stats.github.io/statim/reference/class_ttest_pairwise.md)
object inheriting from
[class_stat_infer](https://s7-stats.github.io/statim/reference/class_stat_infer.md).
Objects from it are printed as a pairwise matrix via
[`tabstats::pairwise_matrix()`](https://rdrr.io/pkg/tabstats/man/pairwise_matrix.html).
All variants that also return
[class_ttest_two](https://s7-stats.github.io/statim/reference/class_ttest_two.md)
inherit
[`auto_tidy()`](https://s7-stats.github.io/statim/reference/auto_tidy.md)
and [`print()`](https://rdrr.io/r/base/print.html) automatically.
Otherwise, to process outputs:

- [`print()`](https://rdrr.io/r/base/print.html): Write it down through
  `print` from
  [`variant()`](https://s7-stats.github.io/statim/reference/variant.md).

- [`tidy()`](https://s7-stats.github.io/statim/reference/tidy.md): Use
  [`making_tidy()`](https://s7-stats.github.io/statim/reference/making_tidy.md)
  to register a tidy method if needed.

## One-sample mode

When
[`pairwise()`](https://s7-stats.github.io/statim/reference/pairwise.md)
has equal referred columns, made by `direction = "<eq, lteq, gteq>"`
argument, each variable is tested against its own `.mu` value rather
than against another variable, resonating to a one-sample test. The
pairwise t-test output matrix displays diagonal entries only.

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
#> Variable Mapper : pairwise 
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
#> |          < ci >           |
#> └───────────────────────────┘
#> 
#> 
#>                      Welch Two Sample t-test                      
#> ──────────────────────────────────────────────────────────────────
#>   Variable         Sepal.Length      Petal.Length    Sepal.Width  
#> ──────────────────────────────────────────────────────────────────
#>   Sepal.Length                                                    
#>                                                                   
#>                                                                   
#>                                                                   
#> ──────────────────────────────────────────────────────────────────
#>   Petal.Length        -2.085                                      
#>                      -13.098                                      
#>                       <0.001                                      
#>                  [-2.399  -1.772]                                 
#> ──────────────────────────────────────────────────────────────────
#>   Sepal.Width         2.786             0.701                     
#>                       36.463            4.719                     
#>                       <0.001            <0.001                    
#>                   [2.635  2.937]    [0.408  0.994]                
#> ──────────────────────────────────────────────────────────────────
```
