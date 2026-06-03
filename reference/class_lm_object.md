# Structured result container for linear model fits

An S7 class produced by
[LINEAR_REG](https://joshuamarie.github.io/statim/reference/LINEAR_REG.md)
pipelines. Not constructed manually — use
`define_model() |> prepare_model(LINEAR_REG) |> conclude()` instead.

Inherits from
[anova_able](https://joshuamarie.github.io/statim/reference/anova_able.md),
so it participates in
[`anova()`](https://joshuamarie.github.io/statim/reference/anova-mod.md)
directly. Downstream packages can use it as a `parent` in
[`S7::new_class()`](https://rconsortium.github.io/S7/reference/new_class.html).

## Details

Constructor arguments (populated automatically by
[LINEAR_REG](https://joshuamarie.github.io/statim/reference/LINEAR_REG.md)):

- `terms`: model terms object.

- `df_residual`: residual degrees of freedom.

- `deviance`: scalar deviance.

- `dispersion`: scalar dispersion parameter.

- `family`: always `"gaussian"` for OLS.

- `residuals`: numeric vector of model residuals.

- `coefficients`: data frame with columns `term`, `estimate`,
  `std_error`, `statistic`, `p_value`.

- `fit_summary`: data frame with columns `r_squared`, `adj_r_squared`,
  `sigma`, `df_residual`, `n_obs`.

## anova() protocol

`class_lm_object` participates in
[`anova()`](https://joshuamarie.github.io/statim/reference/anova-mod.md)
directly. The comparison is computed from `@residuals`, `@df_residual`,
and `@terms`.

## See also

[`anova()`](https://joshuamarie.github.io/statim/reference/anova-mod.md),
[LINEAR_REG](https://joshuamarie.github.io/statim/reference/LINEAR_REG.md)

## Examples

``` r
# Inheriting from class_lm_object in a downstream package:
my_lm = S7::new_class(
    "my_lm",
    parent = statim::class_lm_object
)

# Populating class_lm_object from a fitted lm (as done internally):
fit = lm(dist ~ speed, data = cars)
s = summary(fit)
rss = sum(fit$residuals^2)
df_res = fit$df.residual

obj = class_lm_object(
    terms = fit$terms,
    residuals = fit$residuals,
    df_residual = df_res,
    deviance = rss,
    dispersion = rss / df_res,
    family = "gaussian",
    coefficients = tibble::tibble(
        term = rownames(coef(s)),
        estimate = coef(s)[, 1],
        std_error = coef(s)[, 2],
        statistic = coef(s)[, 3],
        p_value = coef(s)[, 4]
    ),
    fit_summary = tibble::tibble(
        r_squared = s$r.squared,
        adj_r_squared = s$adj.r.squared,
        sigma = s$sigma,
        df_residual = as.integer(df_res),
        n_obs = as.integer(length(fit$residuals))
    )
)
```
