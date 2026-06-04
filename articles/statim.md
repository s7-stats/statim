# Getting started with statim

## Introduction

[statim](https://github.com/joshuamarie/statim) is a new and modified
approach of high-level statistical inference in R. It is fully built for
statistical inference pipeline, made to be pipe-able, extensible, and
exportable. This package is built at top of S7, making
[statim](https://github.com/joshuamarie/statim) flexible and strict. The
idea is not completely new, as the said approach apparantly inherits
traditional statistical modelling approach in R around this idea:

``` r
<<statistical-function>>(<formula>, <data>)
```

But it comes with the flavors of tidyverse-esque grammar verbs
composition.

## Emulation of formulas: model IDs

The functions that emulate the `<formula>` (and its idea) to describe
the model to be written within the pipeline are called model IDs.
Normally, they inherit the parent S7 class of `<model_id>`, and they
should be built within S7. Traditionally, `<formula>` is used to
describe the relationship between LHS (left-hand side) and RHS
(right-hand side), but `<model_id>` take it on another different level.

[statim](https://github.com/joshuamarie/statim) has built-in
`<model_id>` objects:

1.  [`x_by()`](https://joshuamarie.github.io/statim/reference/x_by.md):
    When used, it is simply translated as “compare x by group”. It
    requires 2 main arguments: `x` and `group`, and it is ideal for
    pipelines which compares `x` by `group`. Moreover, you can
    alternatively use its infix operator version `%by%`.

    ``` r

    # In a function call
    x_by(x, group)
    x_by(x, c(g1, g2))

    # Using its infix operator version
    x %by% group
    x %by% c(g1, g2)
    ```

    Both `x` and `group` accept `<tidyselect>` helpers, such as
    `starts_with()`. Only when a data frame is supplied.

2.  [`rel()`](https://joshuamarie.github.io/statim/reference/rel.md): It
    simply reads the expression once used as “relationship between x and
    y”. It requires 2 main arguments: `x` and `resp`, and it is ideal
    for pipelines which describes the relationship of `x` to `resp`.

    ``` r

    rel(x, y)
    ```

    Both `x` and `resp` accept `<tidyselect>` helpers, such as
    `starts_with()`. Only when a data frame is supplied.

3.  [`pairwise()`](https://joshuamarie.github.io/statim/reference/pairwise.md):
    With this function, all variables being selected by it will produce
    pairs one-by-one. Use `direction` to regulate which pairs are kept,
    and it’s `"lt"` (less than) by default.

    ``` r

    pairwise(x, y, z)
    ```

    Note: When using `direction`, the filtration is based on
    lexicographic (alphabetical) ordering. Basically, `direction = "lt"`
    currently means “keep pairs where `name_a` comes before `name_b`
    alphabetically”. Also, it can accept `<tidyselect>` helpers if data
    frame is given.

And if you notice, they also emulate `aes()` mapper from
[ggplot2](https://ggplot2.tidyverse.org), which it captures the
expression internally, instead of evaluating them — indeed they are
mappers, just like `<formula>` objects. Take note that every
`<model_id>` must be a captured expression, generally in `<language>`
data structure, just like formula objects in R.

## General Workflow

![](workflow.jpg)

Usual workflow of writing
[statim](https://github.com/joshuamarie/statim) comes with three (3)
stages:

1.  *Model processor and definition:* The stage that explains the model
    of the statistical inference. You’ll use
    [`define_model()`](https://joshuamarie.github.io/statim/reference/model-define-base.md)
    (always at the beginning), and then some functions to be added in
    the future (like transformations and updating the model).

2.  *Parameterization:* This stage is where you’ll define the
    statistical inference. It is either a model-based inference
    (e.g. linear regression) or H-test inference (e.g. t-test). They are
    lazy-loaded, and you should be able to do anything.

3.  *Output processing and retrieval:* You’ll execute the
    parameterization pipeline, and retrieve the output.

Example:

``` r

# i. Model processor and definition
sleep_dm = define_model(sleep, extra %by% group)

# ii. Parameterization (lazy-loaded)
sleep_tt = sleep_dm |> prepare_test(TTEST) |> update(.ci = 0.9)

# iii. Output processing and retrieval
out = conclude(sleep_tt)
print(out)
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
#>   group  lower_90  upper_90  
#> ─────────────────────────────
#>   group   -3.053    -0.107   
#> ─────────────────────────────
tidy(out)
#> # A tibble: 1 × 7
#>   group estimate t_stat    df  p_val lower_90 upper_90
#>   <chr>    <dbl>  <dbl> <dbl>  <dbl>    <dbl>    <dbl>
#> 1 group    -1.58  -1.86  17.8 0.0794    -3.05   -0.107
```

Since it is pipe-able, you can write down at once the following example
above as:

``` r

sleep |> 
    define_model(extra %by% group) |> 
    prepare_test(TTEST) |> 
    update(.ci = 0.9) |> 
    conclude() |> 
    tidy()
#> # A tibble: 1 × 7
#>   group estimate t_stat    df  p_val lower_90 upper_90
#>   <chr>    <dbl>  <dbl> <dbl>  <dbl>    <dbl>    <dbl>
#> 1 group    -1.58  -1.86  17.8 0.0794    -3.05   -0.107
```

## Hypothesis expressioms

One of the most unique features of
[statim](https://github.com/joshuamarie/statim) is the ability to write
down the expression of null hypothesis during the test in a mathematical
form, not in a declarative manner like `alternative = "less"` gimmicks.
