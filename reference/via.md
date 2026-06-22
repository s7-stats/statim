# Recalibrate the method variant

`via()` switches a lazy pipeline to an alternative method variant and
merges user-supplied arguments with the variant's declared defaults.
Works for both `test_lazy` and `model_lazy` pipelines.

## Usage

``` r
via(.x, .method, ...)
```

## Arguments

- .x:

  A `test_lazy` or `model_lazy` object.

- .method:

  A string naming the method variant. Must match a named
  [`variant()`](https://s7-stats.github.io/statim/reference/variant.md)
  in the
  [`agendas()`](https://s7-stats.github.io/statim/reference/agendas.md)
  of the matched
  [`stat_define()`](https://s7-stats.github.io/statim/reference/stat-infer-definer.md).
  E.g. `"boot"`, `"permute"`, `"permute_rfast"`.

- ...:

  Named arguments forwarded to the variant.

## Value

The modified lazy object with `recalibrate_spec` populated.

## See also

[`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md),
[`stat_define()`](https://s7-stats.github.io/statim/reference/stat-infer-definer.md)

## Examples

``` r
sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(TTEST) |>
    via("boot", n = 2000) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : x_by 
#> Args : extra | group 
#>     x_vars : 1 
#>     by_vars : 1 
#> 
#> == T-Test · boot =============================================================== 
#> 
#> ============================== Bootstrapped T-test =============================
#> 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> Warning: running command 'tput cols' had status 2
#> ------------------------------
#>   CI     :   [-3.14, 0.0102]
#>   n_reps :              2000
#> ------------------------------
#> 
#> 

sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(TTEST) |>
    via("permute", n = 999L) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : x_by 
#> Args : extra | group 
#>     x_vars : 1 
#>     by_vars : 1 
#> 
#> == T-Test · permute ============================================================ 
#> 
#> ============================== T-test Permutation ==============================
#> 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ───────────────────────────────
#>   Statistic  p-value  n_perms  
#> ───────────────────────────────
#>    -1.580     0.099     999    
#> ───────────────────────────────
#> 
#> 
```
