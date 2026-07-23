# Regression modelling with {statim}

## Rationale

[statim](https://s7-stats.github.io/statim/) already covered the
hypothesis testing using this package in this
[vignette](https://s7-stats.github.io/statim/dev/articles/usage/htest.md).
This vignette covers the hypothesis testing based on *regression
models*.
[`prepare()`](https://s7-stats.github.io/statim/dev/reference/prepare.md)
is still used to initialize the parameterization of the inference stage,
but the other one,
[`prepare_model()`](https://s7-stats.github.io/statim/dev/reference/prepare-model.md),
has the same functionality but more safely typed and feeds it
`LINEAR_REG` or `GLM` instead. Same `<var_id>` mappers, same verbs, same
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
at the end. If a hypothesis question turns out to need a regression
instead of a t-test, the syntax on the main semantic you already wrote
doesn’t change shape, thus the pipeline doesn’t change, only the
`<STAT_FN>` swapped in and/or the given during the “definition” stage.

Three questions from the same dataset, run as regression models instead
of hypothesis tests.

### Sample Problem

Same dataset as the hypothesis testing vignette: 303 patients from the
Cleveland Clinic, bundled with this package at
`inst/extdata/heart-disease.csv`. Two columns join the ones used
previously:

| Column   | Type       | Description                                 |
|----------|------------|---------------------------------------------|
| `chol`   | Continuous | Serum cholesterol (mg/dl)                   |
| `target` | Binary     | Presence of heart disease (0 = No, 1 = Yes) |

The questions:

1.  [Does age predict resting blood pressure?](#q1)
2.  [Do age, sex, and cholesterol together explain max heart rate?](#q2)
3.  [Do age, cholesterol, and resting blood pressure predict the
    presence of heart disease?](#q3)

## Setup

The setup is pretty much the same as the setup section from [“Hypothesis
Testing”](https://s7-stats.github.io/statim/dev/articles/usage/htest.md)
vignette, where [box](https://klmr.me/box/) is used to load the imports,
and the
[`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html)
is preferred to import the CSV file.

``` r

box::use(
    statim[
        define_model, prepare, prepare_model, conclude, 
        # Supported models
        LINEAR_REG, GLM,
        # Miscellaneous functions
        rel, tidy,
        # Multiple executions
        write_models, anova
    ],
    stats[update, binomial],
)
```

Then import the CSV file from this package:

``` r

box::use(
    dplyr[mutate, glimpse],
    readr[read_csv],
)

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

## Question 1: Does age predict resting blood pressure?

\text{trestbps} = \beta_0 + \beta_1 \cdot \text{age} + \varepsilon

This is an example case for simple linear regression. There are two
layouts to fit a linear model, the same two you’d reach for in the
hypothesis testing vignette.

Using `rel()`

``` r

heart |>
    define_model(rel(age, trestbps)) |>
    prepare(LINEAR_REG) |>
    conclude()
```

``` fansi

== Model ======================================================================= 

Variable Mapper : rel 
Args : age ; trestbps 
    x_vars : 1 
    resp_vars : 1 

== Linear Regression =========================================================== 

-- Coefficients ----------------------------------------------------------------

──────────────┬───────────────────────────────────────────
  term        │  estimate  std_error  statistic  p_value  
──────────────┼───────────────────────────────────────────
  (Intercept) │  102.296     5.891     17.366    <0.001   
  age         │   0.539      0.107      5.048    <0.001   
──────────────┴───────────────────────────────────────────


-- Model Fit -------------------------------------------------------------------
```

    Warning in system("tput cols", intern = TRUE): running command 'tput cols' had
    status 2

    ------------------------------------------------------
      R Squared      :    0.08    F-statistic :    25.48
      Adj. R Squared :    0.07    df1         :        1
      Sigma          :   16.87    df2         :      301
      n              :     303    p-value     :   <0.001
      df (residual)  :     301                :         
    ------------------------------------------------------

You can use its one-liner version:

``` r

LINEAR_REG(rel(age, trestbps), heart)
```

``` fansi
-- Coefficients ----------------------------------------------------------------

──────────────┬───────────────────────────────────────────
  term        │  estimate  std_error  statistic  p_value  
──────────────┼───────────────────────────────────────────
  (Intercept) │  102.296     5.891     17.366    <0.001   
  age         │   0.539      0.107      5.048    <0.001   
──────────────┴───────────────────────────────────────────


-- Model Fit -------------------------------------------------------------------
```

    Warning in system("tput cols", intern = TRUE): running command 'tput cols' had
    status 2

    ------------------------------------------------------
      R Squared      :    0.08    F-statistic :    25.48
      Adj. R Squared :    0.07    df1         :        1
      Sigma          :   16.87    df2         :      301
      n              :     303    p-value     :   <0.001
      df (residual)  :     301                :         
    ------------------------------------------------------

Using formula syntax

``` r

heart |>
    define_model(trestbps ~ age) |>
    prepare(LINEAR_REG) |>
    conclude()
```

``` fansi

== Model ======================================================================= 

Variable Mapper : formula 
Args : trestbps ~ age 
    left_var : 1 
    right_var : 1 

== Linear Regression =========================================================== 

-- Coefficients ----------------------------------------------------------------

──────────────┬───────────────────────────────────────────
  term        │  estimate  std_error  statistic  p_value  
──────────────┼───────────────────────────────────────────
  (Intercept) │  102.296     5.891     17.366    <0.001   
  age         │   0.539      0.107      5.048    <0.001   
──────────────┴───────────────────────────────────────────


-- Model Fit -------------------------------------------------------------------
```

    Warning in system("tput cols", intern = TRUE): running command 'tput cols' had
    status 2

    ------------------------------------------------------
      R Squared      :    0.08    F-statistic :    25.48
      Adj. R Squared :    0.07    df1         :        1
      Sigma          :   16.87    df2         :      301
      n              :     303    p-value     :   <0.001
      df (residual)  :     301                :         
    ------------------------------------------------------

You can use its one-liner version:

``` r

LINEAR_REG(trestbps ~ age, heart)
```

``` fansi
-- Coefficients ----------------------------------------------------------------

──────────────┬───────────────────────────────────────────
  term        │  estimate  std_error  statistic  p_value  
──────────────┼───────────────────────────────────────────
  (Intercept) │  102.296     5.891     17.366    <0.001   
  age         │   0.539      0.107      5.048    <0.001   
──────────────┴───────────────────────────────────────────


-- Model Fit -------------------------------------------------------------------
```

    Warning in system("tput cols", intern = TRUE): running command 'tput cols' had
    status 2

    ------------------------------------------------------
      R Squared      :    0.08    F-statistic :    25.48
      Adj. R Squared :    0.07    df1         :        1
      Sigma          :   16.87    df2         :      301
      n              :     303    p-value     :   <0.001
      df (residual)  :     301                :         
    ------------------------------------------------------

Both layouts land on the same fit. `rel(age, trestbps)` reads “the
relationship between age and trestbps”; the formula reads “trestbps
explained by age.” Pick whichever one your eyes parse faster,
[statim](https://s7-stats.github.io/statim/) doesn’t care which you use.

Interpretation: each additional year of age adds a little over half an
mmHg to resting blood pressure on average, and the slope is significant
(p \< 0.001). The relationship is real, if modest.

## Question 2: Do age, sex, and cholesterol explain max heart rate?

\text{thalach} = \beta_0 + \beta_1 \cdot \text{age} + \beta_2 \cdot
\text{sex} + \beta_3 \cdot \text{chol} + \varepsilon

This is an example case of multiple linear regression. Here’s a small
preview for the layout to be used: (1)
[`rel()`](https://s7-stats.github.io/statim/dev/reference/rel.md)’s `x`
argument takes a [`c()`](https://rdrr.io/r/base/c.html) of bare names,
so multiple predictors don’t require switching to (2) formula syntax.

Using `rel()`

``` r

mod1 = heart |>
    define_model(
        rel(c(age, sex, chol), thalach)
    ) |>
    prepare_model(LINEAR_REG) |>
    conclude()

mod1
```

``` fansi

== Model ======================================================================= 

Variable Mapper : rel 
Args : age, sex, chol ; thalach 
    x_vars : 3 
    resp_vars : 1 

== Linear Regression =========================================================== 

-- Coefficients ----------------------------------------------------------------

──────────────┬───────────────────────────────────────────
  term        │  estimate  std_error  statistic  p_value  
──────────────┼───────────────────────────────────────────
  (Intercept) │  202.496     9.118     22.208    <0.001   
  age         │   -1.058     0.136     -7.766    <0.001   
  sexMale     │   -3.558     2.647     -1.344     0.180   
  chol        │   0.029      0.024      1.192     0.234   
──────────────┴───────────────────────────────────────────


-- Model Fit -------------------------------------------------------------------
```

    Warning in system("tput cols", intern = TRUE): running command 'tput cols' had
    status 2

    ------------------------------------------------------
      R Squared      :    0.17    F-statistic :    20.38
      Adj. R Squared :    0.16    df1         :        3
      Sigma          :   20.97    df2         :      299
      n              :     303    p-value     :   <0.001
      df (residual)  :     299                :         
    ------------------------------------------------------

> Note:
> [`prepare_model()`](https://s7-stats.github.io/statim/dev/reference/prepare-model.md)
> has the same functionality as
> [`prepare()`](https://s7-stats.github.io/statim/dev/reference/prepare.md)
> but designed to be safely typed for regression models.

You can use its one-liner version:

``` r

LINEAR_REG(rel(c(age, sex, chol), thalach), heart)
```

``` fansi
-- Coefficients ----------------------------------------------------------------

──────────────┬───────────────────────────────────────────
  term        │  estimate  std_error  statistic  p_value  
──────────────┼───────────────────────────────────────────
  (Intercept) │  202.496     9.118     22.208    <0.001   
  age         │   -1.058     0.136     -7.766    <0.001   
  sexMale     │   -3.558     2.647     -1.344     0.180   
  chol        │   0.029      0.024      1.192     0.234   
──────────────┴───────────────────────────────────────────


-- Model Fit -------------------------------------------------------------------
```

    Warning in system("tput cols", intern = TRUE): running command 'tput cols' had
    status 2

    ------------------------------------------------------
      R Squared      :    0.17    F-statistic :    20.38
      Adj. R Squared :    0.16    df1         :        3
      Sigma          :   20.97    df2         :      299
      n              :     303    p-value     :   <0.001
      df (residual)  :     299                :         
    ------------------------------------------------------

Using formula syntax

``` r

heart |>
    define_model(thalach ~ age + sex + chol) |>
    prepare_model(LINEAR_REG) |>
    conclude()
```

``` fansi

== Model ======================================================================= 

Variable Mapper : formula 
Args : thalach ~ age + sex + chol 
    left_var : 1 
    right_var : 3 

== Linear Regression =========================================================== 

-- Coefficients ----------------------------------------------------------------

──────────────┬───────────────────────────────────────────
  term        │  estimate  std_error  statistic  p_value  
──────────────┼───────────────────────────────────────────
  (Intercept) │  202.496     9.118     22.208    <0.001   
  age         │   -1.058     0.136     -7.766    <0.001   
  sexMale     │   -3.558     2.647     -1.344     0.180   
  chol        │   0.029      0.024      1.192     0.234   
──────────────┴───────────────────────────────────────────


-- Model Fit -------------------------------------------------------------------
```

    Warning in system("tput cols", intern = TRUE): running command 'tput cols' had
    status 2

    ------------------------------------------------------
      R Squared      :    0.17    F-statistic :    20.38
      Adj. R Squared :    0.16    df1         :        3
      Sigma          :   20.97    df2         :      299
      n              :     303    p-value     :   <0.001
      df (residual)  :     299                :         
    ------------------------------------------------------

You can use its one-liner version:

``` r

LINEAR_REG(thalach ~ age + sex + chol, heart)
```

``` fansi
-- Coefficients ----------------------------------------------------------------

──────────────┬───────────────────────────────────────────
  term        │  estimate  std_error  statistic  p_value  
──────────────┼───────────────────────────────────────────
  (Intercept) │  202.496     9.118     22.208    <0.001   
  age         │   -1.058     0.136     -7.766    <0.001   
  sexMale     │   -3.558     2.647     -1.344     0.180   
  chol        │   0.029      0.024      1.192     0.234   
──────────────┴───────────────────────────────────────────


-- Model Fit -------------------------------------------------------------------
```

    Warning in system("tput cols", intern = TRUE): running command 'tput cols' had
    status 2

    ------------------------------------------------------
      R Squared      :    0.17    F-statistic :    20.38
      Adj. R Squared :    0.16    df1         :        3
      Sigma          :   20.97    df2         :      299
      n              :     303    p-value     :   <0.001
      df (residual)  :     299                :         
    ------------------------------------------------------

Extract a tidy coefficient table with
[`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md)
instead of reading the printed one:

``` r

tidy(mod1)
```

``` fansi
# A tibble: 4 × 5
  term        estimate std_error statistic  p_value
  <chr>          <dbl>     <dbl>     <dbl>    <dbl>
1 (Intercept) 202.        9.12       22.2  3.18e-65
2 age          -1.06      0.136      -7.77 1.30e-13
3 sexMale      -3.56      2.65       -1.34 1.80e- 1
4 chol          0.0289    0.0242      1.19 2.34e- 1
```

Interpretation: age is still doing the heavy lifting here (negative,
significant), sex and cholesterol don’t add much once age is in the
model. Max heart rate is mostly a function of getting older, not of
these other two variables.

## Question 3: Do age, cholesterol, and blood pressure predict heart disease?

\text{logit}(P(\text{target}=\text{Yes})) = \beta_0 + \beta_1 \cdot
\text{age} + \beta_2 \cdot \text{chol} + \beta_3 \cdot \text{trestbps}

`target` is binary, so this is an example of a logistic regression. In
this case, you need `GLM` instead of `LINEAR_REG`.
[`GLM()`](https://s7-stats.github.io/statim/dev/reference/GLM.md)
defaults to [`stats::gaussian()`](https://rdrr.io/r/stats/family.html)
when no family is set, which isn’t what we want here. Update the
`family` parameter on the lazy loaded execution before
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
runs it:

``` r

heart |>
    define_model(target ~ age + chol + trestbps) |>
    prepare_model(GLM) |> # or prepare_model(GLM, family = binomial())
    update(family = binomial()) |>
    conclude()
```

``` fansi

== Model ======================================================================= 

Variable Mapper : formula 
Args : target ~ age + chol + trestbps 
    left_var : 1 
    right_var : 3 

== Generalized Linear Model ==================================================== 

-- Coefficients ----------------------------------------------------------------

──────────────┬───────────────────────────────────────────
  term        │  estimate  std_error  statistic  p_value  
──────────────┼───────────────────────────────────────────
  (Intercept) │   4.354      1.132      3.846    <0.001   
  age         │   -0.045     0.014     -3.175    <0.001   
  chol        │   -0.001     0.002     -0.585     0.558   
  trestbps    │   -0.010     0.007     -1.453     0.146   
──────────────┴───────────────────────────────────────────


-- Model Fit -------------------------------------------------------------------

─────────────────────────────────────────────────────────────────────────
   family   link   null_deviance  deviance  df_residual    aic    n_obs  
─────────────────────────────────────────────────────────────────────────
  binomial  logit     417.638     399.254       299      407.254   303   
─────────────────────────────────────────────────────────────────────────
```

Or you can just use its one-liner version:

``` r

GLM(target ~ age + chol + trestbps, heart, family = binomial())
```

``` fansi
-- Coefficients ----------------------------------------------------------------

──────────────┬───────────────────────────────────────────
  term        │  estimate  std_error  statistic  p_value  
──────────────┼───────────────────────────────────────────
  (Intercept) │   4.354      1.132      3.846    <0.001   
  age         │   -0.045     0.014     -3.175    <0.001   
  chol        │   -0.001     0.002     -0.585     0.558   
  trestbps    │   -0.010     0.007     -1.453     0.146   
──────────────┴───────────────────────────────────────────


-- Model Fit -------------------------------------------------------------------

─────────────────────────────────────────────────────────────────────────
   family   link   null_deviance  deviance  df_residual    aic    n_obs  
─────────────────────────────────────────────────────────────────────────
  binomial  logit     417.638     399.254       299      407.254   303   
─────────────────────────────────────────────────────────────────────────
```

Interpretation: age comes out as the one reliably associated predictor
here, older patients face higher odds of a positive diagnosis in this
cohort. Cholesterol and resting blood pressure don’t clear significance
on their own once age is accounted for, an easy fact to miss if you
eyeballed `chol` and `trestbps` in isolation.

## Multiple Executions

[`write_models()`](https://s7-stats.github.io/statim/dev/reference/write_models.md)
fits into the model-based pipeline the same way it does the
hypothesis-testing one — see `vignette("htest", package = "statim")`’s
own Multiple Executions section for the mechanics. For regression
specifically, it’s most useful for comparing nested models: adding
predictors one at a time and checking whether the fit earns each one.

### Two layouts, one batch

Question 1 showed `rel(age, trestbps)` and `trestbps ~ age` landing on
the same fit.
[`write_models()`](https://s7-stats.github.io/statim/dev/reference/write_models.md)
lets you see that side by side instead of running the two blocks
separately:

``` r

heart |>
    write_models(
        mod1 = rel(age, trestbps),
        mod2 = trestbps ~ age
    ) |>
    prepare_model(LINEAR_REG) |>
    conclude() |>
    tidy()
```

``` fansi
# A tibble: 2 × 2
  model outs            
  <chr> <named list>    
1 mod1  <tibble [2 × 5]>
2 mod2  <tibble [2 × 5]>
```

### Nested models and `anova()`

Growing a formula with
[`stats::update()`](https://rdrr.io/r/stats/update.html) inside
[`write_models()`](https://s7-stats.github.io/statim/dev/reference/write_models.md)
builds a batch of nested `LINEAR_REG` models in one pipeline, extending
Question 2’s model one predictor at a time:

``` r

heart |>
    write_models(
        m1 = thalach ~ age,
        m2 = update(m1, ~. + sex),
        m3 = update(m2, ~. + chol)
    ) |>
    prepare_model(LINEAR_REG) |>
    conclude() |>
    tidy()
```

``` fansi
# A tibble: 3 × 2
  model outs            
  <chr> <named list>    
1 m1    <tibble [2 × 5]>
2 m2    <tibble [3 × 5]>
3 m3    <tibble [4 × 5]>
```

[`anova()`](https://s7-stats.github.io/statim/dev/reference/anova-mod.md)
dispatches on `<multi_lazy>` directly, so the nested comparison doesn’t
need
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
first:

``` r

heart |>
    write_models(
        m1 = thalach ~ age,
        m2 = update(m1, ~. + sex),
        m3 = update(m2, ~. + chol)
    ) |>
    prepare_model(LINEAR_REG) |>
    anova()
```

``` fansi

== ANOVA · F =================================================================== 

-- ANOVA Table -----------------------------------------------------------------

─────────────────────────────────────────────────────────────
  model  res_df   deviance   df  dev_diff  f_value  p_value  
─────────────────────────────────────────────────────────────
   m1     301    133279.305                                  
   m2     300    132170.377  1   1108.928   2.521    0.113   
   m3     299    131545.082  1   625.295    1.421    0.234   
─────────────────────────────────────────────────────────────
```

Interpretation: consistent with Question 2, adding `sex` barely moves
the fit, and `chol` doesn’t do much better. Age alone is carrying most
of the explanatory weight across all three models.

### Passing arguments across a `GLM` batch

The same nested-model idea applies to `GLM`, only now `family` has to
reach every model in the batch.
[`prepare_model()`](https://s7-stats.github.io/statim/dev/reference/prepare-model.md)’s
`...` forwards into the spec for a
[`write_models()`](https://s7-stats.github.io/statim/dev/reference/write_models.md)
batch, so `family = binomial()` doesn’t need a separate
[`update()`](https://rdrr.io/r/stats/update.html) step:

``` r

heart |>
    write_models(
        g1 = target ~ age,
        g2 = update(g1, ~. + chol),
        g3 = update(g2, ~. + trestbps)
    ) |>
    prepare_model(GLM, family = binomial()) |>
    anova()
```

     [1m [22m [33m! [39m F-test is only valid for Gaussian models.
     [36mℹ [39m Switching to LRT for family  [34m"binomial" [39m.

``` fansi

== ANOVA · LRT ================================================================= 

-- ANOVA Table -----------------------------------------------------------------

───────────────────────────────────────────────────────────────
  model  res_df  deviance  df  dev_diff  chisq_value  p_value  
───────────────────────────────────────────────────────────────
   g1     301    401.861                                       
   g2     300    401.394   1    0.468       0.468      0.494   
   g3     299    399.254   1    2.139       2.139      0.144   
───────────────────────────────────────────────────────────────
```

Interpretation: age alone already does most of the work in Question 3’s
model; adding `chol` and `trestbps` doesn’t buy much more explanatory
power, matching what Question 3’s single model showed once all three
predictors were already in.

### `via()` still applies uniformly

The same caution `vignette("htest", package = "statim")` covers carries
over here:
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md) on a
`<multi_lazy>` sends the same method name and arguments to every model
in the batch, and a variant name is only ever registered for one model
type at a time
([`rel()`](https://s7-stats.github.io/statim/dev/reference/rel.md)’s
registry and `<formula>`’s registry are checked separately — see the
“Where variant names come from” section of
`vignette("recalibration-method", package = "statim")`). A batch that
mixes [`rel()`](https://s7-stats.github.io/statim/dev/reference/rel.md)
and `<formula>` layouts, like the one at the top of this section, needs
any variant passed through
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md) to be
registered for both shapes, or
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md) fails
for whichever model in the batch doesn’t have it, before
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
is even reached.
