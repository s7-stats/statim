# Predict from a concluded statistical result

`predict()` estimates the response for new or existing rows from a
`cld_exec` object produced by
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md).

## Usage

``` r
predict(object, new_data = NULL, ..., check_type = TRUE)
```

## Format

An object of class `S7_external_generic` of length 4.

## Arguments

- object:

  A `cld_exec` object produced by
  [`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md).

- new_data:

  A data frame (or subclass, e.g. `tibble`, `data.table`). `NULL` (the
  default) uses the training data.

- ...:

  Passed to the dispatched method.

- check_type:

  Check whether the returned output is a data frame. If `TRUE`,
  `predict()` is enforcing the dispatched returned output to be a data
  frame. Default is `TRUE`.

## Value

A data frame (specifically a `tibble`) with `.pred`, `truth` when a
response is available, and `.pred_lower`/`.pred_upper` when an interval
was requested. Always inherits `data.frame`, regardless of which method
produced it.

## Dispatch

Dispatches on `object` only, consistent with how
[`stats::predict`](https://rdrr.io/r/stats/predict.html) itself works as
a single-dispatch S3 generic. `new_data`'s shape is validated at the top
of the method body rather than through a second S7 dispatch argument —
an S7 method can't reliably distinguish "argument omitted entirely" from
"argument explicitly NULL" when layered on top of a legacy S3 generic,
so validating inside the body is both simpler and actually correct.

Two paths are tried in order:

**Path 1:
[`auto_predict()`](https://s7-stats.github.io/statim/dev/reference/auto_predict.md)
(preferred).** Called directly when `cld_exec@data` is a
`class_stat_infer` subclass.

**Path 2:
[`making_predict()`](https://s7-stats.github.io/statim/dev/reference/making_predict.md)
registry (escape hatch).** Used when a variant's `fn` intentionally
returns a non-`class_stat_infer` object.

## See also

[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md),
[`auto_predict()`](https://s7-stats.github.io/statim/dev/reference/auto_predict.md),
[`making_predict()`](https://s7-stats.github.io/statim/dev/reference/making_predict.md)
