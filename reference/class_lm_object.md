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
coef_tbl = summary(fit)$coefficients
rss = sum(fit$residuals^2)
df_res = fit$df.residual

obj = class_lm_object(
    terms = fit$terms,
    fitted = unname(fit$fitted.values),
    residuals = unname(fit$residuals),
    beta = coef_tbl[, 1],
    std_beta = coef_tbl[, 2],
    df_residual = df_res,
    deviance = rss,
    dispersion = rss / df_res,
    family = "gaussian"
)

# coefficients and fit_summary are computed automatically:
obj@coefficients
#> # A tibble: 2 × 5
#>   term        estimate std_error statistic  p_value
#>   <chr>          <dbl>     <dbl>     <dbl>    <dbl>
#> 1 (Intercept)   -17.6      6.76      -2.60 1.23e- 2
#> 2 speed           3.93     0.416      9.46 1.49e-12
obj@fit_summary
#> # A tibble: 9 × 2
#>   statistic         value
#>   <chr>             <dbl>
#> 1 R Squared      6.51e- 1
#> 2 Adj. R Squared 6.44e- 1
#> 3 Sigma          1.54e+ 1
#> 4 n              5   e+ 1
#> 5 df (residual)  4.8 e+ 1
#> 6 F-statistic    8.96e+ 1
#> 7 df1            1   e+ 0
#> 8 df2            4.8 e+ 1
#> 9 p-value        1.49e-12
```
