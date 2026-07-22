# Correlation Test

`COR_TEST()` performs a correlation test for one-to-one variable
relationships. If `COR_TEST` is supplied within the lazy-loaded
pipeline, supply `COR_TEST` as a function i.e.
`prepare_test(.test = COR_TEST)` call.

## Usage

``` r
COR_TEST(.var_id = NULL, .data = NULL, ...)
```

## Arguments

- .var_id:

  A variable mapper `<var_id>` for `COR_TEST()`, e.g.
  [`rel()`](https://s7-stats.github.io/statim/dev/reference/rel.md).
  When supplied, the test executes immediately.

- .data:

  A data frame. Only used on the standalone path.

- ...:

  Additional arguments passed to the implementation. See the
  **Arguments** section of each implementation page.

## Value

A `cld_exec` object (in
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)),
or a `test_spec` object when `.var_id = NULL`. The default correlation
test class for most paths is
[class_corr_two](https://s7-stats.github.io/statim/dev/reference/class_corr_two.md).

## Supported variable mapper `<var_id>`s

Each variable mapper `<var_id>` routes to a separate implementation. See
the linked pages for full argument lists, variants, and correlation test
class details:

- [`rel()`](https://s7-stats.github.io/statim/dev/reference/rel.md):
  one-to-one correlation test. See details from
  [cortest-rel](https://s7-stats.github.io/statim/dev/reference/cortest-rel.md).

- `<formula>`: one-to-many correlation test. See details from
  [cortest-formula](https://s7-stats.github.io/statim/dev/reference/cortest-formula.md).

## See also

[cortest-rel](https://s7-stats.github.io/statim/dev/reference/cortest-rel.md),
[cortest-formula](https://s7-stats.github.io/statim/dev/reference/cortest-formula.md)
for per-implementation details.
[class_corr_two](https://s7-stats.github.io/statim/dev/reference/class_corr_two.md)
for correlation test class slots.
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md),
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md),
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md),
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md).

## Examples

``` r
# eager
COR_TEST(rel(speed, dist), cars)
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

cars |>
    define_model(speed ~ dist) |>
    prepare_test(COR_TEST) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : formula 
#> Args : speed ~ dist 
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
#>   speed ~ dist   0.807      9.464    48  <0.001  
#> ─────────────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ────────────────────────────────────
#>       pair      lower_95  upper_95  
#> ────────────────────────────────────
#>   speed ~ dist   0.682     0.886    
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

# Custom Hypothesis Expression
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
