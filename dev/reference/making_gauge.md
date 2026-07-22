# Declare a gauge method for a stat and model type

`making_gauge()` is the escape hatch for registering effect-size methods
when a variant's `fn` intentionally returns a non- `class_stat_infer`
object. When `fn` returns a `class_stat_infer` subclass, implement
[`auto_gauge()`](https://s7-stats.github.io/statim/dev/reference/auto_gauge.md)
on the result class instead — no registration needed.

## Usage

``` r
making_gauge(obj, model_type)
```

## Arguments

- obj:

  A stat function built with
  [`HTEST_FN()`](https://s7-stats.github.io/statim/dev/reference/HTEST_FN.md)
  or
  [`MODEL_FN()`](https://s7-stats.github.io/statim/dev/reference/MODEL_FN.md)
  (e.g. `T_TEST`, `LINEAR_REG`).

- model_type:

  An S7 variable mapper `<var_id>` class, or
  [`S7::class_formula`](https://rconsortium.github.io/S7/reference/base_s3_classes.html).

## Value

A `making_gauge_call` object, consumed by `%<-%`.

## See also

[`auto_gauge()`](https://s7-stats.github.io/statim/dev/reference/auto_gauge.md),
[`method_gauge()`](https://s7-stats.github.io/statim/dev/reference/method_gauge.md),
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md)

## Examples

``` r
# Only needed when fn returns a non-class_stat_infer object.
# Prefer implementing auto_gauge() on your result class instead.
making_gauge(T_TEST, x_by) %<-% method_gauge(
    default = function(.x, ...) { ... }
)
```
