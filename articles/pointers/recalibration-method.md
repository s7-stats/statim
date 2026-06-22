# via(): Switching to different mode

## Rationale

One estimation method, in a form of `<STAT_FN>` under
[`STAT_CONSTRUCTOR()`](https://s7-stats.github.io/statim/reference/STAT_CONSTRUCTOR.md)
functions, have varieties of methods you can use for estimation in
statistical inference. The accessibility is simple: just a one line of
code under lazy-loaded objects using
[`via()`](https://s7-stats.github.io/statim/reference/via.md).

For instance, a classical t-test, a bootstrap t-test, and a permutation
t-test answer the same question: “Is there a difference between these
two groups?”, but they get there through different estimation machinery.
Without [`via()`](https://s7-stats.github.io/statim/reference/via.md),
switching between them would normally mean reaching for a different
function entirely, or threading a string flag through `...` and hoping
the implementation underneath understands it.
[statim](https://github.com/s7-stats/statim) instead treats the
estimation method as something you are *switching the mode* within the
lazy-loaded pipeline, while the model definition, the data, and (if
present) the hypothesis claim stay untouched.

## How `via()` fits in the pipeline

[`via()`](https://s7-stats.github.io/statim/reference/via.md) only
operates on lazy objects — a `test_lazy` produced by
[`prepare_test()`](https://s7-stats.github.io/statim/reference/prepare-test.md),
or a `model_lazy` produced by
[`prepare_model()`](https://s7-stats.github.io/statim/reference/prepare-model.md).
It cannot be used after
[`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md),
since by then the pipeline has already executed and the result is no
longer lazy.

``` r

sleep |>
    define_model(extra %by% group) |>
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
#> Warning in system("tput cols", intern = TRUE): running command 'tput cols' had
#> status 2
#> ------------------------------
#>   CI     :   [-3.21, 0.0702]
#>   n_reps :              2000
#> ------------------------------
```

[`via()`](https://s7-stats.github.io/statim/reference/via.md) itself
does not run anything. It records two things on the lazy object’s
`recalibrate_spec`: the method name (`.method`) and any extra named
arguments (`...`). The actual dispatch (i.e. finding the matching
implementation and running it) only happens once
[`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md)
is called. This is the same “defused until executed” behavior the rest
of the grammar follows:
[`define_model()`](https://s7-stats.github.io/statim/reference/layout-define-base.md),
[`prepare_test()`](https://s7-stats.github.io/statim/reference/prepare-test.md)
/
[`prepare_model()`](https://s7-stats.github.io/statim/reference/prepare-model.md),
[`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md),
and [`via()`](https://s7-stats.github.io/statim/reference/via.md) all
just accumulate specification, and
[`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md)
is the single point where everything is resolved together.

## Where variant names come from

A variant name like `"boot"` or `"permute"` from
[`TTEST()`](https://s7-stats.github.io/statim/reference/TTEST.md) in
`x_by` mode is not arbitrary. It has to match a name registered for that
specific model type, inside the
[`agendas()`](https://s7-stats.github.io/statim/reference/agendas.md)
object passed to
[`stat_define()`](https://s7-stats.github.io/statim/reference/stat-infer-definer.md)
when the test or model was built. Two sources are checked:

1.  The variants declared directly inside the matched
    [`stat_define()`](https://s7-stats.github.io/statim/reference/stat-infer-definer.md)’s
    [`agendas()`](https://s7-stats.github.io/statim/reference/agendas.md),
    alongside its
    [`baseline()`](https://s7-stats.github.io/statim/reference/baseline.md).
    This is how `TTEST` ships with `"boot"`, `"permute"`, `"contrast"`,
    and `"multi"` for
    [`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md)
    pipelines, for example.

2.  Any variants registered afterwards via
    [`add_variant()`](https://s7-stats.github.io/statim/reference/add-variant.md).
    This is a developer-facing function, paired with the `%<-%`
    operator, and is meant for extending an existing `<STAT_FN>` (built
    with
    [`HTEST_FN()`](https://s7-stats.github.io/statim/reference/HTEST_FN.md)
    or
    [`MODEL_FN()`](https://s7-stats.github.io/statim/reference/MODEL_FN.md))
    without touching its original definition:

    ``` r
    add_variant(<STAT_FN>, <var_id>, "<new_mode>") %<-% variant(
        fn = function(.proc, arg1 = , arg2 = , ...) {
            # ...
        }
    )
    ```

    Variants added this way carry an `origin`: `"user"` (the default) is
    scoped to the current session and can be removed with
    [`remove_variant()`](https://s7-stats.github.io/statim/reference/add-variant.md),
    while `"package"` is meant to be registered from a package’s
    `.onLoad()` and lasts as long as that package stays loaded. Either
    way, the name `"default"` is frozen and cannot be added or removed
    through
    [`add_variant()`](https://s7-stats.github.io/statim/reference/add-variant.md)
    /
    [`remove_variant()`](https://s7-stats.github.io/statim/reference/add-variant.md).

Because matching is scoped to model type, the same variant name can mean
different things (or simply do not exist) depending on which `<var_id>`
you used in
[`define_model()`](https://s7-stats.github.io/statim/reference/layout-define-base.md).
A variant registered for
[`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md)
pipelines is not automatically available to a `<formula>`-based pipeline
of the same test, even if both eventually call `TTEST`.

If you pass a method name that is not registered for the model type in
play, [`via()`](https://s7-stats.github.io/statim/reference/via.md)
fails immediately, before
[`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md)
is even reached:

``` r

sleep |>
    define_model(extra %by% group) |>
    prepare_test(TTEST) |>
    via("not_a_real_method")
#> Error in `method(via, list(statim::test_lazy, class_character))`:
#> ! No variant "not_a_real_method" registered for model type "x_by".
#> ℹ Available variants: "contrast", "multi", "boot", and "permute".
```

The error message lists every variant available for that exact model
type, so you can fix the call without digging through documentation.

## Argument merging

Any named arguments supplied to
[`via()`](https://s7-stats.github.io/statim/reference/via.md) are not a
replacement for the arguments already set in
[`prepare_test()`](https://s7-stats.github.io/statim/reference/prepare-test.md)
/
[`prepare_model()`](https://s7-stats.github.io/statim/reference/prepare-model.md)
– they are merged on top of them. Concretely,
[`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md)
combines the two argument lists with
[`utils::modifyList()`](https://rdrr.io/r/utils/modifyList.html), where
the names from
[`via()`](https://s7-stats.github.io/statim/reference/via.md) win on
overlap:

``` r

sleep |>
    define_model(extra %by% group) |>
    prepare_test(TTEST) |>
    update(.ci = 0.9) |>
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
#> Warning in system("tput cols", intern = TRUE): running command 'tput cols' had
#> status 2
#> -----------------------------
#>   CI     :   [-2.94, -0.29]
#>   n_reps :             2000
#> -----------------------------
```

Here, `.ci = 0.9` came from
[`update()`](https://rdrr.io/r/stats/update.html) on the baseline
specification, and `n = 2000` came from
[`via()`](https://s7-stats.github.io/statim/reference/via.md). Both
reach the `"boot"` implementation’s `fn`, because neither name collides
with the other. If
[`via()`](https://s7-stats.github.io/statim/reference/via.md) had also
supplied `.ci`, that value would have taken precedence over the one set
earlier in the pipeline.

This merging behavior is also why
[`via()`](https://s7-stats.github.io/statim/reference/via.md) does not
require you to repeat arguments the variant shares with the baseline.
Only supply what differs for that particular variant; anything else
falls through from what was already specified, or from the variant’s own
declared defaults in its `fn` signature.

## Recalibration and hypothesis claims

If a hypothesis was attached with
[`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md),
recalibrating the method does not invalidate it, as long as the variant
you switch to actually declares a `claim_parser` of its own.
`claim_parser` is an argument to
[`baseline()`](https://s7-stats.github.io/statim/reference/baseline.md)
and to each
[`variant()`](https://s7-stats.github.io/statim/reference/variant.md)
individually — a
[`map_claim()`](https://s7-stats.github.io/statim/reference/map_claim.md)
object that knows how to turn a stated claim into the arguments that one
`fn` expects, since different estimation methods can require the same
population-parameter claim expressed differently. `TTEST`’s
[`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md)
implementation, for instance, gives a `claim_parser` to its `base` and
to `"contrast"`, but not to the resampling-based `"boot"` or `"permute"`
variants, since those do not take a hypothesized value as an argument in
the first place.

``` r

sleep |>
    define_model(extra %by% group) |>
    prepare_test(TTEST) |>
    state_null(
        2 * MU(extra, group == "1") - MU(extra, group == "2") <= 0
    ) |>
    via("contrast") |>
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
#>   group  lower_95  upper_95  
#> ─────────────────────────────
#>   group   -3.112     Inf     
#> ─────────────────────────────
```

At
[`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md),
the `"contrast"` variant’s own `claim_parser` runs against the stated
claim, and its output (in this case, `.mu`, `.op`, and `.w`) is merged
into the argument list the same way the rest of
[`via()`](https://s7-stats.github.io/statim/reference/via.md)’s
arguments are. If the variant you switched to has no `claim_parser`,
[`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md)
reports that explicitly rather than silently ignoring the claim:

``` r

sleep |>
    define_model(extra %by% group) |>
    prepare_test(TTEST) |>
    state_null(MU(extra, group == "1") == MU(extra, group == "2")) |>
    via("permute", n = 999L) |>
    conclude()
#> Error in `method(conclude, statim::test_lazy)`:
#> ! No claim parser defined for variant "permute".
#> ℹ Remove `state_null()` or use a supported variant.
```

Because `claim_parser` lives on the implementation itself rather than in
a separate lookup keyed by variant name, there’s nothing else to update
when you add a new variant via
[`add_variant()`](https://s7-stats.github.io/statim/reference/add-variant.md)
— give it a `claim_parser` if it should support
[`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md),
or leave the argument out if it shouldn’t. Either way
[`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md)
checks whichever `impl` it actually resolved, regardless of whether that
came from the original
[`agendas()`](https://s7-stats.github.io/statim/reference/agendas.md) or
from the runtime registry.

## TL;DR

- [`via()`](https://s7-stats.github.io/statim/reference/via.md) only
  works on lazy objects, before
  [`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md).
- It records a method name and extra arguments; nothing executes until
  [`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md).
- Variant names are scoped per model type, sourced from the matched
  [`stat_define()`](https://s7-stats.github.io/statim/reference/stat-infer-definer.md)’s
  [`agendas()`](https://s7-stats.github.io/statim/reference/agendas.md)
  and any variants registered afterwards via
  [`add_variant()`](https://s7-stats.github.io/statim/reference/add-variant.md).
- Arguments from
  [`via()`](https://s7-stats.github.io/statim/reference/via.md) are
  merged with, not substituted for, the arguments already declared
  earlier in the pipeline.
- A stated null hypothesis survives recalibration only if the new
  variant declares its own `claim_parser`; not every variant needs one.
