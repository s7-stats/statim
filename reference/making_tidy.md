# Declare tidy methods for a stat and model type

`making_tidy()` is used as the left-hand side of the `%<-%` operator to
register a
[`method_tidy()`](https://joshuamarie.github.io/statim/reference/method_tidy.md)
for a stat function and model type.

## Usage

``` r
making_tidy(obj, model_type)
```

## Arguments

- obj:

  A stat function built with
  [`HTEST_FN()`](https://joshuamarie.github.io/statim/reference/HTEST_FN.md)
  or
  [`MODEL_FN()`](https://joshuamarie.github.io/statim/reference/MODEL_FN.md)
  (e.g. `TTEST`). Used to scope the registry key.

- model_type:

  An S7 model ID class (e.g. `x_by`,
  [`S7::class_formula`](https://rconsortium.github.io/S7/reference/base_s3_classes.html)).

## Value

A `making_tidy_call` object, consumed by `%<-%`.

## Examples

``` r
making_tidy(TTEST, x_by) %<-% method_tidy(
    default = function(.x, ...) { ... },
    boot = function(.x, ...) { ... }
)
```
