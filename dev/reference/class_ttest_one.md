# Structured result container for one-sample t-tests

An S7 class produced by
[T_TEST](https://s7-stats.github.io/statim/dev/reference/T_TEST.md)
pipelines using
[`on()`](https://s7-stats.github.io/statim/dev/reference/on.md) as the
variable mapper `<var_id>`. Not constructed manually — use the pipeline
instead.

Inherits from
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md),
so
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md)
dispatches on it automatically. Downstream packages can use it as a
`parent` in
[`S7::new_class()`](https://rconsortium.github.io/S7/reference/new_class.html).

## Value

An S7 object of class `ttest_one`, with the properties listed in
Details. Not constructed manually; returned by
[T_TEST](https://s7-stats.github.io/statim/dev/reference/T_TEST.md)
pipelines.

## Details

Slots (populated automatically by
[T_TEST](https://s7-stats.github.io/statim/dev/reference/T_TEST.md)):

- `term`: name of the tested variable.

- `estimate`: sample mean.

- `true_mu`: hypothesized mean as written in the claim. Falls back to
  `.mu` when no
  [`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md)
  claim is supplied.

- `statistic`: t-statistic.

- `p_val`: p-value.

- `lower_ci`: lower confidence bound.

- `upper_ci`: upper confidence bound.

- `ci_level`: confidence level, e.g. `0.95`.

## Shared by variants

Both `base` and `multi` return a `class_ttest_one`, so
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md)
and [`print()`](https://rdrr.io/r/base/print.html) are inherited by
`multi` for free.

## See also

[T_TEST](https://s7-stats.github.io/statim/dev/reference/T_TEST.md),
[ttest-on](https://s7-stats.github.io/statim/dev/reference/ttest-on.md),
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md),
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md)
