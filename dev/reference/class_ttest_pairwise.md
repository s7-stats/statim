# Structured result container for pairwise t-tests

An S7 class produced by
[T_TEST](https://s7-stats.github.io/statim/dev/reference/T_TEST.md)
pipelines using
[`pairwise()`](https://s7-stats.github.io/statim/dev/reference/pairwise.md)
as the variable mapper `<var_id>`. Not constructed manually — use the
pipeline instead.

Inherits from
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md),
so
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md)
dispatches on it automatically. Downstream packages can use it as a
`parent` in
[`S7::new_class()`](https://rconsortium.github.io/S7/reference/new_class.html).

## Value

An S7 object of class `ttest_pairwise`, with the properties listed in
Details. Not constructed manually; returned by
[T_TEST](https://s7-stats.github.io/statim/dev/reference/T_TEST.md)
pipelines using
[`pairwise()`](https://s7-stats.github.io/statim/dev/reference/pairwise.md).

## Details

Slots (populated automatically by
[T_TEST](https://s7-stats.github.io/statim/dev/reference/T_TEST.md)):

- `var1`: first variable in each pair.

- `var2`: second variable in each pair.

- `est`: mean difference per pair (or sample mean for one-sample mode).

- `df`: degrees of freedom per pair.

- `t_stat`: t-statistic per pair.

- `p_value`: p-value per pair.

- `method_name`: scalar string describing the test method, taken
  directly from
  [`stats::t.test()`](https://rdrr.io/r/stats/t.test.html). Must be
  length 1 — all pairs must share the same method.

## One-sample mode

When
[`pairwise()`](https://s7-stats.github.io/statim/dev/reference/pairwise.md)
uses `direction = "eq"`, `var1` and `var2` are identical (each variable
tested against itself). [`print()`](https://rdrr.io/r/base/print.html)
detects this and renders a diagonal-only matrix.

## See also

[T_TEST](https://s7-stats.github.io/statim/dev/reference/T_TEST.md),
[ttest-pairwise](https://s7-stats.github.io/statim/dev/reference/ttest-pairwise.md),
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md),
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md)
