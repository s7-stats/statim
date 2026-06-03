# Structured result container for two-sample t-tests

An S7 class produced by
[TTEST](https://joshuamarie.github.io/statim/reference/TTEST.md)
pipelines using
[`x_by()`](https://joshuamarie.github.io/statim/reference/x_by.md) as
the model ID. Not constructed manually — use the pipeline instead.

Inherits from
[class_stat_infer](https://joshuamarie.github.io/statim/reference/class_stat_infer.md),
so
[`auto_tidy()`](https://joshuamarie.github.io/statim/reference/auto_tidy.md)
dispatches on it automatically. Downstream packages can use it as a
`parent` in
[`S7::new_class()`](https://rconsortium.github.io/S7/reference/new_class.html).

## Details

Slots (populated automatically by
[TTEST](https://joshuamarie.github.io/statim/reference/TTEST.md)):

- `group`: name of the grouping variable.

- `estimate`: mean difference (or weighted contrast estimate).

- `t_stat`: t-statistic.

- `df`: degrees of freedom.

- `p_val`: p-value.

- `lower_ci`: lower confidence bound.

- `upper_ci`: upper confidence bound.

- `ci_level`: confidence level, e.g. `0.95`.

## Shared by variants

Both `default` and `weighted` return a `class_ttest_two`, so
[`auto_tidy()`](https://joshuamarie.github.io/statim/reference/auto_tidy.md)
and [`print()`](https://rdrr.io/r/base/print.html) are inherited by
`weighted` for free.

## See also

[TTEST](https://joshuamarie.github.io/statim/reference/TTEST.md),
[`auto_tidy()`](https://joshuamarie.github.io/statim/reference/auto_tidy.md),
[class_stat_infer](https://joshuamarie.github.io/statim/reference/class_stat_infer.md)
