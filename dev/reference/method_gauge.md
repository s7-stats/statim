# Declare gauge methods for a stat result

`method_gauge()` is the companion to
[`making_gauge()`](https://s7-stats.github.io/statim/dev/reference/making_gauge.md).
It collects effect-size functions for the base implementation and named
variants, used only when `fn` returns a non-`class_stat_infer` object.

## Usage

``` r
method_gauge(default = NULL, ...)
```

## Arguments

- default:

  A function with signature `function(.x, ...)`, returning a tibble with
  `metric` and `value` columns. Required.

- ...:

  Named functions, one per variant. Names must match variant names
  registered in
  [`agendas()`](https://s7-stats.github.io/statim/dev/reference/agendas.md).
  Omitted variants fall back to `default` automatically.

## Value

A `method_gauge` S7 object.

## See also

[`making_gauge()`](https://s7-stats.github.io/statim/dev/reference/making_gauge.md),
[`auto_gauge()`](https://s7-stats.github.io/statim/dev/reference/auto_gauge.md),
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md)
