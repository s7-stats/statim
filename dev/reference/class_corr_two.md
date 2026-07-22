# Structured result container for two-sample t-tests

An S7 class produced by
[COR_TEST](https://s7-stats.github.io/statim/dev/reference/COR_TEST.md)
using [`rel()`](https://s7-stats.github.io/statim/dev/reference/rel.md)
and `<formula>` as the variable mapper `<var_id>`. Not constructed
manually, use the "grammar interface" instead.

Inherits from
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md),
so
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md)
dispatches on it automatically. Downstream packages can use it as a
`parent` in
[`S7::new_class()`](https://rconsortium.github.io/S7/reference/new_class.html).

## Details

Slots (populated automatically by
[COR_TEST](https://s7-stats.github.io/statim/dev/reference/COR_TEST.md)):

- `ind_vars`: name of the independent variables.

- `resp_vars`: name of the response / dependent variables.

- `estimate`: the estimated correlation coefficient.

- `statistic`: t-statistic.

- `df`: degrees of freedom.

- `p_val`: p-value.

- `lower_ci`: lower confidence bound.

- `upper_ci`: upper confidence bound.

- `ci_level`: confidence level, e.g. `0.95`.

## Shared by variants

Both [`rel()`](https://s7-stats.github.io/statim/dev/reference/rel.md)
and `<formula>`'s default (`base`) return a `class_corr_two`, so
different models shares both
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md)
and [`print()`](https://rdrr.io/r/base/print.html) for free.

## See also

[COR_TEST](https://s7-stats.github.io/statim/dev/reference/COR_TEST.md),
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md),
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md)
