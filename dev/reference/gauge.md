# Effect size for a concluded statistical result

`gauge()` reports the standardized magnitude of an effect — Cohen's d,
partial eta-squared, odds ratio, and similar quantities — as distinct
from
[`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md)'s
raw estimates and the p-value's significance verdict.

## Usage

``` r
gauge(object, ...)
```

## Arguments

- object:

  A `cld_exec` object produced by
  [`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md).

- ...:

  Passed to the dispatched method.

## Value

A tibble with `metric` and `value` columns, one row per effect-size
quantity reported by the underlying result class.

## Dispatch

Same two paths as
[`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md)/`glance()`/[`predict()`](https://s7-stats.github.io/statim/dev/reference/predict.md):

**Path 1:
[`auto_gauge()`](https://s7-stats.github.io/statim/dev/reference/auto_gauge.md)
(preferred).** Called directly when `cld_exec@data` is a
`class_stat_infer` subclass.

**Path 2:
[`making_gauge()`](https://s7-stats.github.io/statim/dev/reference/making_gauge.md)
registry (escape hatch).** Used when a variant's `fn` intentionally
returns a non-`class_stat_infer` object.

## See also

[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md),
[`auto_gauge()`](https://s7-stats.github.io/statim/dev/reference/auto_gauge.md),
[`making_gauge()`](https://s7-stats.github.io/statim/dev/reference/making_gauge.md)
