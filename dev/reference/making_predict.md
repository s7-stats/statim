# Declare a predict method for a stat and model type

`making_predict()` is the escape hatch for registering predict methods
when a variant's `fn` intentionally returns a non-`class_stat_infer`
object. When `fn` returns a `class_stat_infer` subclass, implement
[`auto_predict()`](https://s7-stats.github.io/statim/dev/reference/auto_predict.md)
on the result class instead — no registration needed.

## Usage

``` r
making_predict(obj, model_type)
```

## Arguments

- obj:

  A stat function built with
  [`MODEL_FN()`](https://s7-stats.github.io/statim/dev/reference/MODEL_FN.md)
  (e.g. `LINEAR_REG`).

- model_type:

  An S7 variable mapper `<var_id>` class, or
  [`S7::class_formula`](https://rconsortium.github.io/S7/reference/base_s3_classes.html).

## Value

A `making_predict_call` object, consumed by `%<-%`.

## See also

[`auto_predict()`](https://s7-stats.github.io/statim/dev/reference/auto_predict.md),
[`method_predict()`](https://s7-stats.github.io/statim/dev/reference/method_predict.md),
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md)

## Examples

``` r
# Only needed when fn returns a non-class_stat_infer object.
# Prefer implementing auto_predict() on your result class instead.
making_predict(LINEAR_REG, S7::class_formula) %<-% method_predict(
    default = function(.x, new_data = NULL, ...) { ... }
)
```
