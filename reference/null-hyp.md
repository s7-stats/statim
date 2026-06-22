# State a null hypothesis in the pipeline

`state_null()` captures a hypothesis expression and attaches it to a
`test_lazy` object.

## Usage

``` r
state_null(.x, ...)
```

## Arguments

- .x:

  A `test_lazy` object from
  [`prepare_test()`](https://s7-stats.github.io/statim/reference/prepare-test.md).

- ...:

  Currently unused.

## Value

The modified `test_lazy` object.

## Slots

- `expr`:

  A hypothesis expression. It is passed after `prepare_test(...)` to
  supply the hypothesis expression, e.g.
  `... |> prepare_test(TTEST) |> state_null(expr = MU(x) == 0)`

## Examples

``` r
# Using binomial test as a simple example
define_model(prop(45, 100)) |>
    prepare_test(P_TEST) |>
    state_null(2 * PI() == 0.25) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : prop 
#> Args : 45 / 100 
#>     x : 45 
#>     n : 100 
#> 
#> == Proportion Test ============================================================= 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ────────────────────────────────────────────────
#>   x    n   true_p  estimate  statistic  p_val   
#> ────────────────────────────────────────────────
#>   45  100  0.250    0.450       45      <0.001  
#> ────────────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ──────────────────────
#>   lower_95  upper_95  
#> ──────────────────────
#>    0.350     0.553    
#> ──────────────────────
#> 
#> 
```
