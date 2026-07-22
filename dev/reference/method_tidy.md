# Declare tidy methods for a stat result

`method_tidy()` is the companion to
[`making_tidy()`](https://s7-stats.github.io/statim/dev/reference/making_tidy.md).
It collects tidy functions for the base implementation and named
variants, used only when `fn` returns a
non-[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md)
object.

## Usage

``` r
method_tidy(default = NULL, ...)
```

## Arguments

- default:

  A function with signature `function(.x, ...)`. Required.

- ...:

  Named functions, one per variant. Names must match variant names
  registered in
  [`agendas()`](https://s7-stats.github.io/statim/dev/reference/agendas.md).
  Omitted variants fall back to `default` automatically.

## Value

A `method_tidy` S7 object.

## See also

[`making_tidy()`](https://s7-stats.github.io/statim/dev/reference/making_tidy.md),
[`auto_tidy()`](https://s7-stats.github.io/statim/dev/reference/auto_tidy.md),
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md)
