# Structured result container for two-sample t-tests

An S7 class produced by
[T_TEST](https://s7-stats.github.io/statim/dev/reference/T_TEST.md)
pipelines using
[`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md) as
the variable mapper `<var_id>`. Not constructed manually — use the
pipeline instead.

Inherits from
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md),
so
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md)
dispatches on it automatically. Downstream packages can use it as a
`parent` in
[`S7::new_class()`](https://rconsortium.github.io/S7/reference/new_class.html).

## Value

An S7 object of class `ttest_two`, with the properties listed in
Details. Not constructed manually; returned by
[T_TEST](https://s7-stats.github.io/statim/dev/reference/T_TEST.md)
pipelines.

## Details

Slots (populated automatically by
[T_TEST](https://s7-stats.github.io/statim/dev/reference/T_TEST.md)):

- `group`: name of the grouping variable.

- `estimate`: mean difference (or linear contrast estimate).

- `t_stat`: t-statistic.

- `df`: degrees of freedom.

- `p_val`: p-value.

- `lower_ci`: lower confidence bound.

- `upper_ci`: upper confidence bound.

- `ci_level`: confidence level, e.g. `0.95`.

## Shared by variants

Both the default (`base`) and `contrast` return a `class_ttest_two`, so
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md)
and [`print()`](https://rdrr.io/r/base/print.html) are inherited by
`contrast` for free.

## See also

[T_TEST](https://s7-stats.github.io/statim/dev/reference/T_TEST.md),
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md),
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md)
