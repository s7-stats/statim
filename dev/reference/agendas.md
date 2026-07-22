# Collect implementations for a statistical procedure

`agendas()` is the container for all implementations of a procedure.
Requires exactly one
[`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md)
and accepts any number of named
[`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md)
objects.

## Usage

``` r
agendas(base, ...)
```

## Arguments

- base:

  A
  [`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md)
  object. Required.

- ...:

  Named
  [`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md)
  objects.

## Value

An `agendas` S3 object.

## See also

[`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md),
[`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md),
[`stat_define()`](https://s7-stats.github.io/statim/dev/reference/stat-infer-definer.md)
