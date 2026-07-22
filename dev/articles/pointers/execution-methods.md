# Execution and Retrieval of Outputs

## Rationale

[statim](https://s7-stats.github.io/statim/) separates *declaring* a
statistical analysis from *running* it. Everything up to (and including)
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md) builds
a lazy specification.
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
is the single point where execution actually happens. This separation is
what makes recalibration, inspection, and multi-model comparisons
composable.

This article traces the internal flow from
[`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md)
through to the retrieval functions
([`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md),
[`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md),
[`display()`](https://s7-stats.github.io/statim/dev/reference/display.md)),
describing what each stage produces and why.

| Stage | Function | Produces | Executes? |
|----|----|----|----|
| [Stage 1: layout define](#layout-define) | [`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md) | `<def_var>` | No |
| [Stage 2: parameterization](#parameterization) | [`prepare_test()`](https://s7-stats.github.io/statim/dev/reference/prepare-test.md) | `<test_lazy>` | No |
| [Stage 2: parameterization](#parameterization) | [`prepare_model()`](https://s7-stats.github.io/statim/dev/reference/prepare-model.md) | `<model_lazy>` | No |
| [Stage 2: parameterization](#parameterization) | [`prepare()`](https://s7-stats.github.io/statim/dev/reference/prepare.md) | `<test_lazy> / <model_lazy>` | No |
| [Stage 2: parameterization](#parameterization) | [`via()`](https://s7-stats.github.io/statim/dev/reference/via.md) | modified lazy object | No |
| [Stage 3: output process](#execution-at-conclude) | [`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md) | `cld_exec` | **Yes** |
| [Stage 3: output process](#retrieve-output) | [`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md) | tibble | (reads `cld_exec@data`) |
| [Stage 3: output process](#retrieve-output) | [`print()`](https://rdrr.io/r/base/print.html) | side effect | (reads `cld_exec@data`) |
| [Multiple executions](#multiple-executions) | [`write_models()`](https://s7-stats.github.io/statim/dev/reference/write_models.md) | `<expanded_model>` | No |
| [Multiple executions](#multiple-executions) | [`prepare_model()`](https://s7-stats.github.io/statim/dev/reference/prepare-model.md) / [`prepare_test()`](https://s7-stats.github.io/statim/dev/reference/prepare-test.md) / [`prepare()`](https://s7-stats.github.io/statim/dev/reference/prepare.md) | `<multi_lazy>` | No |
| [Multiple executions](#multiple-executions) | [`via()`](https://s7-stats.github.io/statim/dev/reference/via.md) / [`update()`](https://rdrr.io/r/stats/update.html) | modified `<multi_lazy>` | No |
| [Multiple executions](#multiple-executions) | [`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md) | `<multi_exec>` | **Yes** |

## Stage 1: Defining the Layout

[`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md)
is an S7 generic dispatched on its first argument. When called with a
data frame in pipe position, it dispatches on
[`S7::class_data.frame`](https://rconsortium.github.io/S7/reference/base_s3_classes.html);
when called with a model ID or formula first, it dispatches on the union
of those classes.
[`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md)
produces a `<def_var>` S7 object.

Either way, it calls
[`model_processor()`](https://s7-stats.github.io/statim/dev/reference/model-processor.md)
on the model ID and the data, then stores the result in a `<def_var>` S7
object:

``` r
def_var(
    model_id = <the model ID or formula>,
    processed = <list returned by model_processor()>
)
```

Nothing statistical has been computed. `@processed` is a named list of
resolved data structures (data frames, scalars) that the implementation
`fn` will later receive as `.proc`. No fit, no test statistic, no
p-value.

``` r

sleep |> define_model(x_by(extra, group))
#> 
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Variable Mapper : x_by 
#> Args : extra | group 
#> Other info:
#>     x_vars : 1 
#>     by_vars : 1 
#> Variables :
#>     extra : <dbl [20]> 
#>     group : <fct [20]>
```

## Stage 2: Parameterization

Three functions to attach a specification:
[`prepare_test()`](https://s7-stats.github.io/statim/dev/reference/prepare-test.md),
[`prepare_model()`](https://s7-stats.github.io/statim/dev/reference/prepare-model.md),
and
[`prepare()`](https://s7-stats.github.io/statim/dev/reference/prepare.md).
These three functions attach an inference specification to the
`<def_var>`. They differ only in which spec class they produce:

| Preparation function       | Spec class   | Lazy object class |
|----------------------------|--------------|-------------------|
| `prepare_test(.test)`      | `test_spec`  | `test_lazy`       |
| `prepare_model(.model_fn)` | `model_spec` | `model_lazy`      |
| `prepare(.fn)`             | Either       | Either\`          |

Internally, these functions call the stat function with
`.var_id = NULL`. This special sentinel causes the function to return
its `test_spec` or `model_spec` rather than running any computation,
which is how
[`prepare_test()`](https://s7-stats.github.io/statim/dev/reference/prepare-test.md),
[`prepare_model()`](https://s7-stats.github.io/statim/dev/reference/prepare-model.md),
and
[`prepare()`](https://s7-stats.github.io/statim/dev/reference/prepare.md)
harvest the lookup table of `stat_define` objects and the function’s
name.

The resulting lazy object carries three things:

- `@model_id`: the original model ID.
- `@processed`: the resolved data structures from
  [`model_processor()`](https://s7-stats.github.io/statim/dev/reference/model-processor.md).
- `@model_spec` / `@test_spec`: the spec, including the `defs` lookup
  table.

Still nothing has been computed:

``` r

sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(T_TEST)
#> 
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Variable Mapper : x_by 
#> Args : extra | group 
#> 
#> -- Test Specification ---------------------------------------------------------- 
#> 
#> Test   : T-Test 
#> Method : default
```

``` r

mtcars |>
    define_model(mpg ~ wt) |>
    prepare_model(LINEAR_REG)
#> 
#> mpg ~ wt
#> 
#> -- Model Specification --------------------------------------------------------- 
#> 
#> Model  : Linear Regression 
#> Method : default
```

### `via()` recalibrates without executing

[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md) is an
S7 generic dispatched on the lazy object class and a character string.
It validates that the named variant exists for the current model type,
then writes the variant name and any additional arguments into
`@recalibrate_spec`:

``` r

.x@recalibrate_spec = list(method_name = .method, args = list(...))
```

The lazy object is returned modified; no computation has occurred.
Calling
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md) a
second time overwrites `@recalibrate_spec` in place.

``` r

sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(T_TEST) |>
    via("permute", n = 999L)
#> 
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Variable Mapper : x_by 
#> Args : extra | group 
#> 
#> -- Test Specification ---------------------------------------------------------- 
#> 
#> Test   : T-Test 
#> Method : permute 
#> Args   : n = 999
```

## Stage 3: Execution and output processing

### `conclude()`

[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
is the terminal step. It is an S7 generic with separate methods for
`test_lazy` and `model_lazy`; both methods follow the same four-step
sequence.

1.  *Find the matching `stat_define`*, which uses `find_def()` to look
    up the `defs` list from the spec and matches on
    `S7::S7_class(model_id)@name` (or `"formula"` when the model ID is
    an R formula). This selects the right `stat_define` for the current
    model shape.

2.  *Resolving the variant implementation*. If `@recalibrate_spec` is
    non-`NULL`, the variant name is looked up first in
    `def@impl$variants` (built-in variants), then in the session-scoped
    `variant_registry` (variants added via
    [`add_variant()`](https://s7-stats.github.io/statim/dev/reference/add-variant.md)).
    If both are empty and no
    [`via()`](https://s7-stats.github.io/statim/dev/reference/via.md)
    was called, `def@impl$base` is used.

3.  *Merge arguments*. The base arguments from the spec are merged with
    any arguments supplied to
    [`via()`](https://s7-stats.github.io/statim/dev/reference/via.md),
    with the
    [`via()`](https://s7-stats.github.io/statim/dev/reference/via.md)
    arguments taking precedence:

``` r

all_args = utils::modifyList(spec@args, recalibrate_spec$args %||% list())
```

On the test side, if a
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md)
claim was present, the `claim_translator` on the matching `stat_define`
is also consulted here, turning the parsed hypothesis into named
arguments injected alongside `.proc`.

4.  *Run the implementation*. `inject_and_run()` resolves each formal of
    `fn` in order: `.proc` is always the processed model output; every
    other formal is taken from `all_args` if present, or from the
    formal’s declared default otherwise. A formal with neither a
    supplied value nor a default is a hard error.

The return value of `fn` is wrapped in a `cld_exec` S7 object:

``` r
cld_exec(
    data = <raw return value of fn>,
    impl_cls = <string identifying the stat and model shape>,
    cld_meta = list(
        model_id = ...,
        processed = ...,
        stat_name = ...,
        method = <variant name, or "default">,
        data_name = ...
    )
)
```

#### Examples

``` r

sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(T_TEST) |>
    conclude()
```

``` fansi
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
```

``` r

mtcars |>
    define_model(mpg ~ wt) |>
    prepare_model(LINEAR_REG) |>
    conclude()
```

``` fansi
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : formula 
#> Args : mpg ~ wt 
#>     left_var : 1 
#>     right_var : 1 
#> 
#> == Linear Regression =========================================================== 
#> 
#> -- Coefficients ----------------------------------------------------------------
#> 
#> ──────────────┬───────────────────────────────────────────
#>   term        │  estimate  std_error  statistic  p_value  
#> ──────────────┼───────────────────────────────────────────
#>   (Intercept) │   37.285     1.878     19.858    <0.001   
#>   wt          │   -5.344     0.559     -9.559    <0.001   
#> ──────────────┴───────────────────────────────────────────
#> 
#> 
#> -- Model Fit -------------------------------------------------------------------
```

    #> Warning in system("tput cols", intern = TRUE): running command 'tput cols' had
    #> status 2
    #> ------------------------------------------------------
    #>   R Squared      :    0.75    F-statistic :    91.38
    #>   Adj. R Squared :    0.74    df1         :        1
    #>   Sigma          :    3.05    df2         :       30
    #>   n              :      32    p-value     :   <0.001
    #>   df (residual)  :      30                :         
    #> ------------------------------------------------------

With a [`via()`](https://s7-stats.github.io/statim/dev/reference/via.md)
recalibration, the output reflects the chosen variant:

``` r

sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(T_TEST) |>
    via("permute", n = 999L) |>
    conclude()
```

``` fansi
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
#>    -1.580     0.102     999    
#> ───────────────────────────────
```

### Retrieval of outputs

#### `tidy()`

[`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md)
dispatches on `cld_exec`. It tries two paths in order:

1.  **[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md)
    (optional but preferred)**. When `cld_exec@data` is a
    `<class_stat_infer>` subclass,
    [`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md)
    is called on it directly. S7’s method dispatch handles
    variant-specific overrides: a variant that returns the same class as
    `base` inherits the
    [`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md)
    method for free.

2.  **[`making_tidy()`](https://s7-stats.github.io/statim/dev/reference/making_tidy.md)
    registry (escape hatch)**. When `@data` is not a
    `<class_stat_infer>` subclass (a plain list, an S3 object, etc.),
    [`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md)
    consults the registry populated by
    [`making_tidy()`](https://s7-stats.github.io/statim/dev/reference/making_tidy.md)
    and
    [`method_tidy()`](https://s7-stats.github.io/statim/dev/reference/method_tidy.md).
    This path is only needed for variants that intentionally return a
    non-standard structure.

In both cases the return value must be a tibble (in `tbl_df` S3 class).
An informative error is raised if no method is found.

``` r

mtcars |>
    define_model(mpg ~ wt) |>
    prepare_model(LINEAR_REG) |>
    conclude() |>
    tidy()
```

``` fansi
#> # A tibble: 2 × 5
#>   term        estimate std_error statistic  p_value
#>   <chr>          <dbl>     <dbl>     <dbl>    <dbl>
#> 1 (Intercept)    37.3      1.88      19.9  8.24e-19
#> 2 wt             -5.34     0.559     -9.56 1.29e-10
```

#### `display()`

[`display()`](https://s7-stats.github.io/statim/dev/reference/display.md)
on a `<multi_exec>` prints up to `n` individual model outputs from a
[`write_models()`](https://s7-stats.github.io/statim/dev/reference/write_models.md)
pipeline:

``` r

LifeCycleSavings |>
    write_models(
        f1 = sr ~ 1,
        f2 = sr ~ pop15,
        f3 = sr ~ pop15 + pop75
    ) |>
    prepare_model(LINEAR_REG) |>
    conclude() |>
    display(2)
```

``` fansi
#> 
#> 1. f1
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : formula 
#> Args : sr ~ 1 
#>     left_var : 1 
#>     right_var : 0 
#> 
#> == Linear Regression =========================================================== 
#> 
#> -- Coefficients ----------------------------------------------------------------
#> 
#> ──────────────┬───────────────────────────────────────────
#>   term        │  estimate  std_error  statistic  p_value  
#> ──────────────┼───────────────────────────────────────────
#>   (Intercept) │   9.671      0.634     15.263    <0.001   
#> ──────────────┴───────────────────────────────────────────
#> 
#> 
#> -- Model Fit -------------------------------------------------------------------
```

    #> Warning in system("tput cols", intern = TRUE): running command 'tput cols' had
    #> status 2

``` fansi
#> -----------------------------------------------------
#>   R Squared      :    0.00    F-statistic :     NaN
#>   Adj. R Squared :    0.00    df1         :       0
#>   Sigma          :    4.48    df2         :      49
#>   n              :      50    p-value     :     NaN
#>   df (residual)  :      49                :        
#> -----------------------------------------------------
#> 
#> 
#> 
#> 2. f2
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : formula 
#> Args : sr ~ pop15 
#>     left_var : 1 
#>     right_var : 1 
#> 
#> == Linear Regression =========================================================== 
#> 
#> -- Coefficients ----------------------------------------------------------------
#> 
#> ──────────────┬───────────────────────────────────────────
#>   term        │  estimate  std_error  statistic  p_value  
#> ──────────────┼───────────────────────────────────────────
#>   (Intercept) │   17.497     2.280      7.675    <0.001   
#>   pop15       │   -0.223     0.063     -3.545    <0.001   
#> ──────────────┴───────────────────────────────────────────
#> 
#> 
#> -- Model Fit -------------------------------------------------------------------
```

    #> Warning in system("tput cols", intern = TRUE): running command 'tput cols' had
    #> status 2
    #> ------------------------------------------------------
    #>   R Squared      :    0.21    F-statistic :    12.57
    #>   Adj. R Squared :    0.19    df1         :        1
    #>   Sigma          :    4.03    df2         :       48
    #>   n              :      50    p-value     :   <0.001
    #>   df (residual)  :      48                :         
    #> ------------------------------------------------------

#### `anova()`

[`anova()`](https://s7-stats.github.io/statim/dev/reference/anova-mod.md)
is a separate generic that operates on model outputs rather than on
`cld_exec` directly. It dispatches on `<model_lazy>`, `<cld_exec>`,
`<multi_lazy>`, and `<anova_lazy>`, and always returns a `<cld_anova>`.
See the [ANOVA for Linear
Models](https://s7-stats.github.io/statim/dev/articles/usage/anova-mod.md)
article for the full walkthrough.

## Multiple executions

[`write_models()`](https://s7-stats.github.io/statim/dev/reference/write_models.md)
is the entry point for running the same stat or model across several
specifications in one pipeline. It sits where
[`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md)
sits, producing an `<expanded_model>` instead of a `<def_var>`, and the
rest of the pipeline follows the same three-verb shape with batch-aware
classes at each stage.

### `write_models()` builds an `expanded_model`

[`write_models()`](https://s7-stats.github.io/statim/dev/reference/write_models.md)
is an S7 generic dispatched on `.data`. Each named argument is a
quosure, evaluated in order against a data mask seeded from `.data`.
Because each result is written into the mask under its own name as soon
as it’s evaluated, later expressions can build on earlier ones with
[`stats::update()`](https://rdrr.io/r/stats/update.html):

``` r

LifeCycleSavings |>
    write_models(
        f1 = sr ~ 1,
        f2 = update(f1, ~. + pop15),
        f3 = update(f2, ~. + pop75)
    )
#> 
#> -- Models ---------------------------------------------------------------------- 
#> 
#>   f1 : sr ~ 1
#>   f2 : sr ~ pop15
#>   f3 : sr ~ pop15 + pop75
```

Each resolved expression is a `var_id` (a formula, or the result of
[`rel()`](https://s7-stats.github.io/statim/dev/reference/rel.md),
[`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md), or
any registered `var_id` constructor).
[`write_models()`](https://s7-stats.github.io/statim/dev/reference/write_models.md)
runs it through
[`model_processor()`](https://s7-stats.github.io/statim/dev/reference/model-processor.md)
against `.data` and stores it as a `<def_var>` — the same object
[`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md)
produces for a single model:

``` r
expanded_model(
    models = <named list of def_var>,
    labels = <names(...)>
)
```

Nothing has been fit yet.

### Attaching a spec: `<multi_lazy>`

[`prepare_model()`](https://s7-stats.github.io/statim/dev/reference/prepare-model.md),
[`prepare_test()`](https://s7-stats.github.io/statim/dev/reference/prepare-test.md),
and
[`prepare()`](https://s7-stats.github.io/statim/dev/reference/prepare.md)
each have a method for `list(expanded_model, S7::class_function)`. The
spec is built once — via `as_model_spec()`, `as_test_spec()`, or by
calling `.fn(.var_id = NULL)` — then applied to every `def_var` in
`@models`, producing one `model_lazy` or `test_lazy` per model:

``` r

LifeCycleSavings |>
    write_models(
        f1 = sr ~ 1,
        f2 = sr ~ pop15,
        f3 = sr ~ pop15 + pop75
    ) |>
    prepare_model(LINEAR_REG)
#> 
#> -- Models ---------------------------------------------------------------------- 
#> 
#>   f1 : sr ~ 1
#>   f2 : sr ~ pop15
#>   f3 : sr ~ pop15 + pop75
```

The result is a `<multi_lazy>`, carrying `@models` (the list of lazy
objects), `@labels`, and `@args` (empty until
[`update()`](https://rdrr.io/r/stats/update.html) is used).

### `via()` and `update()` on `multi_lazy`

[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md) has a
method for `list(multi_lazy, S7::class_character)` that maps the
single-model
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md) over
every element of `@models`, so one call recalibrates the whole batch
with the same variant and arguments:

``` r

mtcars |>
    write_models(
        by_am = x_by(mpg, am),
        by_vs = x_by(mpg, vs)
    ) |>
    prepare_test(T_TEST) |>
    via("permute", n = 999L)
#> 
#> -- Models ---------------------------------------------------------------------- 
#> 
#>   by_am : mpg | am
#>   by_vs : mpg | vs
```

[`update()`](https://rdrr.io/r/stats/update.html) is for adjusting
arguments after the fact rather than swapping variants. For each model
it merges its `...` into whichever argument list is currently active —
`@recalibrate_spec$args` if
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md) has
been called, `@model_spec@args` otherwise:

``` r

m@recalibrate_spec$args = utils::modifyList(m@recalibrate_spec$args, dots)
# or, when no via() was called:
m@model_spec@args = utils::modifyList(m@model_spec@args, dots)
```

Only the named arguments supplied to
[`update()`](https://rdrr.io/r/stats/update.html) are overwritten;
everything else is left as-is.

### `conclude()` produces `<multi_exec>`

[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
on `<multi_lazy>` runs the ordinary single-model
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
over each element of `@models` and names the results by `@labels`:

``` r

LifeCycleSavings |>
    write_models(
        f1 = sr ~ 1,
        f2 = sr ~ pop15,
        f3 = sr ~ pop15 + pop75
    ) |>
    prepare_model(LINEAR_REG) |>
    conclude()
```

``` fansi
#> 
#> ── 3 models · Linear Regression ──────────────────────────────────────────────── 
#> 
#> f1 : <cld_exec>
#> f2 : <cld_exec>
#> f3 : <cld_exec>
#> 
#> Use display() to inspect individual results.
```

The resulting `<multi_exec>` stores `@results` (a named list of
`cld_exec`), `@labels`, and `@stat_name` (read off the first result’s
`cld_meta`, for display purposes only).

### `tidy()` on `<multi_exec>`

[`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md) on
`<multi_exec>` maps the ordinary
[`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md) over
`@results` and returns one row per model, with an `outs` list-column
holding each model’s own tidy tibble:

``` r

LifeCycleSavings |>
    write_models(
        f1 = sr ~ 1,
        f2 = sr ~ pop15,
        f3 = sr ~ pop15 + pop75
    ) |>
    prepare_model(LINEAR_REG) |>
    conclude() |>
    tidy()
```

``` fansi
#> # A tibble: 3 × 2
#>   model outs            
#>   <chr> <named list>    
#> 1 f1    <tibble [1 × 5]>
#> 2 f2    <tibble [2 × 5]>
#> 3 f3    <tibble [3 × 5]>
```

[`display()`](https://s7-stats.github.io/statim/dev/reference/display.md),
covered above under [Retrieval of outputs](#retrieve-output), and
[`anova()`](https://s7-stats.github.io/statim/dev/reference/anova-mod.md)
are the other two ways to pull information back out of a `<multi_exec>`
/ `<multi_lazy>`.

## Eager path vs lazy path

There is also an eager path: calling `T_TEST(x_by(extra, group), sleep)`
or `LINEAR_REG(mpg ~ wt, mtcars)` directly skips
[`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md),
`prepare_*()`, and
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md)
entirely. Internally, `run_stat()` calls `find_def()` and
`inject_and_run()` directly against `base`; only the base implementation
is reachable this way. Variants registered via
[`add_variant()`](https://s7-stats.github.io/statim/dev/reference/add-variant.md)
or selected via
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md) are
not accessible on the eager path.

The eager path returns a `cld_exec` with the same slot structure as the
lazy path, but the class hierarchy it belongs to is identical. This
means
[`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md) and
[`print()`](https://rdrr.io/r/base/print.html) work identically on both
outputs.

## The `<class_stat_infer>` contract

`fn` can return anything, but returning a `<class_stat_infer>` subclass
unlocks automatic dispatch for both
[`print()`](https://rdrr.io/r/base/print.html) and
[`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md). The
current hierarchy is:

    class_stat_infer
        ├── anova_able
        │       └── class_lm_object       (LINEAR_REG)
        │       └── class_glm_object      (GLM)
        ├── class_ttest_two               (T_TEST · x_by)
        ├── class_ttest_pairwise          (T_TEST · pairwise)
        ├── class_corr_two                (COR_TEST · rel)
        └── class_p_test                  (P_TEST)

A variant that reuses its def’s existing result class inherits both
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md)
and [`print()`](https://rdrr.io/r/base/print.html) automatically. A
variant that needs a genuinely different output shape can opt out by
returning a plain structure and supplying a `print` function directly to
[`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md).
