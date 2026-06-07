# Structured result container for GLM fits

An S7 class produced by
[GLM](https://s7-stats.github.io/statim/reference/GLM.md) pipelines. Not
constructed manually — use
`define_model() |> prepare_model(GLM) |> conclude()` instead.

Inherits from
[anova_able](https://s7-stats.github.io/statim/reference/anova_able.md),
so it participates in
[`anova()`](https://s7-stats.github.io/statim/reference/anova-mod.md)
directly. Downstream packages can use it as a `parent` in
[`S7::new_class()`](https://rconsortium.github.io/S7/reference/new_class.html).

## Details

Constructor arguments (populated automatically by
[GLM](https://s7-stats.github.io/statim/reference/GLM.md)):

- `terms`: model terms object.

- `df_residual`: residual degrees of freedom.

- `deviance`: scalar deviance.

- `dispersion`: scalar dispersion parameter.

- `family`: string naming the error family, e.g. `"binomial"`.

- `coefficients`: data frame with columns `term`, `estimate`,
  `std_error`, `statistic`, `p_value`.

- `fit_summary`: data frame with columns `family`, `link`,
  `null_deviance`, `deviance`, `df_residual`, `aic`, `n_obs`.

## See also

[anova_able](https://s7-stats.github.io/statim/reference/anova_able.md),
[GLM](https://s7-stats.github.io/statim/reference/GLM.md)

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
    coefficients = tibble::tibble(
        term = rownames(coef(s)),
        estimate = coef(s)[, 1],
        std_error = coef(s)[, 2],
        statistic = coef(s)[, 3],
        p_value = coef(s)[, 4]
    ),
    fit_summary = tibble::tibble(
        family = fam,
        link = fit$family$link,
        null_deviance = fit$null.deviance,
        deviance = fit$deviance,
        df_residual = as.integer(fit$df.residual),
        aic = fit$aic,
        n_obs = as.integer(length(fit$residuals))
    )
)
```
