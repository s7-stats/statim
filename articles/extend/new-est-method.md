# Writing new estimation method for inferential statistics

## Rationale

[statim](https://github.com/s7-stats/statim) is designed so that writing
a new estimation method never means forking the function the user calls.
[`TTEST()`](https://s7-stats.github.io/statim/reference/TTEST.md),
[`P_TEST()`](https://s7-stats.github.io/statim/reference/P_TEST.md),
[`LINEAR_REG()`](https://s7-stats.github.io/statim/reference/LINEAR_REG.md),
every one of them is built from the same primitives: a `stat_define` per
supported model shape, an
[`agendas()`](https://s7-stats.github.io/statim/reference/agendas.md) of
[`baseline()`](https://s7-stats.github.io/statim/reference/baseline.md)
plus named
[`variant()`](https://s7-stats.github.io/statim/reference/variant.md)
implementations inside it, and a shared dispatcher
([`STAT_CONSTRUCTOR()`](https://s7-stats.github.io/statim/reference/STAT_CONSTRUCTOR.md),
[`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md))
that neither knows nor cares what the implementation actually computes.

Whether you’re adding a robust-regression option to
[`LINEAR_REG()`](https://s7-stats.github.io/statim/reference/LINEAR_REG.md)
or a trimmed-mean option to
[`TTEST()`](https://s7-stats.github.io/statim/reference/TTEST.md), the
mechanism is identical, because a model-based inference function and a
hypothesis-test function are the same kind of object underneath —
[`MODEL_FN()`](https://s7-stats.github.io/statim/reference/MODEL_FN.md)
and
[`HTEST_FN()`](https://s7-stats.github.io/statim/reference/HTEST_FN.md)
are both thin wrappers around
[`STAT_CONSTRUCTOR()`](https://s7-stats.github.io/statim/reference/STAT_CONSTRUCTOR.md).
This vignette covers that mechanism. For the full anatomy of
`model_type`, `impl`, `compatible_params`, and `claim_translator`, see
the [`stat_define`
objects](https://s7-stats.github.io/statim/articles/pointers/stat_define.md)
article. This one assumes that vocabulary and focuses on extending it.

## Two ways to add a new estimation method

There are two genuinely different things “adding a new estimation
method” can mean, and they have different reach.

1.  When you want to add another variant to a model shape that’s already
    supported. Let’s say adding a variant to a model shape
    [`TTEST()`](https://s7-stats.github.io/statim/reference/TTEST.md)
    already supports — a trimmed-mean test for
    [`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md),
    say. This is the public, documented surface:
    [`add_variant()`](https://s7-stats.github.io/statim/reference/add-variant.md),
    no access to internals required. The rest of this vignette covers
    it.

2.  Add another but independent support for a model shape that doesn’t
    exist yet. This needs a new stat_define registered from outside the
    package, which isn’t public yet. `defs` is closed over inside
    [`STAT_CONSTRUCTOR()`](https://s7-stats.github.io/statim/reference/STAT_CONSTRUCTOR.md)
    with no exported mutator, and the registration mechanism is still
    being designed (collision handling and snapshot staleness are open
    questions). Until it ships, this means contributing upstream or
    building your own
    [`STAT_CONSTRUCTOR()`](https://s7-stats.github.io/statim/reference/STAT_CONSTRUCTOR.md)-based
    function.

## The shared contract: what every `fn` must honor

Regardless of which function you’re extending,
[`baseline()`](https://s7-stats.github.io/statim/reference/baseline.md)
and
[`variant()`](https://s7-stats.github.io/statim/reference/variant.md)
enforce one rule at construction time: `fn`’s first formal argument must
literally be named `.proc`.

``` r

variant(
    fn = function(data, n = 1000L) NULL
)
#> Error in `variant()`:
#> ! `fn` must have `.proc` as its first argument.
#> ℹ Found `data` instead.
#> ℹ See `baseline()` for the expected signature.
```

This is a guardrail you already wrote into the framework, and it’s worth
trusting it rather than working around it — every implementation,
test-side or model-side, receives the same processed model output as its
first argument, and the dispatcher (`inject_and_run()`) depends on that
position being `.proc` to inject it correctly.

Past `.proc`, `fn` is an ordinary function with named arguments and
defaults. What you return matters more than how you compute it: return a
[`class_stat_infer`](https://s7-stats.github.io/statim/reference/class_stat_infer.md)
subclass and
[`tidy()`](https://s7-stats.github.io/statim/reference/tidy.md) /
[`print()`](https://rdrr.io/r/base/print.html) are handled for you
automatically, provided the subclass already has methods registered
(either because you reused an existing result class, or because you
wrote
[`auto_tidy()`](https://s7-stats.github.io/statim/reference/auto_tidy.md)
for a new one). Return anything else — a plain list, a `boot.ci` object
— and supply a `print` function directly to
[`baseline()`](https://s7-stats.github.io/statim/reference/baseline.md)/[`variant()`](https://s7-stats.github.io/statim/reference/variant.md)
instead.

## Worked example: adding a variant to a model function

[`LINEAR_REG()`](https://s7-stats.github.io/statim/reference/LINEAR_REG.md)’s
formula implementation calls
[`stats::lm()`](https://rdrr.io/r/stats/lm.html) with no weights.
Suppose you want a weighted-least-squares variant. It reuses the
package’s own `lm_to_lm_object()` helper, so it inherits the same
[`print()`](https://rdrr.io/r/base/print.html), `coefficients`, and
[`anova()`](https://s7-stats.github.io/statim/reference/anova-mod.md)
support as the default:

``` r

add_variant(LINEAR_REG, S7::class_formula, "weighted") %<-% variant(
    fn = function(.proc, weights = NULL) {
        fit = do.call(
            stats::lm,
            list(formula = .proc$formula, data = .proc$data, weights = weights)
        )
        coef_tbl = summary(fit)$coefficients
        rss = sum(fit$residuals^2)
        df_res = fit$df.residual
        
        class_lm_object(
            terms = fit$terms,
            fitted = unname(fit$fitted.values),
            residuals = unname(fit$residuals),
            beta = coef_tbl[, 1],
            std_beta = coef_tbl[, 2],
            df_residual = df_res,
            deviance = rss,
            dispersion = rss / df_res,
            family = "gaussian",
            x_mat = as.numeric(stats::model.matrix(fit))
        )
    }
)
```

Let’s try with a simple example:

``` r

cars |>
    define_model(dist ~ speed) |>
    prepare_model(LINEAR_REG) |>
    via("weighted", weights = 1 / cars$speed) |>
    conclude()
```


    == Model ======================================================================= 

    Model ID : formula 
    Args : dist ~ speed 
        left_var : 1 
        right_var : 1 

    == Linear Regression · weighted ================================================ 

    -- Coefficients ----------------------------------------------------------------

    ──────────────┬───────────────────────────────────────────
      term        │  estimate  std_error  statistic  p_value  
    ──────────────┼───────────────────────────────────────────
      (Intercept) │  -12.967     4.879     -2.658     [31m 0.011 [39m   
      speed       │   3.633      0.345     10.521     [1m<0.001 [22m   
    ──────────────┴───────────────────────────────────────────


    -- Model Fit -------------------------------------------------------------------

    Warning in system("tput cols", intern = TRUE): running command 'tput cols' had
    status 2

    ------------------------------------------------------
      R Squared      :    0.65    F-statistic :    88.09
      Adj. R Squared :    0.64    df1         :        1
      Sigma          :   15.46    df2         :       48
      n              :      50    p-value     :   <0.001
      df (residual)  :      48                :         
    ------------------------------------------------------

Nothing here differs structurally from extending a test function. The
left-hand side of `%<-%` names the function being extended
(`LINEAR_REG`), the model shape it applies to
([`S7::class_formula`](https://rconsortium.github.io/S7/reference/base_s3_classes.html)),
and the variant’s name (`"weighted"`); the right-hand side is an
ordinary
[`variant()`](https://s7-stats.github.io/statim/reference/variant.md)
object. `%<-%` dispatches on the class of its left-hand side — here
`add_variant_call` — to `add_variant_register()`, which validates
`model_type` and registers the variant under a key built from `cls`
(read off `LINEAR_REG` via its `"cls"` attribute) and the model type’s
name.

## Worked example: adding a variant to a test function

The canonical example in
[`?add_variant`](https://s7-stats.github.io/statim/reference/add-variant.md)
does exactly the same thing for `TTEST` and
[`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md):

``` r

add_variant(TTEST, x_by, "another_boot") %<-% 
    variant(
        fn = function(.proc, .n = 1000L) {
            x = .proc$x_data[[1]]
            grp = as.character(.proc$group_data[[1]])
            lvls = unique(grp)
            x1 = x[grp == lvls[[1]]]
            x2 = x[grp == lvls[[2]]]
            boot_fn = function(d, i) mean(d[i, 1]) - mean(d[i, 2])
            b = boot::boot(data.frame(x1, x2), boot_fn, R = .n)
            boot::boot.ci(b, type = "perc")
        }
    )
```

Same two calls, same `%<-%`, same registration path — only the function,
model type, and `fn` body changed. That sameness is the point: once
you’ve extended one
[`STAT_CONSTRUCTOR()`](https://s7-stats.github.io/statim/reference/STAT_CONSTRUCTOR.md)-built
function, you already know how to extend all of them.

## How arguments actually reach your `fn`

Technically speaking, `via("weighted", weights = ...)` doesn’t call your
`fn` directly, it passes through the internal function called
`inject_and_run()`, which resolves each of `fn`’s formals one at a time.
`.proc` is always injected from the processed model output. Every other
formal is taken from the supplied arguments if present; otherwise its
declared default is used, evaluated in `fn`’s own environment if the
default is an expression rather than a literal. A formal with no default
and no supplied value is a hard error, listing every missing argument in
one message rather than failing on the first:

``` r

variant(
    fn = function(.proc, weights) {
        # `weights` has no default 
        # calling via("weighted") with nothing
        # supplied for it aborts with "1 required argument not supplied: weights"
    }
)
```

Arguments supplied to
[`via()`](https://s7-stats.github.io/statim/reference/via.md) that don’t
match any formal in `fn`, and that `fn` has no `...` to absorb, are also
a hard error rather than being silently dropped —
`via("weighted", wieghts = ...)` (note the typo) fails loudly instead of
quietly running unweighted.

## Session-scoped vs package-scoped extensions

[`add_variant()`](https://s7-stats.github.io/statim/reference/add-variant.md)’s
`origin` argument decides how long the registration lives.
`origin = "user"` (the default) is for interactive iteration. Register
it, try it,
[`remove_variant()`](https://s7-stats.github.io/statim/reference/add-variant.md)
it if it’s wrong, all within one session. On the other hand,
`origin = "package"` is for an extension package’s `.onLoad()`,
registering a variant that exists for as long as that package is loaded
and disappears when it’s detached. This is the right choice if the soon
to be created packages: `{nullis7}` and `{category7}`, ship a new
estimation method as part of their own installation rather than asking
the user to register it by hand every session.

`"default"` is frozen in both modes — it always means `base`, and
neither
[`add_variant()`](https://s7-stats.github.io/statim/reference/add-variant.md)
nor
[`remove_variant()`](https://s7-stats.github.io/statim/reference/add-variant.md)
will touch it.
[`remove_variant()`](https://s7-stats.github.io/statim/reference/add-variant.md)
is similarly restricted in the other direction: it only removes
`"user"`-origin entries, refusing to let a session manually tear down
something a package registered on load.

## Stress-testing your new method before you ship it

A few things worth checking deliberately rather than assuming, before
considering a new variant finished.

1.  Confirm it’s actually reached by calling it through
    `... |> via("yourname", ...)` and checking the output differs from
    `base` . A model-type or name mismatch between
    [`add_variant()`](https://s7-stats.github.io/statim/reference/add-variant.md)
    and your
    [`via()`](https://s7-stats.github.io/statim/reference/via.md) call
    resolves silently to `base` in the current
    [`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md)
    implementation rather than throwing an error, so a passing test that
    secretly ran `base` the whole time is a real failure mode, not a
    hypothetical one.

2.  Remember *variants* are locked for grammar/piped syntax only: there
    is no way that the “eager form” call for a variant, so
    `LINEAR_REG(rel(x, y), data)` directly will never reach anything you
    registered via
    [`add_variant()`](https://s7-stats.github.io/statim/reference/add-variant.md),
    only `... |> prepare_model(LINEAR_REG) |> via(...)` type of call
    can.

3.  If `fn` returns an existing `<class_stat_infer>` class, verify
    [`tidy()`](https://s7-stats.github.io/statim/reference/tidy.md) and
    [`print()`](https://rdrr.io/r/base/print.html) actually produce
    sensible output for your variant’s specific output shape —
    inheriting a method is not the same as that method being *correct*
    for what you return, particularly for confidence intervals or
    degrees of freedom that your method computes differently from
    `base`.

4.  Finally, if you’re registering at `origin = "package"`, test the
    unload path too — calling
    [`detach()`](https://rdrr.io/r/base/detach.html) to detach the
    registering package and confirming the variant is genuinely gone,
    not just inaccessible by name, is the difference between
    “self-cleaning” and “looks clean until someone reloads in the same
    session.”
