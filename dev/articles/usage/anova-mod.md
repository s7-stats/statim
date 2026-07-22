# ANOVA for Linear models with {statim}

## What inference am I declaring?

When you fit a linear model with
[statim](https://s7-stats.github.io/statim/), the model is a
`class_lm_object` stored inside a `cld_exec`. Because `class_lm_object`
inherits from `anova_able`, every fitted model knows how to participate
in an ANOVA comparison: it carries the residual degrees of freedom, the
residual sum of squares, the model matrix, and the error family.
[`anova()`](https://s7-stats.github.io/statim/dev/reference/anova-mod.md)
reads those slots directly, so no separate conversion step is needed.

[statim](https://s7-stats.github.io/statim/) supports two distinct ANOVA
questions:

1.  **Single model (Type I)**: how much does each predictor reduce
    residual variance, in the order the terms were added? One row per
    term, plus a Residuals row.

2.  **Multiple models (incremental F or LRT)**: is the extra complexity
    of a larger model justified over a simpler nested model? One row per
    model.

Both questions are answered by the same
[`anova()`](https://s7-stats.github.io/statim/dev/reference/anova-mod.md)
generic, dispatched on whatever object you hand it.

## Single model: Type I ANOVA

The code below follows the standard declarative grammar. Here the `cars`
dataset is used, which ships with base R: `speed` predicts stopping
`dist`.

### Define and fit

``` r

cars_lr = cars |>
    define_model(dist ~ speed) |>
    prepare_model(LINEAR_REG) |>
    conclude()
```

[`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md)
binds the formula to the data and processes it.
`prepare_model(LINEAR_REG)` attaches the linear regression specification
lazily; nothing is computed yet.
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
resolves that specification and returns a `cld_exec` holding a
`class_lm_object`.

### Run the ANOVA

``` r

anova(cars_lr)
```

``` fansi

== ANOVA · Type I ============================================================== 

-- ANOVA Table -----------------------------------------------------------------

─────────────────────────────────────────────────────────
    term     df     ss         ms      f_value  p_value  
─────────────────────────────────────────────────────────
    speed    1   21185.459  21185.459  89.567   <0.001   
  Residuals  48  11353.521   236.532                     
─────────────────────────────────────────────────────────
```

The returned `cld_anova` prints the full Type I table. The final row is
always Residuals, with `f_value` and `p_value` set to `NA`. A small
p-value for `speed` says that adding `speed` to the intercept-only model
significantly reduced the residual variance.

### Tidy the coefficients

[`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md)
takes the `cld_exec` returned by
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
and extracts a tibble of primary results. For a `LINEAR_REG` model, that
tibble is the coefficient table: one row per term, with columns `term`,
`estimate`, `std_error`, `statistic`, and `p_value`.

``` r

cars_lr |> tidy()
```

``` fansi
# A tibble: 2 × 5
  term        estimate std_error statistic  p_value
  <chr>          <dbl>     <dbl>     <dbl>    <dbl>
1 (Intercept)   -17.6      6.76      -2.60 1.23e- 2
2 speed           3.93     0.416      9.46 1.49e-12
```

This is the programmatic form of the Coefficients section that
[`print()`](https://rdrr.io/r/base/print.html) displays. Using
[`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md) is
useful when you need the estimates downstream, for example to filter
significant terms, pass them to another function, or bind rows across
multiple models.

### From a `model_lazy` directly

[`anova()`](https://s7-stats.github.io/statim/dev/reference/anova-mod.md)
also dispatches on `model_lazy`, so
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
is optional:

``` r

cars |>
    define_model(dist ~ speed) |>
    prepare_model(LINEAR_REG) |>
    anova()
```

``` fansi

== ANOVA · Type I ============================================================== 

-- ANOVA Table -----------------------------------------------------------------

─────────────────────────────────────────────────────────
    term     df     ss         ms      f_value  p_value  
─────────────────────────────────────────────────────────
    speed    1   21185.459  21185.459  89.567   <0.001   
  Residuals  48  11353.521   236.532                     
─────────────────────────────────────────────────────────
```

The out is identical as above.

## Multiple models: incremental F-test

Comparing a sequence of nested models tells you whether each additional
predictor improves fit beyond what the simpler model already explains.
This is the main use case for
[`write_models()`](https://s7-stats.github.io/statim/dev/reference/write_models.md).

### Using `write_models()`

[`write_models()`](https://s7-stats.github.io/statim/dev/reference/write_models.md)
accepts named model expressions and evaluates them sequentially against
the same data frame. Names appear as row labels in the ANOVA output:

``` r

LifeCycleSavings |>
    write_models(
        null = sr ~ 1,
        main = sr ~ pop15,
        extend = sr ~ pop15 + pop75,
        full = sr ~ pop15 + pop75 + dpi + ddpi
    ) |>
    prepare_model(LINEAR_REG) |>
    anova()
```

``` fansi

== ANOVA · F =================================================================== 

-- ANOVA Table -----------------------------------------------------------------

────────────────────────────────────────────────────────────
  model   res_df  deviance  df  dev_diff  f_value  p_value  
────────────────────────────────────────────────────────────
   null     49    983.628                                   
   main     48    779.511   1   204.118   14.116   <0.001   
  extend    47    726.168   1    53.343    3.689    0.061   
   full     45    650.713   2    75.455    2.609    0.085   
────────────────────────────────────────────────────────────
```

The first row always has `NA` test statistics because there is no
simpler model to compare it against. Each subsequent row answers: “given
the model above, does adding these extra predictors significantly help?”

The `test` argument accepts `"F"` (default for Gaussian models),
`"LRT"`, or `"Chisq"`. For non-Gaussian families such as binomial GLMs,
`"F"` is automatically switched to `"LRT"` with an informational
message.

### Passing `model_lazy` objects directly

When the models come from separate pipeline branches, pass them directly
to
[`anova()`](https://s7-stats.github.io/statim/dev/reference/anova-mod.md):

``` r

mod1 = LifeCycleSavings |> define_model(sr ~ 1) |> prepare_model(LINEAR_REG)
mod2 = LifeCycleSavings |> define_model(sr ~ pop15) |> prepare_model(LINEAR_REG)
mod3 = LifeCycleSavings |> define_model(sr ~ pop15 + pop75) |> prepare_model(LINEAR_REG)

anova(mod1, mod2, mod3)
```

``` fansi

== ANOVA · F =================================================================== 

-- ANOVA Table -----------------------------------------------------------------

───────────────────────────────────────────────────────────
  model  res_df  deviance  df  dev_diff  f_value  p_value  
───────────────────────────────────────────────────────────
    1      49    983.628                                   
    2      48    779.511   1   204.118   13.211   <0.001   
    3      47    726.168   1    53.343    3.453    0.069   
───────────────────────────────────────────────────────────
```

### Passing `cld_exec` objects

Or, after calling
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
on each model:

``` r

exec1 = LifeCycleSavings |> define_model(sr ~ 1) |> prepare_model(LINEAR_REG) |> conclude()
exec2 = LifeCycleSavings |> define_model(sr ~ pop15) |> prepare_model(LINEAR_REG) |> conclude()

anova(exec1, exec2, test = "LRT")
```

``` fansi

== ANOVA · LRT ================================================================= 

-- ANOVA Table -----------------------------------------------------------------

───────────────────────────────────────────────────────────────
  model  res_df  deviance  df  dev_diff  chisq_value  p_value  
───────────────────────────────────────────────────────────────
    1      49    983.628                                       
    2      48    779.511   1   204.118     12.569     <0.001   
───────────────────────────────────────────────────────────────
```

## Multiple models: `conclude()` and `tidy()`

When the goal is to fit all models and inspect each one,
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
on a `multi_lazy` returns a `multi_exec` collecting all results:

``` r

all_fits = LifeCycleSavings |>
    write_models(
        null = sr ~ 1,
        main = sr ~ pop15 + pop75
    ) |>
    prepare_model(LINEAR_REG) |>
    conclude()

all_fits
```

``` fansi

── 2 models · Linear Regression ──────────────────────────────────────────────── 

null : <cld_exec>
main : <cld_exec>

Use display() to inspect individual results.
```

[`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md) on a
`multi_exec` returns a nested tibble with one row per model:

``` r

tidy(all_fits)
```

``` fansi
# A tibble: 2 × 2
  model outs            
  <chr> <named list>    
1 null  <tibble [1 × 5]>
2 main  <tibble [3 × 5]>
```

Use
[`display()`](https://s7-stats.github.io/statim/dev/reference/display.md)
to inspect individual model outputs when there are many:

``` r

LifeCycleSavings |>
    write_models(
        f1 = sr ~ 1,
        f2 = sr ~ pop15,
        f3 = sr ~ pop15 + pop75
    ) |>
    prepare_model(LINEAR_REG) |>
    conclude() |>
    display(2)
```

``` fansi

1. f1

== Model ======================================================================= 

Variable Mapper : formula 
Args : sr ~ 1 
    left_var : 1 
    right_var : 0 

== Linear Regression =========================================================== 

-- Coefficients ----------------------------------------------------------------

──────────────┬───────────────────────────────────────────
  term        │  estimate  std_error  statistic  p_value  
──────────────┼───────────────────────────────────────────
  (Intercept) │   9.671      0.634     15.263    <0.001   
──────────────┴───────────────────────────────────────────


-- Model Fit -------------------------------------------------------------------
```

    Warning in system("tput cols", intern = TRUE): running command 'tput cols' had
    status 2

``` fansi
-----------------------------------------------------
  R Squared      :    0.00    F-statistic :     NaN
  Adj. R Squared :    0.00    df1         :       0
  Sigma          :    4.48    df2         :      49
  n              :      50    p-value     :     NaN
  df (residual)  :      49                :        
-----------------------------------------------------



2. f2

== Model ======================================================================= 

Variable Mapper : formula 
Args : sr ~ pop15 
    left_var : 1 
    right_var : 1 

== Linear Regression =========================================================== 

-- Coefficients ----------------------------------------------------------------

──────────────┬───────────────────────────────────────────
  term        │  estimate  std_error  statistic  p_value  
──────────────┼───────────────────────────────────────────
  (Intercept) │   17.497     2.280      7.675    <0.001   
  pop15       │   -0.223     0.063     -3.545    <0.001   
──────────────┴───────────────────────────────────────────


-- Model Fit -------------------------------------------------------------------
```

    Warning in system("tput cols", intern = TRUE): running command 'tput cols' had
    status 2

    ------------------------------------------------------
      R Squared      :    0.21    F-statistic :    12.57
      Adj. R Squared :    0.19    df1         :        1
      Sigma          :    4.03    df2         :       48
      n              :      50    p-value     :   <0.001
      df (residual)  :      48                :         
    ------------------------------------------------------

## GLMs: likelihood ratio test

For non-Gaussian families,
[`anova()`](https://s7-stats.github.io/statim/dev/reference/anova-mod.md)
performs a likelihood ratio test (LRT) and reports a chi-squared
statistic instead of an F-statistic. Pass `test = "LRT"` explicitly;
`"F"` is not meaningful for GLMs.

Supply the family directly to
[`prepare_model()`](https://s7-stats.github.io/statim/dev/reference/prepare-model.md).
It is forwarded to every model in the pipeline:

``` r

mtcars |>
    write_models(
        null = am ~ 1,
        main = am ~ wt,
        full = am ~ wt + hp
    ) |>
    prepare_model(GLM, family = binomial()) |>
    anova(test = "LRT")
```

``` fansi

== ANOVA · LRT ================================================================= 

-- ANOVA Table -----------------------------------------------------------------

───────────────────────────────────────────────────────────────
  model  res_df  deviance  df  dev_diff  chisq_value  p_value  
───────────────────────────────────────────────────────────────
  null     31     43.230                                       
  main     30     19.176   1    24.054     24.054     <0.001   
  full     29     10.059   1    9.117       9.117     <0.001   
───────────────────────────────────────────────────────────────
```

The output table has a `chisq_value` column in place of `f_value`. The
first row has `NA` test statistics because there is no baseline to
compare it against.
