# statim ![](reference/figures/logo.png)

**A Declarative Interface for Statistical Inference**

## Package Overview: Simple Fun Fact

What does [statim](https://github.com/s7-stats/statim) mean?

[statim](https://github.com/s7-stats/statim) is a Latin word for
“immediately, at once”. The name carries a double meaning:

- *stat*: as in statistics, the domain this package lives in
- *im* (*statim*): as in “immediate”, signalling that inference should
  be expressible as a direct declaration, not somewhat a sequence of
  mechanical steps

This simply means: you declare *what* statistical inference you want to
perform, then [statim](https://github.com/s7-stats/statim) immediately
delivers *how*.

## Why statim?

R has a rich statistical ecosystem. Most of the packages in the wild
were written at top of S3 and S4, and it is yet for the S7 to be
prominent into statistical ecosystem —
[statim](https://github.com/s7-stats/statim) is glad to take the step
(there are reasons why [S7 supersedes both S3 and
S4](https://tidyverse.org/blog/2024/11/s7-0-2-0/)). Statistical
inference in general is served by an assortment of disconnected
functions: the functions you’re looking for may exist but they are
scattered across different packages.

R gained a grammar for graphics
([ggplot2](https://ggplot2.tidyverse.org)), and one for data
manipulation ([dplyr](https://dplyr.tidyverse.org)). And then there’s
[statim](https://github.com/s7-stats/statim), an attempt to re-imagine
the “grammar of statistical inference” from the ground up. The core idea
of [statim](https://github.com/s7-stats/statim) in general is it’s fully
declarative, and that any inferential procedure can be described in
[three steps](#general-usage).

What makes [statim](https://github.com/s7-stats/statim) *composable* for
statistical workflows is the *verbs* and the *accessibility* of the
methods you’re looking for. For example, you want to write a t-test
pipeline, and you want to use the classical one and then the permutation
method. [statim](https://github.com/s7-stats/statim) lets you do that
with [`via()`](https://s7-stats.github.io/statim/reference/via.md), and
while you can use t-test from `default` (classical), you can access its
permutation method through `... |> via(permute)` (or whatever the
keyword is) with one line of code only. You won’t need you to do a lot
of work (which sometimes require rewriting your code), just a single
addition to the syntax.

``` r

# Classical t-test
sleep |> 
    define_model(x_by(extra, group)) |> 
    prepare_test(TTEST) |> 
    conclude()

# Permutation t-test
sleep |> 
    define_model(x_by(extra, group)) |> 
    prepare_test(TTEST) |> 
    # Here, one line added, nothing else changes
    via("permute", n = 1000L) |>         
    conclude()
```

For a quick result, the eager form skips the piped syntax entirely:

``` r

# Only works for `stat_fn` functions
TTEST(x_by(extra, group), sleep)
```

The trade-off: eager forms cannot be recalibrated / switch off into
different methods with
[`via()`](https://s7-stats.github.io/statim/reference/via.md) and do not
support post-execution output manipulation ([see for more
details](#core-semantics)).

## Installation

The package is yet to be submitted into CRAN.

``` r

# Stable version (not yet released)
install.packages("statim")
```

For the time being, you can install the current implementation on
GitHub:

``` r

# Development version from GitHub
# install.packages("pak")
pak::pak("s7-stats/statim")
```

## General Usage

By the way, loading a library comes with [a lot of
preferences](https://joshuamarie.com/posts/06-load-pkg/). Let us start
by loading [statim](https://github.com/s7-stats/statim) first:

``` r

library(statim)
```

All you need to know is that the most usual usage of
[statim](https://github.com/s7-stats/statim) comes with three steps.

``` r
data |>                                                       # 1
    define_model(<model_id>(var1, var2, ...)) |>              # 1  
    # Lazy loading begins after
    prepare_<test/model>(<STAT_FN>) |>                        # 2  
    # Must come after `prepare_test()` / prepare_model()` 
    via() |>                                                  # 2
    state_null() |>                                           # 2 
    # End of lazy loading
    conclude() |>                                             # 3            
    <output-to-process>()                                     # 3          
```

Brief explanation of the code above:

1.  *Model processor and definition*, where defining the shape of model
    *to be analyzed* happens at the beginning during statistical
    inference. Typically, this step where supplying either a data frame
    or a `<model_id>` objects into
    [`define_model()`](https://s7-stats.github.io/statim/reference/model-define-base.md)
    occurs, and then some functions to be appended in the future
    updates.

2.  *Parameterization*, where the estimation process of the statistical
    inference pipeline is defined lazily. Our usual statistical
    inference application can be either a model-based inference
    (e.g. linear regression through
    [`prepare_model()`](https://s7-stats.github.io/statim/reference/prepare-model.md))
    or H-test inference (e.g. t-test through
    [`prepare_test()`](https://s7-stats.github.io/statim/reference/prepare-test.md)).
    With that said, the execution is lazy-loaded, and only executed if
    needed.

3.  *Execution and retrieval*, where the first 2 steps is (re-)executed
    and then retrieve the output. The most common function is
    [`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md).
    There are several techniques to retrieve the output, e.g. through
    [`tidy()`](https://s7-stats.github.io/statim/reference/tidy.md).
    This is functional if there are available methods are registered,
    automatically or from a manual step.

For more information, see through
[`vignette("statim")`](https://s7-stats.github.io/statim/articles/statim.md),
and learn more about how [statim](https://github.com/s7-stats/statim)
works.

## Core Semantics

The package is designed around three ideas:

1.  **Composability**: the simplest way to write
    [statim](https://github.com/s7-stats/statim) has two forms: the
    eager form and the grammar/piped syntax form. The eager form skips
    the verbs and cannot be recalibrated, only skips to the output. On
    the other hand, the grammar/piped syntax form relies on verbs and
    lazy loading, which comes with the recalibration of the estimation
    method with a single
    [`via()`](https://s7-stats.github.io/statim/reference/via.md) call,
    and the execution of the lazy-loaded pipeline with
    [`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md).

2.  **A shared grammar**: Only applied on the main
    [statim](https://github.com/s7-stats/statim) semantics:
    piped/grammar syntax.
    [`define_model()`](https://s7-stats.github.io/statim/reference/model-define-base.md)
    =\> `prepare_*()` =\>
    [`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md)
    is the same shape for every inferential procedure. The `<model_id>`
    objects (`x_by`, `rel`, `pairwise`, …) describe the statistical
    structure of the problem; the verbs stay constant.

    > Eager forms
    > ([`TTEST()`](https://s7-stats.github.io/statim/reference/TTEST.md),
    > [`CORTEST()`](https://s7-stats.github.io/statim/reference/CORTEST.md),
    > …) provide a shortcut when the full pipeline (in a form of piped
    > syntax that reads like a sentence) is not needed.

3.  **Extensible by design**: the
    [statim](https://github.com/s7-stats/statim) pipeline is extensible.
    For instance, if you want to write new estimation method, an
    implementation is through filling up the
    [`stat_define()`](https://s7-stats.github.io/statim/reference/stat-infer-definer.md)
    object (then store it within list of `defs` from
    [`STAT_CONSTRUCTOR()`](https://s7-stats.github.io/statim/reference/STAT_CONSTRUCTOR.md)
    functions, saved as `<STAT_FN>`), then
    [`baseline()`](https://s7-stats.github.io/statim/reference/baseline.md)
    to write the default form of `<STAT_FN>` and
    [`variant()`](https://s7-stats.github.io/statim/reference/variant.md)
    to extend the current `<STAT_FN>` form (only be accessed with
    [`via()`](https://s7-stats.github.io/statim/reference/via.md) only).
    With these, you can bring your own engine, your own method, your own
    implementation, or use them to extend the current ones.

## License

MIT + file LICENSE

## Contributing

We are sincerely grateful for contributions; they are beneficial for the
project and for us as maintainers. Please read
[CONTRIBUTING.md](https://s7-stats.github.io/statim/CONTRIBUTING.md) for
development setup, pull request guidelines, and workflow notes.

## Code of Conduct

Please note that the statim project is released with a [Contributor Code
of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
