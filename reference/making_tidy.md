# Declare tidy methods for a stat and model type

`making_tidy()` is the escape hatch for registering tidy methods when a
variant's `fn` intentionally returns a
non-[class_stat_infer](https://s7-stats.github.io/statim/reference/class_stat_infer.md)
object (plain list, S3, S4, or R6). When `fn` returns a
[class_stat_infer](https://s7-stats.github.io/statim/reference/class_stat_infer.md)
subclass, implement
[`auto_tidy()`](https://s7-stats.github.io/statim/reference/auto_tidy.md)
on the result class instead — no registration needed.

## Usage

``` r
making_tidy(obj, model_type)
```

## Arguments

- obj:

  A stat function built with
  [`HTEST_FN()`](https://s7-stats.github.io/statim/reference/HTEST_FN.md)
  or
  [`MODEL_FN()`](https://s7-stats.github.io/statim/reference/MODEL_FN.md)
  (e.g. `TTEST`).

- model_type:

  An S7 variable mapper `<var_id>` class (e.g. `x_by`,
  [`S7::class_formula`](https://rconsortium.github.io/S7/reference/base_s3_classes.html)).

## Value

A `making_tidy_call` object, consumed by `%<-%`.

## See also

[`auto_tidy()`](https://s7-stats.github.io/statim/reference/auto_tidy.md),
[`method_tidy()`](https://s7-stats.github.io/statim/reference/method_tidy.md),
[class_stat_infer](https://s7-stats.github.io/statim/reference/class_stat_infer.md)

## Examples

``` r
# Only needed when fn returns a non-class_stat_infer object.
# Prefer implementing auto_tidy() on your result class instead.
making_tidy(TTEST, x_by) %<-% method_tidy(
    default = function(.x, ...) { ... },
    boot = function(.x, ...) { ... }
)
```
