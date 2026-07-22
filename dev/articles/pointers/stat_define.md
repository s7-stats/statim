# stat_define objects

## What are objects?

`stat_define` is an S7 object used as a unit of registration that tells
a top-level function like
[`T_TEST()`](https://s7-stats.github.io/statim/dev/reference/T_TEST.md)
or
[`LINEAR_REG()`](https://s7-stats.github.io/statim/dev/reference/LINEAR_REG.md)
how to behave for one particular shape of model. “Shape of model” means
the variable mapper `<var_id>` under `<var_id>` class:
[`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md),
[`pairwise()`](https://s7-stats.github.io/statim/dev/reference/pairwise.md),
[`rel()`](https://s7-stats.github.io/statim/dev/reference/rel.md), a
`<formula>`, and so on. Each shape implies a different procedure, a
different set of arguments, and often a different result structure, even
though the user calls the same top-level function regardless of which
shape they pass in.

[`stat_define()`](https://s7-stats.github.io/statim/dev/reference/stat-infer-definer.md)
is exported under three names, and all three build the exact same S7
class:

``` r

stat_define         # the canonical name
test_define         # alias, conventionally used for HTEST_FN()-fed defs
model_infer_define  # alias, conventionally used for MODEL_FN()-fed defs
```

The alias is purely a readability convention, not a different type.
`ptest_def`, which feeds
[`P_TEST()`](https://s7-stats.github.io/statim/dev/reference/P_TEST.md),
is written with
[`test_define()`](https://s7-stats.github.io/statim/dev/reference/stat-infer-definer.md);
`linear_reg_def_rel`, which feeds
[`LINEAR_REG()`](https://s7-stats.github.io/statim/dev/reference/LINEAR_REG.md),
is written with
[`model_infer_define()`](https://s7-stats.github.io/statim/dev/reference/stat-infer-definer.md).
Both are `stat_define` objects with identical properties:

``` r
ptest_def = test_define(
    model_type = <var_id>,                 # Which is `prop`
    impl = agendas(
        base = baseline(fn = ..., claim_parser = map_claim(...)),
        ...
    ),
    compatible_params = list(<param_obj>)   # which is `PI`
)

linear_reg_def_rel = model_infer_define(
    model_type = <var_id>,                 # Which is `rel`
    impl = agendas(...),
    compatible_params = list()
)
```

A top-level function such as `T_TEST` or `LINEAR_REG` contains a list of
`stat_define`, one per supported model shape, passed in as `defs`:

``` r

T_TEST = HTEST_FN(
    cls = "ttest",
    defs = list(
        ttest_def_two, 
        ttest_def_formula, 
        ttest_def_pairwise,
        ...
    ),
    .name = "T-Test"
)

LINEAR_REG = MODEL_FN(
    cls = "linear_reg",
    defs = list(
        linear_reg_def_rel, 
        linear_reg_def_formula,
        ...
    ),
    .name = "Linear Regression"
)
```

When you call `T_TEST(x_by(extra, group), sleep)`, the dispatcher looks
at the class of the variable mapper `<var_id>` you passed, finds the
matching `stat_define` (i.e. `ttest_def_two` in this case), and runs
that implementation. The exact same lookup runs when you call
`LINEAR_REG(rel(mpg, wt), mtcars)`, only the exception that is the
registry being searched differs.

## Why are objects required?

The alternative to this registration pattern is a long `if`/`switch`
inside the body of every top-level function, each branch hand-rolling
its own argument handling and result wrapping. That breaks down fast:
not just because `T_TEST` alone has three model shapes, but because the
package has two whole families of top-level function — hypothesis tests
built with
[`HTEST_FN()`](https://s7-stats.github.io/statim/dev/reference/HTEST_FN.md)
and model-based inference built with
[`MODEL_FN()`](https://s7-stats.github.io/statim/dev/reference/MODEL_FN.md)
— and both need the same dispatch machinery underneath.

`stat_define` is what lets that machinery be written exactly once.
[`STAT_CONSTRUCTOR()`](https://s7-stats.github.io/statim/dev/reference/STAT_CONSTRUCTOR.md)
is the function both
[`HTEST_FN()`](https://s7-stats.github.io/statim/dev/reference/HTEST_FN.md)
and
[`MODEL_FN()`](https://s7-stats.github.io/statim/dev/reference/MODEL_FN.md)
delegate to; `build_lookup()`, `find_def()`, and
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
don’t know or care whether the `stat_define` list they’re searching came
from a test function or a model function. Adding a fourth model shape to
`T_TEST`, or a third model fit to `LINEAR_REG`, means writing one more
`stat_define` and adding it to that function’s `defs` — it never means
touching the dispatcher itself.

This is also why `compatible_params` lives on `stat_define` while
`claim_parser` lives one level down, on
[`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md)
and each
[`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md):
which parameter types a hypothesis may reference is a property of the
model shape as a whole, but how a claim gets turned into arguments is
specific to one implementation — different variants of the same model
shape can need the same claim expressed differently, or not support
claims at all (more on that below).

## Anatomy of a object

Each argument is explain by each section.

``` r
stat_define(
    model_type = <var_id>,
    impl = agendas(...),
    compatible_params = list(<param_obj>, ...)
)
```

1.  `model_type`

    The `<var_id>` class this implementation handles — `x_by`, `rel`,
    `pairwise`, `prop`, or
    [`S7::class_formula`](https://rconsortium.github.io/S7/reference/base_s3_classes.html)
    for formula-based dispatch. This is the key `find_def()` uses to
    route an incoming variable mapper `<var_id>` to the right
    `stat_define`, via `S7::S7_class(var_id)@name` (or the literal
    string `"formula"` when the variable mapper `<var_id>` is a formula
    rather than an S7 variable mapper `<var_id>` object).

2.  `impl`

    An
    [`agendas()`](https://s7-stats.github.io/statim/dev/reference/agendas.md)
    object: exactly one
    [`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md)
    for `base`, plus zero or more named
    [`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md)
    entries. `base` is what the default of top functions like
    [`T_TEST()`](https://s7-stats.github.io/statim/dev/reference/T_TEST.md)
    — it runs when no
    [`via()`](https://s7-stats.github.io/statim/dev/reference/via.md) is
    called and is the only thing reachable on the eager path. Every `fn`
    inside, whether it computes a binomial test or fits an
    [`lm()`](https://rdrr.io/r/stats/lm.html), must have `.proc` as its
    literal first formal.
    [`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md)
    and
    [`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md)
    both check this at construction time and refuse anything else:

    ``` r

    baseline(
        fn = function(data, ...) NULL,
        print = NULL
    )
    ```

         [1m [33mError [39m in `baseline()`: [22m
         [1m [22m [33m! [39m `fn` must have `.proc` as its first argument.
         [36mℹ [39m Found `data` instead.
         [36mℹ [39m See `baseline()` for the expected signature.

    `linear_reg_def_rel`’s implementation shows the same shape as
    `ptest_def`’s, just fitting a different model:

    ``` r

    linear_reg_def_rel = model_infer_define(
        model_type = rel,
        impl = agendas(
            base = baseline(
                fn = function(.proc, ...) {
                    x_data = .proc$x_data
                    resp_data = .proc$resp_data
                    f = stats::reformulate(names(x_data), response = names(resp_data))
                    lm_to_lm_object(stats::lm(f, data = vctrs::vec_cbind(resp_data, x_data), ...))
                }
            )
        )
    )
    ```

    Both
    [`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md)
    and
    [`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md)
    also accept a third, optional argument: `claim_parser`. This is
    where the hypothesis vocabulary for *that one implementation* lives
    — see the dedicated section below.

3.  `compatible_params`

    A list of population-parameter classes — `list(MU)`, `list(PI)` —
    this implementation’s hypothesis claims are allowed to reference. An
    empty list, the default, skips the check entirely. In practice this
    property is a hypothesis-test concern: `ptest_def` sets it to
    `list(PI)`, while `linear_reg_def_rel` and `linear_reg_def_formula`
    both leave it at the default, because model-based inference doesn’t
    currently route through
    [`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md)
    claims at all. Unlike `claim_parser` below, `compatible_params`
    applies to every variant inside `impl` uniformly — it isn’t
    something an individual
    [`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md)
    or
    [`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md)
    declares for itself.

## `claim_parser`: turning a claim into arguments

`claim_parser` is not a `stat_define` property — it’s an optional
argument to
[`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md)
and to each
[`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md)
individually, holding a
[`map_claim()`](https://s7-stats.github.io/statim/dev/reference/map_claim.md)
object that turns a parsed
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md)
claim into named arguments for that one `fn`. It defaults to `NULL`, and
stays `NULL` on every `LINEAR_REG` implementation — there is no claim
vocabulary to parse when the implementation was never given a hypothesis
to begin with. It only does work where a
[`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md)
or
[`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md)
explicitly opts in:

``` r

baseline(
    fn = function(.proc, .p = 0.5, .alt = "two.sided", .ci = 0.95, .true_p = NULL) {
        # ...
    },
    claim_parser = map_claim(
        .p = function(claim, processed) claim_scalar(claim, solve_coef = TRUE)$scalar,
        .alt = function(claim, processed) {
            switch(
                claim@op,
                "==" = , "!=" = "two.sided",
                ">=" = , ">" = "less",
                "<=" = , "<" = "greater"
            )
        }
    )
)
```

Because `claim_parser` sits on the implementation itself rather than in
a separate name-keyed lookup, there is nothing to keep in sync when you
add a new variant: a
[`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md)
that needs claim support declares its own `claim_parser`, and one that
doesn’t simply omits the argument.
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
checks whichever `impl` was actually resolved (`base`, a named variant,
or one registered via
[`add_variant()`](https://s7-stats.github.io/statim/dev/reference/add-variant.md))
for a `claim_parser` at the moment a stated claim needs translating —
see [recalibration and hypothesis
claims](https://s7-stats.github.io/statim/dev/articles/explanation/recalibration-method.html#recalibration-and-hypothesis-claims)
for how that interacts with
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md).

## How a object gets used

Both families of top-level function reach `stat_define` through a
mirrored pair of pipelines that differ only in name:

|  | Hypothesis tests | Model-based inference |
|----|----|----|
| Constructor | [`HTEST_FN()`](https://s7-stats.github.io/statim/dev/reference/HTEST_FN.md) | [`MODEL_FN()`](https://s7-stats.github.io/statim/dev/reference/MODEL_FN.md) |
| Lazy attach step | [`prepare_test()`](https://s7-stats.github.io/statim/dev/reference/prepare-test.md) | [`prepare_model()`](https://s7-stats.github.io/statim/dev/reference/prepare-model.md) |
| Lazy spec class | `test_spec` | `model_spec` |
| Lazy pipeline object | `test_lazy` | `model_lazy` |
| Example | `T_TEST`, `P_TEST` | `LINEAR_REG`, `GLM` |

Both pipelines converge on the same terminal generic. There are two
paths into a `stat_define`’s `impl`, and both end at `inject_and_run()`.

1.  Eager path: `T_TEST(x_by(extra, group), sleep)` or
    `LINEAR_REG(rel(mpg, wt), mtcars)` calls `run_stat()`, which finds
    the matching `stat_define` via `find_def()`, processes the variable
    mapper `<var_id>` through
    [`model_processor()`](https://s7-stats.github.io/statim/dev/reference/model-processor.md),
    and runs `def@impl$base` directly. There is no variant resolution on
    this path — only `base` is reachable.

2.  Lazy path:
    `sleep |> define_model(x_by(extra, group)) |> prepare_test(T_TEST) |> via("boot", n = 2000) |> conclude()`
    and
    `mtcars |> define_model(rel(mpg, wt)) |> prepare_model(LINEAR_REG) |> conclude()`
    both defer execution until
    [`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md),
    which has separate
    [`S7::method()`](https://rconsortium.github.io/S7/reference/method.html)
    implementations for `test_lazy` and `model_lazy`. The `test_lazy`
    method does four things: resolve the variant’s `fn` (falling back to
    `base` only when no variant was requested), merge
    [`via()`](https://s7-stats.github.io/statim/dev/reference/via.md)’s
    arguments over whatever was supplied at
    [`prepare_test()`](https://s7-stats.github.io/statim/dev/reference/prepare-test.md)
    time, run that resolved implementation’s own `claim_parser` if a
    claim is present, and call `inject_and_run()` once with the
    assembled argument list. The `model_lazy` method does the same,
    minus the claim step — `model_lazy` objects have no `claims` slot at
    all, since
    [`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md)
    only ever dispatches on `test_lazy`.

## The contract

`fn` can return anything, but returning a `class_stat_infer` subclass
unlocks two things for free:
[`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md)
dispatches to
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md)
automatically based on the result’s S7 class, and
[`print()`](https://rdrr.io/r/base/print.html) on the wrapping
`cld_exec` falls back to that class’s own `print` method when
[`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md)
/
[`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md)
didn’t supply one directly.

Test-side and model-side implementations both rely on this, through
different branches of the same hierarchy:

    class_stat_infer
        ├── anova_able
        │       └── class_lm_object       (LINEAR_REG)
        ├── class_ttest_two               (T_TEST · x_by)
        ├── class_ttest_pairwise          (T_TEST · pairwise)
        ├── class_corr_two                (COR_TEST · rel)
        └── class_p_test                  (P_TEST)

A variant that reuses its def’s existing result class inherits
[`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md) and
[`print()`](https://rdrr.io/r/base/print.html) for free — the
weighted-least-squares idea in the extension guide returns
`class_lm_object` and gets
[`anova()`](https://s7-stats.github.io/statim/dev/reference/anova-mod.md)
support along with it, without writing a single method. A variant that
needs genuinely different output, like the two-sample t-test’s `boot`
and `permute` variants returning plain lists, opts out of class-based
dispatch and supplies `print` directly on the
[`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md)
call instead.

## Current status

`defs` is closed over inside
[`STAT_CONSTRUCTOR()`](https://s7-stats.github.io/statim/dev/reference/STAT_CONSTRUCTOR.md)
at the moment a top-level function is built, with no exported way to
append a new `stat_define` to an existing function afterward. Teaching
`T_TEST` or `LINEAR_REG` a model shape it doesn’t already support means
editing the package source, not extending it from outside. Adding a new
*variant* to a model shape that’s already supported is the public
extension surface, and it doesn’t touch `defs` at all — see the [writing
a new estimation
method](https://s7-stats.github.io/statim/dev/articles/extend/new-est-method.md)
guide for that path.
