# Writing Full Null Hypothesis Expression

## Rationale

It may sound complex, but it’s meant to mirror what you’d already write
under a hypothesis heading in a statistics textbook.
[statim](https://github.com/s7-stats/statim) leans on syntactic sugar
and a small embedded DSL (domain-specific language) to do this, and the
closest existing analogue in R is `join_by()` from
[dplyr](https://dplyr.tidyverse.org): a join condition like `x == y` is
never evaluated as a boolean — it’s captured as an unevaluated
expression and interpreted structurally by the join itself.

[`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md)
works the same way. `MU(x) == 0` is never run as a logical test;
[`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md)
parses it into a `null_claim` object recording the parameter, the
operator, and the scalar, and hands that structure to whichever `fn` the
active variant runs.

## How `state_null()` reads an expression

Parsing happens in two passes. First, the top-level operator is checked
against a fixed set — `==`, `!=`, `<`, `>`, `<=`, `>=` — anything else
is rejected before either side is touched. Then each side is parsed
independently: a numeric literal becomes a scalar term, a call to a
known `<param_obj>` constructor
([`MU()`](https://s7-stats.github.io/statim/reference/MU.md),
[`PI()`](https://s7-stats.github.io/statim/reference/PI.md),
[`RHO()`](https://s7-stats.github.io/statim/reference/RHO.md)) becomes a
parameter term with its arguments captured as quosures rather than
evaluated, and `+`, `-`, `*`, `/`, `^` recurse into the same parser, so
a combination like the one below parses just as readily as a bare
parameter on its own:

``` r

c * MU(x, g == "a") - d == scalar
```

A bare symbol is the one exception: if it isn’t a known parameter
constructor,
[`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md)
tries evaluating it in the calling environment and accepts the result
only if it’s numeric, which is how a named threshold like `thresh = 0.5`
followed by `PI() == thresh` works without being mistaken for a
parameter.

## Linear combinations

A claim with exactly one parameter term is handled by
[`claim_scalar()`](https://s7-stats.github.io/statim/reference/claim_scalar.md),
which rearranges `c * PARAM + d == scalar` so everything but the
parameter sits on the right. This is what lets
[`P_TEST()`](https://s7-stats.github.io/statim/reference/P_TEST.md)
accept a scaled claim like `2 * PI() == 0.3` and solve it down to
`.p = 0.15` for
[`binom.test()`](https://rdrr.io/r/stats/binom.test.html), while still
displaying `0.3` as the hypothesis you actually typed.

A claim with more than one parameter term needs
[`claim_contrast_coefs()`](https://s7-stats.github.io/statim/reference/claim_contrast_coefs.md)
instead, and it adds a guard
[`claim_scalar()`](https://s7-stats.github.io/statim/reference/claim_scalar.md)
doesn’t have: `assert_linear()` walks the expression first and rejects a
parameter multiplied by another parameter, a parameter in a denominator,
or a parameter raised to a power, each with an error pointing at the
exact offending subexpression.

This is what backs the t-test contrast variant:

``` r

sleep |>
    define_model(extra %by% group) |>
    prepare_test(TTEST) |>
    state_null(
        # Internally, `<=` will be automatically flipped for the alternative hypothesis
        2 * MU(extra, group == "1") - MU(extra, group == "2") <= 0
    ) |>
    via("contrast") |>
    conclude()
```

Order matters here in a way that’s easy to miss: which named term ends
up with coefficient `+1` versus `-1` is decided by the order you wrote
the expression in, not by any property of the groups themselves.
`MU(extra, group == "1") - MU(extra, group == "2")` and
`MU(extra, group == "2") - MU(extra, group == "1")` are the same
hypothesis mathematically — one is just the negation of the other — but
[`TTEST()`](https://s7-stats.github.io/statim/reference/TTEST.md)’s
[`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md)
translator reads whichever name has coefficient `+1` as `.first_group`,
and uses it to decide which group becomes `x` in the underlying
[`stats::t.test()`](https://rdrr.io/r/stats/t.test.html) call.

Write the groups in the opposite order and the test still runs and
reports the same p-value, but `estimate` and `t_stat` come back with the
opposite sign. This isn’t specific to
[`TTEST()`](https://s7-stats.github.io/statim/reference/TTEST.md),
either — any `claim_translator` that reads `names(coefs)[coefs == 1]`
the same way inherits the same sensitivity, since
[`claim_contrast_coefs()`](https://s7-stats.github.io/statim/reference/claim_contrast_coefs.md)
preserves the left-to-right order terms were written in all the way
through to the `coefs` vector it returns.

That guard is specific to
[`claim_contrast_coefs()`](https://s7-stats.github.io/statim/reference/claim_contrast_coefs.md),
though, not to non-linearity in general.
[`claim_scalar()`](https://s7-stats.github.io/statim/reference/claim_scalar.md)
never calls `assert_linear()`, so the same mistake in a single-parameter
claim doesn’t get the same clean diagnostic:

``` r

define_model(prop(45, 100)) |>
    prepare_test(P_TEST) |>
    state_null(5 / PI() == 1) |>
    conclude()
```

This still fails, but inside `collect_terms()`’s arithmetic branches,
which assume their non-coefficient operand is numeric and divide into it
without checking — the result is a generic R error about a non-numeric
argument to a binary operator, not a message naming the parameter or the
rule it broke. Worth knowing if you ever hit a cryptic error from a
hypothesis that looks fine at a glance: the parser did catch it, but
only the multi-parameter path explains why.

If two terms for the same parameter happen to cancel inside a contrast —
writing `MU(x, a) - MU(x, a)`, say — the coefficient resolves to zero
rather than silently vanishing, and
[statim](https://github.com/s7-stats/statim) warns about it instead of
quietly dropping the term, since a zero coefficient is far more often a
typo than an intentional contrast. The same duplicate in a
single-parameter claim never reaches that logic at all:
[`claim_scalar()`](https://s7-stats.github.io/statim/reference/claim_scalar.md)
counts it as two parameter terms and refuses outright before any
cancellation could happen.

## Potential grips

Three guardrails are worth knowing about before assuming a claim will
just work.

1.  The left-hand side must contain a parameter. `0.5 == PI()` is
    rejected outright, with the error suggesting the flipped, accepted
    form — `PI() == 0.5` — rather than silently swapping it for you. The
    direction you write is the direction that’s kept.

2.  Every `stat_define` can restrict which parameter types it accepts
    via `compatible_params`, and
    [`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md)
    enforces this the moment the claim is attached, not later at
    [`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md)
    time.
    [`P_TEST()`](https://s7-stats.github.io/statim/reference/P_TEST.md)’s
    default implementation only accepts
    [`PI()`](https://s7-stats.github.io/statim/reference/PI.md); writing
    `state_null(MU(x) == 0)` against a
    [`prop()`](https://s7-stats.github.io/statim/reference/prop.md)
    pipeline fails immediately, naming the parameter you used and the
    parameters that were actually allowed.

3.  Every variable named inside a parameter is checked against the
    variables the model ID actually declared. Let’s take a look of this:
    `MU(extra, group == "1")`. `extra` and `group`. Every problem found
    is collected and reported together rather than stopping at the first
    one. A typo’d variable name fails at
    [`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md),
    not three steps later inside the test implementation.
