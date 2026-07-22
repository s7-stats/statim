# statim

**A Declarative Interface for Statistical Inference**

## Package Overview: Simple Fun Fact

What does [statim](https://s7-stats.github.io/statim/) mean?

*statim* is a Latin word for “immediately, at once”. Its prefix, *stat*
(as in statistics), is where the domain this package lives in. This can
be interpreted as: you declare *what* statistical inference you want to
perform, then [statim](https://s7-stats.github.io/statim/) immediately
delivers *how*.

## Installation

The stable version of package can be installed from CRAN:

``` r

# Stable version
install.packages("statim")
```

You can install the current development version from GitHub:

``` r

# Development version from GitHub
# install.packages("pak")
pak::pak("s7-stats/statim")
```

## Why statim?

R has a dedicated rich ecosystem in statistics. Statistical inference in
general is served by an assortment of disconnected functions: the
functions you’re looking for may exist but they are scattered across
different packages.

R gained a grammar for graphics
([ggplot2](https://ggplot2.tidyverse.org)), and one for data
manipulation ([dplyr](https://dplyr.tidyverse.org)). And then there’s
[statim](https://s7-stats.github.io/statim/), an attempt to re-imagine
the “grammar of statistical inference” from the ground up. The core idea
of [statim](https://s7-stats.github.io/statim/) in general is it’s fully
declarative, and that any inferential procedure can be described in
[three steps](https://s7-stats.github.io/statim/articles/statim.html).

What makes [statim](https://s7-stats.github.io/statim/) *composable* for
statistical workflows is the *verbs* and the *accessibility* of the
methods you’re looking for. For example, you want to write a t-test
pipeline, and you want to use the classical one and then the permutation
method. [statim](https://s7-stats.github.io/statim/) lets you do that
with `via("<method_name>")`, and while you can use t-test from `default`
(classical), you can access its permutation method through
`... |> via("permute")` with one line of code only. You won’t need you
to do a lot of work (which sometimes require rewriting your code), just
a single addition to the syntax.

``` r

# Classical t-test
sleep |> 
    define_model(x_by(extra, group)) |> 
    prepare_test(T_TEST) |> 
    conclude()

# Permutation t-test
sleep |> 
    define_model(x_by(extra, group)) |> 
    prepare_test(T_TEST) |> 
    # Here, one line added
    # Nothing else changed
    via("permute", n = 1000L) |>         
    conclude()
```

For a quick result, a one-liner or an eager form skips the piped syntax
entirely:

``` r

# Only works for `<stat_fn>` functions
T_TEST(x_by(extra, group), sleep)
```

The nuanced downside of eager forms is that they are not supported with
its main semantics that is, for example, (1) recalibrating / switching
off into different methods from the same estimation method with
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md) and
(2) do not support post-execution output manipulation.

Visit
[`vignette("statim")`](https://s7-stats.github.io/statim/dev/articles/statim.md)
to get started.

## Core Semantics

The package is designed around three ideas:

1.  **Composability**: the simplest way to write
    [statim](https://s7-stats.github.io/statim/) has two forms: the
    eager form and the grammar/piped syntax form. The eager form skips
    the verbs and cannot be recalibrated, only skips to the output. On
    the other hand, the grammar/piped syntax form relies on verbs and
    lazy loading, which comes with the recalibration of the estimation
    method with a single
    [`via()`](https://s7-stats.github.io/statim/dev/reference/via.md)
    call, and the execution of the lazy-loaded pipeline with
    [`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md).

2.  **A shared grammar**: Only applied on the main
    [statim](https://s7-stats.github.io/statim/) semantics:
    piped/grammar syntax.
    [`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md)
    =\>
    [`prepare()`](https://s7-stats.github.io/statim/dev/reference/prepare.md)
    =\>
    [`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
    is the same shape for every inferential procedure. The `<var_id>`
    objects (`x_by`, `rel`, `pairwise`, …) describe the statistical
    structure of the problem; the verbs stay constant.

    > Eager forms
    > ([`T_TEST()`](https://s7-stats.github.io/statim/dev/reference/T_TEST.md),
    > [`COR_TEST()`](https://s7-stats.github.io/statim/dev/reference/COR_TEST.md),
    > …) provide a shortcut when the full pipeline (in a form of piped
    > syntax that reads like a sentence) is not needed.

3.  **Extensible by design**: the
    [statim](https://s7-stats.github.io/statim/) pipeline is extensible.
    For instance, if you want to write new estimation method, an
    implementation is through filling up the
    [`stat_define()`](https://s7-stats.github.io/statim/dev/reference/stat-infer-definer.md)
    object (then store it within list of `defs` from
    [`STAT_CONSTRUCTOR()`](https://s7-stats.github.io/statim/dev/reference/STAT_CONSTRUCTOR.md)
    functions, saved as `<STAT_FN>`), then
    [`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md)
    to write the default form of `<STAT_FN>` and
    [`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md)
    to extend the current `<STAT_FN>` form (only be accessed with
    [`via()`](https://s7-stats.github.io/statim/dev/reference/via.md)
    only). With these, you can bring your own engine, your own method,
    your own implementation, or use them to extend the current ones.

## License

MIT + file LICENSE

## Contributing

We are sincerely grateful for contributions; they are beneficial for the
project and for us as maintainers. Please read
[CONTRIBUTING.md](https://github.com/s7-stats/statim/blob/master/.github/CONTRIBUTING.md)
for development setup, pull request guidelines, and workflow notes.

## Code of Conduct

Please note that the statim project is released with a [Contributor Code
of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
