# What are {statim}'s Null Hypothesis Expressions?

## Rationale

It may sound complex, but it’s easy and intuitive. It is meant to mirror
what you’d read and already write under a hypothesis heading in a
statistics textbook. [statim](https://s7-stats.github.io/statim/) leans
on syntactic sugar and a small embedded DSL (domain-specific language)
to do this, and the closest existing analogue in R is `join_by()` from
[dplyr](https://dplyr.tidyverse.org): a join condition like `x == y` is
never evaluated as a boolean — it’s captured as an unevaluated
expression and interpreted structurally by the join itself.

[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md)
works the same way. `MU(x) == 0` is never run as a logical test;
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md)
parses it into a `null_claim` object recording the parameter, the
operator, and the scalar, and hands that structure to whichever `fn` the
active variant runs.

## How `state_null()` reads an expression

Parsing happens in two passes. First, the top-level operator is checked
against a fixed set — `==`, `!=`, `<`, `>`, `<=`, `>=` — anything else
is rejected before either side is touched. Then each side is parsed
independently: a numeric literal becomes a scalar term, a call to a
known `<param_obj>` constructor
([`MU()`](https://s7-stats.github.io/statim/dev/reference/MU.md),
[`PI()`](https://s7-stats.github.io/statim/dev/reference/PI.md),
[`RHO()`](https://s7-stats.github.io/statim/dev/reference/RHO.md))
becomes a parameter term with its arguments captured as quosures rather
than evaluated, and `+`, `-`, `*`, `/`, `^` recurse into the same
parser, so a combination like the one below parses just as readily as a
bare parameter on its own:

``` r

c * MU(x, g == "a") - d == scalar
```

A bare symbol is the one exception: if it isn’t a known parameter
constructor,
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md)
tries evaluating it in the calling environment and accepts the result
only if it’s numeric, which is how a named threshold like `thresh = 0.5`
followed by `PI() == thresh` works without being mistaken for a
parameter.

## Linear combinations

A claim with exactly one parameter term is handled by
[`claim_scalar()`](https://s7-stats.github.io/statim/dev/reference/claim_scalar.md),
which rearranges `c * PARAM + d == scalar` so everything but the
parameter sits on the right. This is what lets
[`P_TEST()`](https://s7-stats.github.io/statim/dev/reference/P_TEST.md)
accept a scaled claim like `2 * PI() == 0.3` and solve it down to
`.p = 0.15` for
[`binom.test()`](https://rdrr.io/r/stats/binom.test.html), while still
displaying `0.3` as the hypothesis you actually typed.

A null hypothesis claim expression with more than one parameter term,
e.g. `c1 * MU(x, g == "a") + c2 * MU(x, g == "b") == scalar`, needs
[`claim_contrast_coefs()`](https://s7-stats.github.io/statim/dev/reference/claim_contrast_coefs.md)
instead, and it adds a guard
[`claim_scalar()`](https://s7-stats.github.io/statim/dev/reference/claim_scalar.md)
doesn’t have: it uses `assert_linear()` internally that walks the
expression first and rejects a parameter multiplied by another
parameter, a parameter in a denominator, or a parameter raised to a
power, each with an error pointing at the exact offending subexpression.

This is what backs the t-test contrast variant:

``` r

sleep |>
    define_model(extra %by% group) |>
    prepare_test(T_TEST) |>
    state_null(
        # Internally, `<=` will be automatically flipped into `>` for the alternative hypothesis
        2 * MU(extra, group == "1") - MU(extra, group == "2") <= 0
    ) |>
    via("contrast") |>
    conclude()
```

``` fansi

== Model ======================================================================= 

Variable Mapper : x_by 
Args : extra | group 
    x_vars : 1 
    by_vars : 1 

== T-Test · contrast =========================================================== 

-- Summary ---------------------------------------------------------------------

──────────────────────────────────────────
  group  estimate  t_stat    df    p_val  
──────────────────────────────────────────
  group   -0.830   -0.640  14.130  0.734  
──────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

─────────────────────────────
  group  lower_95  upper_95  
─────────────────────────────
  group   -3.112     Inf     
─────────────────────────────
```

Order matters here in a way that’s easy to miss: which named term ends
up with coefficient `+1` versus `-1` is decided by the order you wrote
the expression in, not by any property of the groups themselves.

### Another simple example

- 1 vs 2
- 2 vs 1

``` r

sleep |>
    define_model(extra %by% group) |>
    prepare_test(T_TEST) |>
    state_null(
        MU(extra, group == "1") - MU(extra, group == "2") <= 0
    ) |>
    conclude()
```

``` fansi

== Model ======================================================================= 

Variable Mapper : x_by 
Args : extra | group 
    x_vars : 1 
    by_vars : 1 

== T-Test ====================================================================== 

-- Summary ---------------------------------------------------------------------

──────────────────────────────────────────
  group  estimate  t_stat    df    p_val  
──────────────────────────────────────────
  group   -1.580   -1.861  17.780  0.960  
──────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

─────────────────────────────
  group  lower_95  upper_95  
─────────────────────────────
  group   -3.053     Inf     
─────────────────────────────
```

``` r

sleep |>
    define_model(extra %by% group) |>
    prepare_test(T_TEST) |>
    state_null(
        MU(extra, group == "2") - MU(extra, group == "1") <= 0
    ) |>
    conclude()
```

``` fansi

== Model ======================================================================= 

Variable Mapper : x_by 
Args : extra | group 
    x_vars : 1 
    by_vars : 1 

== T-Test ====================================================================== 

-- Summary ---------------------------------------------------------------------

──────────────────────────────────────────
  group  estimate  t_stat    df    p_val  
──────────────────────────────────────────
  group   1.580    1.861   17.780  0.040  
──────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

─────────────────────────────
  group  lower_95  upper_95  
─────────────────────────────
  group   0.107      Inf     
─────────────────────────────
```

### Explanation

`MU(extra, group == "1") - MU(extra, group == "2")` and
`MU(extra, group == "2") - MU(extra, group == "1")` are the same
hypothesis mathematically. One is just the negation of the other, but
[`T_TEST()`](https://s7-stats.github.io/statim/dev/reference/T_TEST.md)’s
[`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md)
`claim_parser` reads whichever name has coefficient `+1` as
`.first_group`, and uses it to decide which group becomes `x` and which
becomes `y` in the underlying `stats::t.test(x, y, ...)` call.

Run both tabs above and the asymmetry shows up immediately: `estimate`
and `t_stat` flip sign, exactly as you’d expect from swapping `x` and
`y`. The p-value, though, does *not* stay put — it goes from `0.960` to
`0.040`, the two numbers summing to almost exactly `1`. That’s the
signature of a one-sided test whose tail got swapped along with the
groups, not preserved. `.alt` is resolved from `claim@op` alone — `<=`
always becomes `"greater"`, regardless of which side of the contrast a
group landed on — so reordering the groups changes which physical
quantity (`x - y` vs `y - x`) that fixed `"greater"` direction is being
asked about. The hypothesis you wrote and the hypothesis
[`t.test()`](https://rdrr.io/r/stats/t.test.html) actually evaluated end
up pointing in opposite directions, even though `.alt` itself never
changed.

This is specific to one-sided claims. Write the same comparison with
`==` instead of `<=`, and the p-value genuinely is invariant to order,
because a two-sided test is symmetric around zero — swapping `x` and `y`
only negates the statistic, and `"two.sided"` doesn’t care which side of
zero you landed on. It’s only `<`, `<=`, `>`, and `>=` claims where
group order silently decides which one-sided question gets asked, which
makes this worth checking deliberately rather than assuming the test
“just knows” which direction you meant.

Nor is this specific to
[`T_TEST()`](https://s7-stats.github.io/statim/dev/reference/T_TEST.md)
— any `claim_parser` that reads `names(coefs)[coefs == 1]` to pick out a
“first” term the same way inherits the same sensitivity, since
[`claim_contrast_coefs()`](https://s7-stats.github.io/statim/dev/reference/claim_contrast_coefs.md)
preserves the left-to-right order terms were written in all the way
through to the `coefs` vector it returns. If you’re writing a
`claim_parser` for a new variant and it derives both an entity (a group,
a side, a reference level) and a direction (`.alt`, a sign convention)
from the same claim independently, double-check that the two stay
consistent under reordering — they won’t, by default.

The `assert_linear()` guard from the previous section is unrelated to
this. It only rejects non-linear *structure* (a parameter times a
parameter, in a denominator, raised to a power), and has nothing to say
about term order, which is exactly why swapping two valid linear terms
passes silently instead of erroring: there’s no rule being broken, just
an implicit convention (whichever term is `+1` is “first”) that’s easy
to not notice you’re relying on.
[`claim_scalar()`](https://s7-stats.github.io/statim/dev/reference/claim_scalar.md)
never calls `assert_linear()` at all, so the same kind of structural
mistake in a single-parameter claim doesn’t get the same clean
diagnostic:

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
[statim](https://s7-stats.github.io/statim/) warns about it instead of
quietly dropping the term, since a zero coefficient is far more often a
typo than an intentional contrast. The same duplicate in a
single-parameter claim never reaches that logic at all:
[`claim_scalar()`](https://s7-stats.github.io/statim/dev/reference/claim_scalar.md)
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
    [`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md)
    enforces this the moment the claim is attached, not later at
    [`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
    time.
    [`P_TEST()`](https://s7-stats.github.io/statim/dev/reference/P_TEST.md)’s
    default implementation only accepts
    [`PI()`](https://s7-stats.github.io/statim/dev/reference/PI.md);
    writing `state_null(MU(x) == 0)` against a
    [`prop()`](https://s7-stats.github.io/statim/dev/reference/prop.md)
    pipeline fails immediately, naming the parameter you used and the
    parameters that were actually allowed.

3.  Every variable named inside a parameter is checked against the
    variables the variable mapper `<var_id>` actually declared. Let’s
    take a look of this: `MU(extra, group == "1")`. `extra` and `group`.
    Every problem found is collected and reported together rather than
    stopping at the first one. A typo’d variable name fails at
    [`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md),
    not three steps later inside the test implementation.
