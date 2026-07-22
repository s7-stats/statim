# Protocol class for ANOVA participation

Any model result container that should participate in
[`anova()`](https://s7-stats.github.io/statim/dev/reference/anova-mod.md)
must inherit from `anova_able`. Subclasses fill the four required slots;
`build_anova()` reads only those slots and dispatches the test statistic
computation on `@family`.

## Usage

``` r
anova_able(
  terms = NULL,
  df_residual = integer(0),
  deviance = integer(0),
  dispersion = integer(0),
  family = "gaussian"
)
```

## Slots

- `terms`:

  The model terms object. Used to verify response consistency.

- `df_residual`:

  Residual degrees of freedom.

- `deviance`:

  Scalar deviance measure. For Gaussian LMs this is the residual sum of
  squares. For GLMs this is the model deviance from
  [`stats::deviance()`](https://rdrr.io/r/stats/deviance.html).

- `dispersion`:

  Scalar dispersion parameter. For Gaussian LMs this is `sigma^2`
  (`rss / df_residual`). For GLMs with a known dispersion (binomial,
  Poisson) set to `1`. For quasi-families use the estimated Pearson
  dispersion.

- `family`:

  A string identifying the error family, e.g. `"gaussian"`,
  `"binomial"`, `"poisson"`. Used by `build_anova()` to select the
  correct test statistic. Must be consistent across all models passed to
  a single
  [`anova()`](https://s7-stats.github.io/statim/dev/reference/anova-mod.md)
  call.

## See also

[`anova()`](https://s7-stats.github.io/statim/dev/reference/anova-mod.md)
