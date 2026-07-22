# Declare predict methods for a stat result

`method_predict()` is the companion to
[`making_predict()`](https://s7-stats.github.io/statim/dev/reference/making_predict.md).
It collects predict functions for the base implementation and named
variants, used only when `fn` returns a non-`class_stat_infer` object.

## Usage

``` r
method_predict(default = NULL, ...)
```

## Arguments

- default:

  A function with signature `function(.x, new_data = NULL, ...)`.
  Required.

- ...:

  Named functions, one per variant. Names must match variant names
  registered in
  [`agendas()`](https://s7-stats.github.io/statim/dev/reference/agendas.md).
  Omitted variants fall back to `default` automatically.

## Value

A `method_predict` S7 object.

## See also

[`making_predict()`](https://s7-stats.github.io/statim/dev/reference/making_predict.md),
[`auto_predict()`](https://s7-stats.github.io/statim/dev/reference/auto_predict.md),
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md)
