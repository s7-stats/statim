# T-Test

`T_TEST()` performs a t-test for one-sample, two-sample, paired,
pairwise, or formula-based comparisons. If `T_TEST` is supplied within
the lazy-loaded pipeline, supply `T_TEST` as a function within i.e.
`prepare_test(.test = T_TEST)` call.

## Usage

``` r
T_TEST(.var_id = NULL, .data = NULL, ...)
```

## Arguments

- .var_id:

  A variable mapper `<var_id>` from
  [`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md),
  [`pairwise()`](https://s7-stats.github.io/statim/dev/reference/pairwise.md),
  or a formula. When supplied, the test executes immediately.

- .data:

  A data frame. Only used on the standalone path.

- ...:

  Additional arguments passed to the implementation. See the **Arguments
  by variable mapper** section for the full list per path.

## Value

A `cld_exec` object (in
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)),
a `stat_infer_spec` object, or a `test_spec` when `.var_id = NULL`.
Depending on the implementation you wrote, it returns any class.
However, by default, some implementations use base `{statim}` S7
classes. For instance:

- `ttest_x_by`, by default, returns a
  [class_ttest_two](https://s7-stats.github.io/statim/dev/reference/class_ttest_two.md)
  object

- `ttest_pairwise`, by default, returns a
  [class_ttest_pairwise](https://s7-stats.github.io/statim/dev/reference/class_ttest_pairwise.md)
  object

## Supported variable mapper `<var_id>`s

Each variable mapper `<var_id>` routes to a separate implementation. See
the linked pages for full argument lists, variants, and result class
details:

- [`on()`](https://s7-stats.github.io/statim/dev/reference/on.md):
  one-sample t-test. See details from
  [ttest-on](https://s7-stats.github.io/statim/dev/reference/ttest-on.md).

- [`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md):
  two-sample or paired t-test. See details from
  [ttest-xby](https://s7-stats.github.io/statim/dev/reference/ttest-xby.md).

- [`pairwise()`](https://s7-stats.github.io/statim/dev/reference/pairwise.md):
  pairwise t-tests across variables. See details from
  [ttest-pairwise](https://s7-stats.github.io/statim/dev/reference/ttest-pairwise.md).

- `<formula>`: one-sample and/or two-sample t-test. See details from
  [ttest-formula](https://s7-stats.github.io/statim/dev/reference/ttest-formula.md).

## References

Welch, B. L. (1947). The generalization of "Student's" problem when
several different population variances are involved. *Biometrika*,
34(1-2), 28-35.
[doi:10.1093/biomet/34.1-2.28](https://doi.org/10.1093/biomet/34.1-2.28)

Satterthwaite, F. E. (1946). An approximate distribution of estimates of
variance components. *Biometrics Bulletin*, 2(6), 110-114.
[doi:10.2307/3002019](https://doi.org/10.2307/3002019)

Kutner, M. H., Nachtsheim, C. J., Neter, J., & Li, W. (2004). *Applied
Linear Statistical Models* (5th ed.). McGraw-Hill/Irwin.

## See also

[ttest-on](https://s7-stats.github.io/statim/dev/reference/ttest-on.md),
[ttest-xby](https://s7-stats.github.io/statim/dev/reference/ttest-xby.md),
[ttest-pairwise](https://s7-stats.github.io/statim/dev/reference/ttest-pairwise.md),
[ttest-formula](https://s7-stats.github.io/statim/dev/reference/ttest-formula.md)
for per-implementation details.
[class_ttest_two](https://s7-stats.github.io/statim/dev/reference/class_ttest_two.md),
[class_ttest_pairwise](https://s7-stats.github.io/statim/dev/reference/class_ttest_pairwise.md)
for result class slots.
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md),
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md),
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md),
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md).

## Examples

``` r
# eager
T_TEST(x_by(extra, group), sleep)
#> -- Summary ---------------------------------------------------------------------
#> 
#> ──────────────────────────────────────────
#>   group  estimate  t_stat    df    p_val  
#> ──────────────────────────────────────────
#>   group   -1.580   -1.861  17.780  0.079  
#> ──────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ─────────────────────────────
#>   group  lower_95  upper_95  
#> ─────────────────────────────
#>   group   -3.365    0.206    
#> ─────────────────────────────
#> 
#> 

# pipeline
sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(T_TEST) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : x_by 
#> Args : extra | group 
#>     x_vars : 1 
#>     by_vars : 1 
#> 
#> == T-Test ====================================================================== 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ──────────────────────────────────────────
#>   group  estimate  t_stat    df    p_val  
#> ──────────────────────────────────────────
#>   group   -1.580   -1.861  17.780  0.079  
#> ──────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ─────────────────────────────
#>   group  lower_95  upper_95  
#> ─────────────────────────────
#>   group   -3.365    0.206    
#> ─────────────────────────────
#> 
#> 

# bootstrap
sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(T_TEST) |>
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
#>   CI     :   [-3.21, 0.0702]
#>   n_reps :              2000
#> ------------------------------
#> 
#> 

# permutation
sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(T_TEST) |>
    via("permute", n = 2000) |>
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
#>    -1.580     0.092    2000    
#> ───────────────────────────────
#> 
#> 

# Contrast t-test
# This uses `state_null()` in a higher degree
# This performs Welch-Satterthwaite linear contrast test for t-test
sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(T_TEST) |>
    state_null(
        2 * MU(extra, group == "1") <= MU(extra, group == "2")
    ) |>
    # Try to obtain 90% of the confidence interval
    via("contrast", .ci = 0.9) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : x_by 
#> Args : extra | group 
#>     x_vars : 1 
#>     by_vars : 1 
#> 
#> == T-Test · contrast =========================================================== 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ──────────────────────────────────────────
#>   group  estimate  t_stat    df    p_val  
#> ──────────────────────────────────────────
#>   group   -0.830   -0.640  14.130  0.734  
#> ──────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ─────────────────────────────
#>   group  lower_90  upper_90  
#> ─────────────────────────────
#>   group   -2.573     Inf     
#> ─────────────────────────────
#> 
#> 

# pairwise
iris |>
    define_model(pairwise(Sepal.Length, Sepal.Width, Petal.Length)) |>
    prepare_test(T_TEST) |>
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
#> ┌────────────────────────────┐
#> | Layout for Pairwise Matrix |
#> ├────────────────────────────┤
#> |          < diff >          |
#> |         < t_stat >         |
#> |          < pval >          |
#> |           < ci >           |
#> └────────────────────────────┘
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
