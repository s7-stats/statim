# T-Test

`TTEST()` performs a t-test for one-sample, two-sample, paired,
pairwise, or formula-based comparisons.

## Usage

``` r
TTEST(.model = NULL, .data = NULL, ...)
```

## Arguments

- .model:

  A model ID from
  [`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md),
  [`pairwise()`](https://s7-stats.github.io/statim/reference/pairwise.md),
  or a formula. When supplied, the test executes immediately. When
  `NULL` (default), returns a `test_spec` for use in the pipeline via
  [`prepare_test()`](https://s7-stats.github.io/statim/reference/prepare-test.md).

- .data:

  A data frame. Only used on the standalone path.

- ...:

  Additional arguments passed to the implementation. See the **Arguments
  by model ID** section for the full list per path.

## Value

A `cld_exec` object (in
[`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md)),
a `stat_infer_spec` object, or a `test_spec` when `.model = NULL`.
Depending on the implementation you wrote, it returns any class.
However, by default, some implementations use base `{statim}` S7
classes. For instance:

- `ttest_x_by`, by default, returns a
  [class_ttest_two](https://s7-stats.github.io/statim/reference/class_ttest_two.md)
  object

- `ttest_pairwise`, by default, returns a
  [class_ttest_pairwise](https://s7-stats.github.io/statim/reference/class_ttest_pairwise.md)
  object

## Supported model IDs

Each model ID routes to a separate implementation. See the linked pages
for full argument lists, variants, and result class details:

- [`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md):
  two-sample or paired t-test. See
  [ttest-xby](https://s7-stats.github.io/statim/reference/ttest-xby.md).

- [`pairwise()`](https://s7-stats.github.io/statim/reference/pairwise.md):
  pairwise t-tests across variables. See
  [ttest-pairwise](https://s7-stats.github.io/statim/reference/ttest-pairwise.md).

- `<formula>`: one-sample and/or two-sample t-test. See
  [ttest-formula](https://s7-stats.github.io/statim/reference/ttest-formula.md).

## Arguments

The following arguments are passed via `...` in `TTEST()` or
[`via()`](https://s7-stats.github.io/statim/reference/via.md):

- `.paired`:

  Logical. Whether to perform a paired t-test. Default `FALSE`.

- `.mu`:

  Numeric. Hypothesized mean difference. Default `0`.

- `.alt`:

  Direction: `"two.sided"`, `"greater"`, or `"less"`. Default
  `"two.sided"`.

- `.ci`:

  Confidence level. Default `0.95`.

## Variants

- `"boot"`:

  Bootstrap CI. Accepts `n` (reps) and `seed`.

- `"permute"`:

  Permutation test. Accepts `n` and `seed`.

- `"weighted"`:

  Weighted contrast. Accepts `.w`, `.mu`, `.ci`, `.op`.

## Result class

Returns a
[class_ttest_two](https://s7-stats.github.io/statim/reference/class_ttest_two.md)
object. All variants that also return
[class_ttest_two](https://s7-stats.github.io/statim/reference/class_ttest_two.md)
inherit
[`auto_tidy()`](https://s7-stats.github.io/statim/reference/auto_tidy.md)
and [`print()`](https://rdrr.io/r/base/print.html) automatically.

## Hypothesis claims

Supports [`MU()`](https://s7-stats.github.io/statim/reference/MU.md) via
[`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md).
The `weighted` variant additionally accepts contrast coefficients via
`.w`.

## See also

[ttest-xby](https://s7-stats.github.io/statim/reference/ttest-xby.md),
[ttest-pairwise](https://s7-stats.github.io/statim/reference/ttest-pairwise.md),
[ttest-formula](https://s7-stats.github.io/statim/reference/ttest-formula.md)
for per-implementation details.
[class_ttest_two](https://s7-stats.github.io/statim/reference/class_ttest_two.md),
[class_ttest_pairwise](https://s7-stats.github.io/statim/reference/class_ttest_pairwise.md)
for result class slots.
[`via()`](https://s7-stats.github.io/statim/reference/via.md),
[`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md),
[`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md),
[`auto_tidy()`](https://s7-stats.github.io/statim/reference/auto_tidy.md).

## Examples

``` r
# eager
TTEST(x_by(extra, group), sleep)
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
    prepare_test(TTEST) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : x_by 
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
    prepare_test(TTEST) |>
    via("boot", n = 2000) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : x_by 
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
    prepare_test(TTEST) |>
    via("permute", n = 2000) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : x_by 
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

# weighted contrast
sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(TTEST) |>
    state_null(
        2 * MU(extra, group == "1") <= MU(extra, group == "2")
    ) |>
    via("weighted") |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : x_by 
#> Args : extra | group 
#>     x_vars : 1 
#>     by_vars : 1 
#> 
#> == T-Test · weighted =========================================================== 
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
#>   group  lower_95  upper_95  
#> ─────────────────────────────
#>   group   -2.282     Inf     
#> ─────────────────────────────
#> 
#> 

# pairwise
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

# hypothesis claim
sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(TTEST) |>
    state_null(MU(extra) == 0) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : x_by 
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
```
