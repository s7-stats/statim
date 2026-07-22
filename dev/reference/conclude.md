# Execute a lazy pipeline

`conclude()` is the terminal step of the pipeline. It resolves the
method variant, runs the implementation, and returns a `cld_exec` S7
object.

## Usage

``` r
conclude(.x, ...)
```

## Arguments

- .x:

  A `test_lazy` or `model_lazy` object produced by
  [`prepare_test()`](https://s7-stats.github.io/statim/dev/reference/prepare-test.md)
  or
  [`prepare_model()`](https://s7-stats.github.io/statim/dev/reference/prepare-model.md)
  (optionally followed by
  [`via()`](https://s7-stats.github.io/statim/dev/reference/via.md)).

- ...:

  Currently unused.

## Value

A `cld_exec` S7 object with the following slots:

- `@data`:

  The raw return value of the `fn` defined in
  [`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md)
  or
  [`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md).
  Its structure depends on the implementation — see the documentation of
  the stat function (e.g.
  [`?T_TEST`](https://s7-stats.github.io/statim/dev/reference/T_TEST.md))
  for what to expect.

- `@cld_meta`:

  A list of pipeline metadata:

  `$var_id`

  :   The Variable Mapper object passed to
      [`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md).

  `$processed`

  :   The processed model output from
      [`model_processor()`](https://s7-stats.github.io/statim/dev/reference/model-processor.md).
      The same object received as `.proc` inside the `fn`.

  `$stat_name`

  :   The human-readable test or model name.

  `$method`

  :   The variant name used. `"default"` when no
      [`via()`](https://s7-stats.github.io/statim/dev/reference/via.md)
      was called.

  `$data_name`

  :   The name of the data frame, if resolvable.

## Writing print functions

The `print` argument of
[`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md)
and
[`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md)
receives a `cld_exec` object as `x`. Read your output from `x@data`:

    baseline(
        fn = function(.proc, .mu = 0) { ... },
        print = function(x, ...) {
            dat = x@data
            # render dat
            invisible(x)
        }
    )

Otherwise, when the base S7 class dispatches
[`print()`](https://rdrr.io/r/base/print.html) elsewhere, it is
inherited without writing `print` from
[`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md)
/
[`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md)

## Writing tidy functions

Prefer implementing
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md)
on your result class when `fn` returns a
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md)
subclass. Use
[`making_tidy()`](https://s7-stats.github.io/statim/dev/reference/making_tidy.md)
only when `fn` intentionally returns a
non-[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md)
object.

For example:

    making_tidy(T_TEST, x_by) %<-% method_tidy(
        default = function(.x, ...) {
            dat = .x@data
            # return a tibble
        }
    )

## See also

[`prepare_test()`](https://s7-stats.github.io/statim/dev/reference/prepare-test.md),
[`prepare_model()`](https://s7-stats.github.io/statim/dev/reference/prepare-model.md),
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md),
[`model_processor()`](https://s7-stats.github.io/statim/dev/reference/model-processor.md),
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md),
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md)

## Examples

``` r
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
#> ---------------------------------
#>   CI     :   [-3.1605, -0.0598]
#>   n_reps :                 2000
#> ---------------------------------
#> 
#> 

mtcars |>
    define_model(rel(mpg, wt)) |>
    prepare_model(LINEAR_REG) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : rel 
#> Args : mpg ; wt 
#>     x_vars : 1 
#>     resp_vars : 1 
#> 
#> == Linear Regression =========================================================== 
#> 
#> -- Coefficients ----------------------------------------------------------------
#> 
#> ──────────────┬───────────────────────────────────────────
#>   term        │  estimate  std_error  statistic  p_value  
#> ──────────────┼───────────────────────────────────────────
#>   (Intercept) │   6.047      0.309     19.590    <0.001   
#>   mpg         │   -0.141     0.015     -9.559    <0.001   
#> ──────────────┴───────────────────────────────────────────
#> 
#> 
#> -- Model Fit -------------------------------------------------------------------
#> 
#> Warning: running command 'tput cols' had status 2
#> ------------------------------------------------------
#>   R Squared      :    0.75    F-statistic :    91.38
#>   Adj. R Squared :    0.74    df1         :        1
#>   Sigma          :    0.49    df2         :       30
#>   n              :      32    p-value     :   <0.001
#>   df (residual)  :      30                :         
#> ------------------------------------------------------
#> 
#> 
```
