# statim ![](reference/figures/logo.png)

> This package is under active development. APIs may change.

**A Declarative Interface for Statistical Inference**

## Package Overview

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

R has a rich statistical ecosystem, but statistical inference in general
is served by an assortment of disconnected functions. R gained a grammar
for graphics ([ggplot2](https://ggplot2.tidyverse.org)) and one for data
manipulation ([dplyr](https://dplyr.tidyverse.org)), but statistical
inference has no equivalent: each testing function ships with its own
interface, its own way of specifying data, and its own output format.
There is no shared grammar for inference: no way to say *what* you want
to test without simultaneously committing to *how* the procedure carries
it out.

[statim](https://github.com/s7-stats/statim) is an attempt to re-imagine
this from the ground up, the same way
[ggplot2](https://ggplot2.tidyverse.org) introduced a grammar for
graphics without replacing base plotting functions. The core idea is
that any inferential procedure can be described in [three
steps](#general-usage).

This separation matters because it makes statistical workflows
*composable*. For example, in t-test you just want to switch from
classical to permutation. [statim](https://github.com/s7-stats/statim)
won’t need you to do a lot of work (which sometimes require rewriting
your code) to switch from a classical to a permutation procedure does
not require rewriting your code, just a single addition to the syntax.

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
    via("permute", n = 1000L) |> # Here, one line added, nothing else changes
    conclude()
```

The same syntax works for any registered tests, e.g. correlation test:

``` r

cars |> 
    define_model(rel(speed, dist)) |> 
    prepare_test(CORTEST) |> 
    conclude()
    
```

For a quick result, the eager form skips the piped syntax entirely:

``` r

# Only works for `stat_fn` function
TTEST(x_by(extra, group), sleep)
CORTEST(rel(speed, dist), cars)
```

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
pak::pak("joshuamarie/statim")
```

## General Usage

Loading a library comes with [a lot of
preferences](https://joshuamarie.com/posts/06-load-pkg/). In this
example, [`library()`](https://rdrr.io/r/base/library.html) is used for
a simple demonstration:

``` r

library(statim)
```

All you need to know is that the usual workflow of
[statim](https://github.com/s7-stats/statim) comes with three usual
steps:

``` r

sleep |>                                # 1
    define_model(extra %by% group) |>   # 1              
    prepare_test(TTEST) |>              # 2         
    update(.ci = 0.9) |>                # 2      
    conclude() |>                       # 3           
    tidy()                              # 3          
```

1.  *Model processor and definition*, where defining the model *to be
    analyzed* happens at the beginning during statistical inference.
    Typically, this step where supplying either a data frame or a
    `<model_id>` objects into
    [`define_model()`](https://s7-stats.github.io/statim/reference/model-define-base.md)
    occurs, and then some functions to be appended in the future
    updates.

2.  *Parameterization*, and then proceed to writing the estimation
    process of the statistical inference pipeline. At the normal level,
    the statistical inference can be either a model-based inference
    (e.g. linear regression through
    [`prepare_model()`](https://s7-stats.github.io/statim/reference/prepare-model.md))
    or H-test inference (e.g. t-test through
    [`prepare_test()`](https://s7-stats.github.io/statim/reference/prepare-test.md)).
    They are lazy-loaded, and only executed if needed.

3.  *Execution and retrieval* then (re-)executes the first 2 steps and
    retrieves the output. There are several techniques to retrieve the
    output — e.g. through
    [`tidy()`](https://s7-stats.github.io/statim/reference/tidy.md).
    Functions like these will worked if there are available method is
    registered, automatically or from a manual step.

See through
[`vignette("statim")`](https://s7-stats.github.io/statim/articles/statim.md),
and learn more about the API design as a starter.

## Core Semantics

The package is designed around three ideas:

1.  **A shared grammar**: every inferential procedure follows the same
    shape –
    [`define_model()`](https://s7-stats.github.io/statim/reference/model-define-base.md),
    [`prepare_test()`](https://s7-stats.github.io/statim/reference/prepare-test.md),
    [`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md)
    – regardless of which test or model ID is used. The model ID objects
    (e.g. `x_by`, `rel`, `pairwise`) determines what the test does; the
    grammar stays the same. Eager forms
    ([`TTEST()`](https://s7-stats.github.io/statim/reference/TTEST.md),
    [`CORTEST()`](https://s7-stats.github.io/statim/reference/CORTEST.md),
    …) provide a shortcut when the full pipeline is not needed.

2.  **Composable pipelines**: build up a test specification lazily,
    recalibrate the estimation method with a single
    [`via()`](https://s7-stats.github.io/statim/reference/via.md) call,
    and execute with
    [`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md).

3.  **Extensible by design**: every test is a
    [`stat_define()`](https://s7-stats.github.io/statim/reference/stat-infer-definer.md)
    object; bring your own engine, your own method, your own
    implementation. Auto dispatch handles
    [`tidy()`](https://s7-stats.github.io/statim/reference/tidy.md) for
    your method without requiring you to write it.

## License

MIT © Joshua Marie

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
