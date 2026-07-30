# Structured result container for GLM fits

An S7 class produced by
[GLM](https://s7-stats.github.io/statim/dev/reference/GLM.md) pipelines.
Not constructed manually — use
`define_model() |> prepare_model(GLM) |> conclude()` instead.

Inherits from
[anova_able](https://s7-stats.github.io/statim/dev/reference/anova_able.md),
so it participates in
[`anova()`](https://s7-stats.github.io/statim/dev/reference/anova-mod.md)
directly. Downstream packages can use it as a `parent` in
[`S7::new_class()`](https://rconsortium.github.io/S7/reference/new_class.html).

## Value

An S7 object of class `glm_object` holding the fitted GLM's terms,
coefficients, dispersion, and family information. Not constructed
manually; populated internally by
[GLM](https://s7-stats.github.io/statim/dev/reference/GLM.md).

## Details

Constructor arguments (populated automatically by
[GLM](https://s7-stats.github.io/statim/dev/reference/GLM.md)):

- `terms`: model terms object.

- `df_residual`: residual degrees of freedom.

- `deviance`: scalar deviance.

- `dispersion`: scalar dispersion parameter.

- `family`: string naming the error family, e.g. `"binomial"`.

- `link`: string naming the link function, e.g. `"logit"`.

- `null_deviance`: scalar deviance of the intercept-only model.

- `aic`: scalar AIC.

- `logLik`: scalar log-likelihood of the fitted model.

- `null_logLik`: scalar log-likelihood of the intercept-only model.

- `beta`: named numeric vector of coefficient estimates.

- `std_beta`: named numeric vector of coefficient standard errors.

- `actual`: numeric vector of the original values on the response scale.

- `fitted`: numeric vector of fitted values on the response scale.

- `vcov`: variance-covariance matrix of the coefficients, e.g.
  `stats::vcov(fit)`. Required for
  [`predict()`](https://s7-stats.github.io/statim/dev/reference/predict.md)
  with `interval`.

- `x_mat`: model matrix stored as a flat numeric vector via
  `as.numeric(stats::model.matrix(fit))`. Required for
  [`predict()`](https://s7-stats.github.io/statim/dev/reference/predict.md).

- `x_levels`: factor levels used when fitting, via
  `stats::.getXlevels(fit$terms, stats::model.frame(fit))`. Required for
  [`predict()`](https://s7-stats.github.io/statim/dev/reference/predict.md)
  on new data with factor predictors.

The following are computed automatically and do not need to be supplied:

- `statistic`: per-coefficient test statistics (`beta / std_beta`).

- `p_value`: per-coefficient two-sided p-values. Uses a z-test when
  `family` is `"binomial"` or `"poisson"` (fixed dispersion), and a
  t-test against `df_residual` otherwise (estimated dispersion).

- `coefficients`: tibble with columns `term`, `estimate`, `std_error`,
  `statistic`, `p_value`.

- `fit_summary`: tibble with columns `family`, `link`, `null_deviance`,
  `deviance`, `df_residual`, `aic`, `n_obs`.

## predict() arguments

[`predict()`](https://s7-stats.github.io/statim/dev/reference/predict.md)
on a `class_glm_object` accepts:

- `new_data`: A data frame of new predictors. `NULL` (the default)
  returns fitted values and response-based `truth` for the training
  data.

- `type`: One of `"response"` (default, back-transformed through the
  inverse link) or `"link"` (linear predictor scale).

- `interval`: One of `"none"` (default) or `"confidence"`. Prediction
  intervals are not available, since GLMs have no closed-form analogue
  of OLS prediction error.

- `level`: Confidence level for the interval. Default `0.95`.

## See also

[anova_able](https://s7-stats.github.io/statim/dev/reference/anova_able.md),
[GLM](https://s7-stats.github.io/statim/dev/reference/GLM.md)

## Examples

``` r
# Inheriting from class_glm_object in a downstream package:
my_glm = S7::new_class(
    "my_glm",
    parent = class_glm_object
)

# Populating class_glm_object from a fitted glm (as done internally):
fit = glm(am ~ wt + hp, data = mtcars, family = binomial())
s = summary(fit)
fam = fit$family$family

obj = class_glm_object(
    terms = fit$terms,
    df_residual = fit$df.residual,
    deviance = fit$deviance,
    dispersion = if (fam %in% c("binomial", "poisson")) 1 else s$dispersion,
    family = fam,
    link = fit$family$link,
    null_deviance = fit$null.deviance,
    aic = fit$aic,
    beta = coef(s)[, 1],
    std_beta = coef(s)[, 2],
    actual = unname(fit$y),
    fitted = unname(fit$fitted.values),
    vcov = vcov(fit),
    x_mat = as.numeric(model.matrix(fit)),
    x_levels = .getXlevels(fit$terms, model.frame(fit))
)

obj@coefficients
#> # A tibble: 3 × 5
#>   term        estimate std_error statistic p_value
#>   <chr>          <dbl>     <dbl>     <dbl>   <dbl>
#> 1 (Intercept)  18.9       7.44        2.53 0.0113 
#> 2 wt           -8.08      3.07       -2.63 0.00843
#> 3 hp            0.0363    0.0177      2.04 0.0409 
obj@fit_summary
#> # A tibble: 1 × 7
#>   family   link  null_deviance deviance df_residual   aic n_obs
#>   <chr>    <chr>         <dbl>    <dbl>       <int> <dbl> <int>
#> 1 binomial logit          43.2     10.1          29  16.1    32
```
