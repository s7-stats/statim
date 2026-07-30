# Structured result container for proportion tests

An S7 class produced by
[P_TEST](https://s7-stats.github.io/statim/dev/reference/P_TEST.md)
pipelines using
[`prop()`](https://s7-stats.github.io/statim/dev/reference/prop.md) as
the model ID. Not constructed manually — use the pipeline instead.

Inherits from
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md),
so
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md)
dispatches on it automatically. Downstream packages can use it as a
`parent` in
[`S7::new_class()`](https://rconsortium.github.io/S7/reference/new_class.html).

## Value

An S7 object of class `p_test`, with the properties listed in Details.
Not constructed manually; returned by
[P_TEST](https://s7-stats.github.io/statim/dev/reference/P_TEST.md)
pipelines.

## Details

Slots (populated automatically by
[P_TEST](https://s7-stats.github.io/statim/dev/reference/P_TEST.md)):

- `x`: number of successes (input).

- `n`: number of trials (input).

- `estimate`: observed proportion (`x / n`).

- `statistic`: test statistic. The count `x` for the default binomial;
  the chi-squared value for `"prop"`.

- `p_val`: p-value.

- `lower_ci`: lower confidence bound.

- `upper_ci`: upper confidence bound.

- `ci_level`: confidence level, e.g. `0.95`.

## Shared by variants

Both `default` and `prop` return a `class_p_test`, so
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md)
and [`print()`](https://rdrr.io/r/base/print.html) are inherited by
`prop` for free.

## See also

[P_TEST](https://s7-stats.github.io/statim/dev/reference/P_TEST.md),
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md),
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md)
