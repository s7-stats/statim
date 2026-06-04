# statim ![](reference/figures/logo.png)

> This package is under active development. APIs may change.

**Higher Level Interface for Statistical Inference**

## Package Overview

What does [statim](https://github.com/joshuamarie/statim) mean?

[statim](https://github.com/joshuamarie/statim) is a Latin word for
“immediately, at once”. The name carries a double meaning:

- *stat*: as in statistics, the domain this package lives in
- *im* (*statim*): as in immediate, signalling that inference should be
  expressible as a direct declaration, not somewhat a sequence of
  mechanical steps

This simply means: you declare *what* statistical inference you want to
perform, then [statim](https://github.com/joshuamarie/statim)
immediately delivers *how*.

## Why statim?

R has a rich statistical ecosystem, but inferential procedures are
fragmented by design: each function has its own interface, its own way
of specifying data, and its own output format. There is no shared
grammar for statistical inference: no way to say *what* you want to
infer without also committing to *how* every individual step is carried
out.

[statim](https://github.com/joshuamarie/statim) is an attempt to
re-imagine this from the ground up, the same way
[ggplot2](https://ggplot2.tidyverse.org) introduced a grammar for
graphics without replacing base plotting functions. The core idea is
that any inferential procedure can be described in three steps: define
the structure of the data
([`define_model()`](https://joshuamarie.github.io/statim/reference/model-define-base.md)),
declare what you want to infer
([`prepare_test()`](https://joshuamarie.github.io/statim/reference/prepare-test.md)),
and optionally recalibrate the estimation method
([`via()`](https://joshuamarie.github.io/statim/reference/via.md)). The
procedure executes only when you call
[`conclude()`](https://joshuamarie.github.io/statim/reference/conclude.md).

This separation matters because it makes statistical workflows
*composable*. Switching from a classical to a permutation procedure does
not require rewriting your code; it is a single addition to the
pipeline:

``` r

# Classical t-test
sleep |> define_model(x_by(extra, group)) |> prepare_test(TTEST) |> conclude()

# Permutation t-test: one line added, nothing else changes
sleep |> define_model(x_by(extra, group)) |> prepare_test(TTEST) |> via("permute", n = 1000L) |> conclude()

# The same pipeline shape works for any registered test
cars |> define_model(rel(speed, dist)) |> prepare_test(CORTEST) |> conclude()

# For a quick result, the eager form skips the pipeline entirely
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

## Usages

``` r

library(statim)
```

### T-test

The pipeline form lets you recalibrate the method without rewriting
anything else. Switching from a classical t-test to a permutation t-test
is a single
[`via()`](https://joshuamarie.github.io/statim/reference/via.md) call:

``` r

# Classical
sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(TTEST) |>
    conclude()
```

``` R
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : x_by 
#> Args : extra | group 
#>     x_vars : 1 
#>     by_vars : 1 
#> 
#> == T-Test ====================================================================== 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ─────────────────────────────────
#>   groups   diff   t-stat  pval   
#> ─────────────────────────────────
#>   group   -1.580  -1.861  0.079  
#> ─────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ──────────────────────────────
#>   groups  lower_95  upper_95  
#> ──────────────────────────────
#>   group    -3.365    0.205    
#> ──────────────────────────────
```

``` r

# Permutation: one line added, nothing else changes
sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(TTEST) |>
    via("permute", n = 500L, seed = 123L) |>
    conclude()
```

``` R
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : x_by 
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
#>    -1.580     0.072     500    
#> ───────────────────────────────
```

For a quick one-shot result, the eager form skips the pipeline entirely:

``` r

TTEST(x_by(extra, group), sleep)
```

``` R
#> -- Summary ---------------------------------------------------------------------
#> 
#> ─────────────────────────────────
#>   groups   diff   t-stat  pval   
#> ─────────────────────────────────
#>   group   -1.580  -1.861  0.079  
#> ─────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ──────────────────────────────
#>   groups  lower_95  upper_95  
#> ──────────────────────────────
#>   group    -3.365    0.205    
#> ──────────────────────────────
```

### Correlation test

The same pipeline shape works for any registered test. Here is the same
structure used for a correlation test:

``` r

cars |>
    define_model(rel(speed, dist)) |>
    prepare_test(CORTEST) |>
    conclude()
```

``` R
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : rel 
#> Args : speed ; dist 
#>     x_vars : 1 
#>     resp_vars : 1 
#> 
#> == Correlation Test ============================================================ 
#> 
#> -- Summary ---------------------------------------------------------------------
#> 
#> ─────────────────────────────────────────
#>       pair      estimate  stat    pval   
#> ─────────────────────────────────────────
#>   dist ~ speed   0.807    9.464  <0.001  
#> ─────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ────────────────────────────────────
#>       pair      lower_95  upper_95  
#> ────────────────────────────────────
#>   dist ~ speed   0.682     0.886    
#> ────────────────────────────────────
```

For a quick one-shot result, the eager form works here too:

``` r

CORTEST(rel(speed, dist), cars)
```

``` R
#> -- Summary ---------------------------------------------------------------------
#> 
#> ─────────────────────────────────────────
#>       pair      estimate  stat    pval   
#> ─────────────────────────────────────────
#>   dist ~ speed   0.807    9.464  <0.001  
#> ─────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ────────────────────────────────────
#>       pair      lower_95  upper_95  
#> ────────────────────────────────────
#>   dist ~ speed   0.682     0.886    
#> ────────────────────────────────────
```

## Core Ideas

The package is designed around three ideas:

1.  **A shared grammar**: every inferential procedure follows the same
    shape –
    [`define_model()`](https://joshuamarie.github.io/statim/reference/model-define-base.md),
    [`prepare_test()`](https://joshuamarie.github.io/statim/reference/prepare-test.md),
    [`conclude()`](https://joshuamarie.github.io/statim/reference/conclude.md)
    – regardless of which test is used. Eager forms
    ([`TTEST()`](https://joshuamarie.github.io/statim/reference/TTEST.md),
    [`CORTEST()`](https://joshuamarie.github.io/statim/reference/CORTEST.md),
    …) provide a shortcut when the full pipeline is not needed.
2.  **Composable pipelines**: build up a test specification lazily,
    recalibrate the estimation method with a single
    [`via()`](https://joshuamarie.github.io/statim/reference/via.md)
    call, and execute with
    [`conclude()`](https://joshuamarie.github.io/statim/reference/conclude.md).
3.  **Extensible by design**: every test is a
    [`test_define()`](https://joshuamarie.github.io/statim/reference/stat-infer-definer.md)
    object; bring your own engine, your own method, your own
    implementation.

## License

MIT © Joshua Marie

## Contributing

We are sincerely grateful for contributions; they are beneficial for the
project and for us as maintainers. Please read
[CONTRIBUTING.md](https://joshuamarie.github.io/statim/CONTRIBUTING.md)
for development setup, pull request guidelines, and workflow notes.

## Code of Conduct

Please note that the statim project is released with a [Contributor Code
of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
