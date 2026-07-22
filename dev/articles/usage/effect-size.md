# Gauging effect size with {statim}

## Rationale

A p-value answers one question: is this effect distinguishable from
noise. It says nothing about whether the effect is *large*. Effect size
is the separate quantity that answers “how big”. Use
[`gauge()`](https://s7-stats.github.io/statim/dev/reference/gauge.md)
from [statim](https://s7-stats.github.io/statim/) after evaluation of
the estimation with
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
to report it. This function reports Cohen’s *d* for a t-test, Cohen’s
*h* for a proportion test, R^2 and Cohen’s f^2 for a regression.

Same shape as
[`predict()`](https://s7-stats.github.io/statim/dev/reference/predict.md)
and [`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md):
one generic, used after
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md),
and dispatched on the `cld_exec` object from
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md).
When the result inside is a `class_stat_infer` subclass, (1)
[`gauge()`](https://s7-stats.github.io/statim/dev/reference/gauge.md)
re-routes to
[`auto_gauge()`](https://s7-stats.github.io/statim/dev/reference/auto_gauge.md)
automatically, or (2) a
[`making_gauge()`](https://s7-stats.github.io/statim/dev/reference/making_gauge.md)
registry exists for the rare case where a variant’s `fn` returns
something else. Nothing about calling
[`gauge()`](https://s7-stats.github.io/statim/dev/reference/gauge.md)
changes depending on whether you’re holding a t-test or a GLM, only the
metric name in the output does.

## Setup

``` r

box::use(
    statim[
        define_model, prepare, state_null, conclude, gauge,
        LINEAR_REG, GLM, T_TEST, P_TEST,
        x_by, prop, PI
    ],
    stats[update, binomial]
)

box::use(
    dplyr[mutate, glimpse],
    readr[read_csv]
)
```

The example data is the same:

``` r

heart = 
    read_csv(system.file("extdata", "heart-disease.csv", package = "statim")) |>
    mutate(
        sex = factor(sex, levels = c(0, 1), labels = c("Female", "Male")),
        target = factor(target, levels = c(0, 1), labels = c("No", "Yes"))
    )
```

     [1mRows:  [22m [34m303 [39m  [1mColumns:  [22m [34m14 [39m
     [36m── [39m  [1mColumn specification [22m  [36m──────────────────────────────────────────────────────── [39m
     [1mDelimiter: [22m ","
     [32mdbl [39m (14): age, sex, cp, trestbps, chol, fbs, restecg, thalach, exang, oldpea...

     [36mℹ [39m Use `spec()` to retrieve the full column specification for this data.
     [36mℹ [39m Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r

glimpse(heart)
```

``` fansi
Rows: 303
Columns: 14
$ age      <dbl> 63, 37, 41, 56, 57, 57, 56, 44, 52, 57, 54, 48, 49, 64, 58, 5…
$ sex      <fct> Male, Male, Female, Male, Female, Male, Female, Male, Male, M…
$ cp       <dbl> 3, 2, 1, 1, 0, 0, 1, 1, 2, 2, 0, 2, 1, 3, 3, 2, 2, 3, 0, 3, 0…
$ trestbps <dbl> 145, 130, 130, 120, 120, 140, 140, 120, 172, 150, 140, 130, 1…
$ chol     <dbl> 233, 250, 204, 236, 354, 192, 294, 263, 199, 168, 239, 275, 2…
$ fbs      <dbl> 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0…
$ restecg  <dbl> 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1…
$ thalach  <dbl> 150, 187, 172, 178, 163, 148, 153, 173, 162, 174, 160, 139, 1…
$ exang    <dbl> 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0…
$ oldpeak  <dbl> 2.3, 3.5, 1.4, 0.8, 0.6, 0.4, 1.3, 0.0, 0.5, 1.6, 1.2, 0.2, 0…
$ slope    <dbl> 0, 0, 2, 2, 2, 1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 1, 2, 0, 2, 2, 1…
$ ca       <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0…
$ thal     <dbl> 1, 2, 2, 2, 2, 1, 2, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3…
$ target   <fct> Yes, Yes, Yes, Yes, Yes, Yes, Yes, Yes, Yes, Yes, Yes, Yes, Y…
```

## Effect size for a regression

Refit the two models from this
[vignette](https://s7-stats.github.io/statim/dev/articles/usage/model-infer.md):

``` r

mod1 = heart |>
    define_model(thalach ~ age + sex + chol) |>
    prepare(LINEAR_REG) |>
    conclude()

mod2 = heart |>
    define_model(target ~ age + chol + trestbps) |>
    prepare(GLM) |>
    update(family = binomial()) |>
    conclude()
```

Then extract the effect size with
[`gauge()`](https://s7-stats.github.io/statim/dev/reference/gauge.md):

``` r

gauge(mod1)
```

``` fansi
# A tibble: 2 × 2
  metric    value
  <chr>     <dbl>
1 r_squared 0.170
2 cohens_f2 0.204
```

For a linear model, that’s `r_squared`: The share of variance in
`thalach` explained by age, sex, and cholesterol together, and
`cohens_f2`, the same quantity rescaled onto Cohen’s small/medium/large
convention (`r2 / (1 - r2)`).

By [`GLM()`](https://s7-stats.github.io/statim/dev/reference/GLM.md)’s
default, it has no residual sum of squares in the OLS sense so
[`gauge()`](https://s7-stats.github.io/statim/dev/reference/gauge.md)
reports two R^2-analogues instead

``` r

gauge(mod2)
```

``` fansi
# A tibble: 4 × 2
  metric              value
  <chr>               <dbl>
1 deviance_r2        0.0440
2 mcfadden_r2        0.0440
3 cohens_f2_deviance 0.0460
4 cohens_f2_mcfadden 0.0460
```

- `deviance_r2`, built from deviance the way `r_squared` is built from
  RSS

- `mcfadden_r2`, comparing the fitted model’s log-likelihood against an
  intercept-only model.

The figure most commonly cited alongside a logistic regression. Each
gets its own `cohens_f2` conversion, since the two don’t agree closely
enough to share one.

## Effect size for a hypothesis test

### t-test

The same
[`gauge()`](https://s7-stats.github.io/statim/dev/reference/gauge.md)
call works on
[`T_TEST()`](https://s7-stats.github.io/statim/dev/reference/T_TEST.md)
and
[`P_TEST()`](https://s7-stats.github.io/statim/dev/reference/P_TEST.md)
results too. Is cholesterol different between men and women in this
cohort?

``` r

chol_by_sex = 
    heart |>
    define_model(x_by(chol, sex)) |>
    prepare(T_TEST) |>
    conclude()

chol_by_sex
```

``` fansi

== Model ======================================================================= 

Variable Mapper : x_by 
Args : chol | sex 
    x_vars : 1 
    by_vars : 1 

== T-Test ====================================================================== 

-- Summary ---------------------------------------------------------------------

────────────────────────────────────────────
  group  estimate  t_stat    df     p_val   
────────────────────────────────────────────
   sex   -22.012   -3.024  134.390  <0.001  
────────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

─────────────────────────────
  group  lower_95  upper_95  
─────────────────────────────
   sex   -36.407    -7.617   
─────────────────────────────
```

By default, `TTEST()` under
[`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md) path
doesn’t store per-group sample sizes, so
[`auto_gauge()`](https://s7-stats.github.io/statim/dev/reference/auto_gauge.md)
approximates Cohen’s *d* as `2 * t_stat / sqrt(df)`. It is “exact” under
roughly equal group sizes, and reported as `cohens_d_approx` rather than
`cohens_d` to flag the assumption.

``` r

gauge(chol_by_sex)
```

``` fansi
# A tibble: 1 × 3
  group metric           value
  <chr> <chr>            <dbl>
1 sex   cohens_d_approx -0.522
```

Optionally, you can pass `quiet = FALSE` to
[`gauge()`](https://s7-stats.github.io/statim/dev/reference/gauge.md) to
print the same caveat as a message.

### Proportion test

And what fraction of this cohort has heart disease, against a
hypothesized 50%?

``` r

n_yes = sum(heart$target == "Yes")
n_total = nrow(heart)

disease_rate = define_model(prop(n_yes, n_total)) |>
    prepare(P_TEST) |> 
    state_null(PI() == 0.5) |> 
    conclude()

disease_rate
```

``` fansi

== Model ======================================================================= 

Variable Mapper : prop 
Args : 165 / 303 
    x : 165 
    n : 303 

== Proportion Test ============================================================= 

-- Summary ---------------------------------------------------------------------

────────────────────────────────────────────────
   x    n   true_p  estimate  statistic  p_val  
────────────────────────────────────────────────
  165  303  0.500    0.545       165     0.135  
────────────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

──────────────────────
  lower_95  upper_95  
──────────────────────
   0.487     0.602    
──────────────────────
```

By default,
[`gauge()`](https://s7-stats.github.io/statim/dev/reference/gauge.md)
for
[`P_TEST()`](https://s7-stats.github.io/statim/dev/reference/P_TEST.md)
reports Cohen’s *h*, the arcsine-transformed difference between the
observed and hypothesized proportions. The standard effect size for a
single proportion, since raw proportion differences aren’t comparable
across different baseline rates the way Cohen’s *d* is for means.

``` r

gauge(disease_rate)
```

``` fansi
# A tibble: 1 × 2
  metric    value
  <chr>     <dbl>
1 cohens_h 0.0892
```
