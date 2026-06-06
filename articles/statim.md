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

    # infix form
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
    With this function, all variables being selected by it will generate
    all pairwise combinations. Use `direction` to regulate which pairs
    are kept, and it’s `"lt"` (less than) by default.

    ``` r

    pairwise(x, y, z)
    ```

    Note: When using `direction`, the filtration is based on
    lexicographic (alphabetical) ordering. Basically, `direction = "lt"`
    means “keep pairs where `name_a` comes before `name_b`
    alphabetically”. Also, it accepts `<tidyselect>` helpers if a data
    frame is given.

4.  [`prop()`](https://joshuamarie.github.io/statim/reference/prop.md):
    Use this when the data is just a single observed count, namely the
    number of successes `x` out of `n` trials. Unlike the other model
    IDs,
    [`prop()`](https://joshuamarie.github.io/statim/reference/prop.md)
    takes scalar constants directly; no variable names or data frame is
    involved.

    ``` r

    prop(45, 100)   # 45 successes out of 100 trials
    ```

    Because the data is embedded in the model ID itself,
    [`define_model()`](https://joshuamarie.github.io/statim/reference/model-define-base.md)
    does not require a data frame:

    ``` r

    define_model(prop(45, 100))
    ```

And if you notice, they also emulate `aes()` mapper from
[ggplot2](https://ggplot2.tidyverse.org), which it captures the
expression internally, instead of evaluating them — indeed they are
mappers, just like `<formula>` objects. Take note that `model_id`
abstract S7 class must be carried as you create another `<model_id>`
object (see more details).

If you don’t have the given data frame, internally it tries to look up
the variables you passed on `<model_id>` objects at the current
environment (global environment by default). If you don’t want to write
intermediate variables by assigning the data you created in a variable,
use inline data with [`I()`](https://rdrr.io/r/base/AsIs.html) or
multiple inlines with
[`inlines()`](https://joshuamarie.github.io/statim/reference/inlines.md):

``` r

# `x_by()`
I(rnorm(30)) %by% I(rep(c("a", "b"), each = 30))

# `rel()`
rel(I(rnorm(30)), I(rnorm(30)))

# `pairwise()`
pairwise(inlines(rnorm(30), rnorm(30), rnorm(30)))
```

## General Workflow

![](workflow.jpg)

Usual workflow of writing
[statim](https://github.com/joshuamarie/statim) comes with three (3)
stages:

1.  *Model processor and definition:* The stage which explains the model
    to be analyzed throughout the
    [statim](https://github.com/joshuamarie/statim)’s statistical
    inference pipeline. This stage is where you supplied either data
    frame (it could be any data structure, as long as they’re dispatched
    into
    [`model_processor()`](https://joshuamarie.github.io/statim/reference/model-processor.md))
    or a `<model_id>` (formula objects are special ones) into
    [`define_model()`](https://joshuamarie.github.io/statim/reference/model-define-base.md),
    and then some functions to be added in the future (like
    transformations and updating the model).

2.  *Parameterization:* This stage is always AFTER defining the model to
    be analyzed within the statistical inference pipeline, a stage which
    defines the estimation process of the statistical inference. It is
    either a model-based inference (e.g. linear regression) or H-test
    inference (e.g. t-test). They are lazy-loaded, and you should be
    able to do anything. Later updates may include other processes, such
    as sensitivity analysis.

3.  *Execution and retrieval:* You’ll execute the first-two stages,
    especially the parameterization stage, and then retrieve the output.

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

### Eager Form

There are times where you do not need the full pipeline, a quick eager
form can do that. For a quick one-shot result, every test exposes an
eager form that skips
[`define_model()`](https://joshuamarie.github.io/statim/reference/model-define-base.md)
and
[`prepare_test()`](https://joshuamarie.github.io/statim/reference/prepare-test.md)
entirely:

``` r

TTEST(extra %by% group, sleep, .ci = 0.9)
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
```

The eager form accepts the same model ID and data arguments, pass the
rest of arguments, and returns the same printed output. The only
constraints the “eager form” compensates is you can’t use the rest of
the API, such as
[`via()`](https://joshuamarie.github.io/statim/reference/via.md) and
[`tidy()`](https://joshuamarie.github.io/statim/reference/tidy.md).

## Recalibrating the estimation method

[statim](https://github.com/joshuamarie/statim) has a way to recalibrate
the method of estimation in the statistical inference pipeline. Use
[`via()`](https://joshuamarie.github.io/statim/reference/via.md) to
switch a lazy pipeline to an alternative estimation method. It updates
the specification while the whole pipeline is defused before
[`conclude()`](https://joshuamarie.github.io/statim/reference/conclude.md)
executes it. Any named arguments after `.method` are forwarded to that
variant.

For example, switching from a classical t-test to a permutation test is
a single added line, with nothing else changing:

``` r

# Classical
sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(TTEST) |>
    conclude()
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
#>   group  lower_95  upper_95  
#> ─────────────────────────────
#>   group   -3.365    0.206    
#> ─────────────────────────────

# Permutation: one line added
sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(TTEST) |>
    via("permute", n = 999L) |>
    conclude()
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
#>    -1.580     0.102     999    
#> ───────────────────────────────

# Bootstrap
sleep |>
    define_model(x_by(extra, group)) |>
    prepare_test(TTEST) |>
    via("boot", n = 2000L) |>
    conclude()
#> 
#> == Model ======================================================================= 
#> 
#> Model ID : x_by 
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
#>   CI     :   [-3.1, -0.0198]
#>   n_reps :              2000
#> ------------------------------
```

## Hypothesis expressioms

One of the distinguishing features of
[statim](https://github.com/joshuamarie/statim) is the ability to state
the null hypothesis as a mathematical expression. The conventional
approach in base R uses declarative strings gotchas like
`alternative = "less"`. While it is a shortcase, they encode a direction
without naming the parameter being constrained or the value it is being
tested against. You cannot read `alternative = "greater"` and know
whether the claim is about a population mean, a population proportion,
or a population correlation without reading the surrounding context.
After all, hypothesis testing is about testing the null hypothesis of
whether you have an evidence to support the claim, and parametric tests
are about testing the population population.

While [statim](https://github.com/joshuamarie/statim) still supports
this, [statim](https://github.com/joshuamarie/statim) made some
redirection with explicit hypothesis declaration built from parameter
objects, in `<param_obj>` class, and standard R comparison operators.
The expression names the population parameter, the relational operator,
and the hypothesized scalar — the same three components that appear in
any textbook null hypothesis statement. Internally,
[`state_null()`](https://joshuamarie.github.io/statim/reference/null-hyp.md)
parses the expression, extracts the important components, and passes
them into the `fn` implementation from
[`baseline()`](https://joshuamarie.github.io/statim/reference/baseline.md)
/
[`variant()`](https://joshuamarie.github.io/statim/reference/variant.md).
Any linear combination of parameters is accepted on either side.

The supported operators are `==`, `!=`, `<`, `>`, `<=`, `>=`, and `%=%`
(simultaneous equality across multiple parameters). Here are the current
built-in `<param_obj>` objects:

- [`MU()`](https://joshuamarie.github.io/statim/reference/MU.md): refers
  to the population mean \mu. It has following usages:

  1.  `MU(x)` which means the assumed population mean of the variable
      `x`.

  2.  `MU(x, group == "1")` which means the assumed population mean of
      the variable `x` given the `group` equal `"1"`.

- [`RHO()`](https://joshuamarie.github.io/statim/reference/RHO.md): or
  \rho which refers to the population correlation between 2 variables —
  `RHO(x, y) == 0` simply means the population correlation between `x`
  and `y` is 0 or \rho\_{x, y} = 0.

- [`PI()`](https://joshuamarie.github.io/statim/reference/PI.md): refers
  to the population proportion \pi. Used with
  [`prop()`](https://joshuamarie.github.io/statim/reference/prop.md)
  pipelines. It accepts zero or one argument:

  1.  [`PI()`](https://joshuamarie.github.io/statim/reference/PI.md) —
      the population proportion of the modelled count, when the variable
      name is already encoded in the model ID via
      [`prop()`](https://joshuamarie.github.io/statim/reference/prop.md)
      (see
      [`?P_TEST`](https://joshuamarie.github.io/statim/reference/P_TEST.md)).

  2.  `PI(x)` — the population proportion of a named variable `x`, for
      future two-sample proportion tests.

Here’s a simple example of a t-test that tests the following null
hypothesis:

\mu\_{x\|\text{group}=1} \leq \mu\_{x\|\text{group}=2}

or sometimes this null hypothesis can be written as:

\mu_1 \leq \mu_2

``` r

sleep |>
    define_model(extra %by% group) |>
    prepare_test(TTEST) |>
    state_null(
        MU(x, group == "1") <= MU(x, group == "2")
    ) |>
    conclude()
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
#>   group   -1.580   -1.861  17.780  0.960  
#> ──────────────────────────────────────────
#> 
#> 
#> -- Confidence Interval ---------------------------------------------------------
#> 
#> ─────────────────────────────
#>   group  lower_95  upper_95  
#> ─────────────────────────────
#>   group   -3.053     Inf     
#> ─────────────────────────────
```

## Generalization

If you have an inferential statistics tasks, give this package a shot —
it’s updated and more modernized. Besides, it’s written in S7, so type
annotation is the least of your worries. And that’s pretty much all you
need to know when you started working with this package.
