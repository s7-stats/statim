# Automatically gauge effect size from a statistical result

`auto_gauge()` is the protocol generic for computing effect-size
quantities from result objects produced by `fn` in
[`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md)
and
[`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md).
It is called automatically by
[`gauge()`](https://s7-stats.github.io/statim/dev/reference/gauge.md)
when the result stored in `cld_exec@data` is a `class_stat_infer`
subclass.

## Usage

``` r
auto_gauge(x, ...)
```

## Arguments

- x:

  A `class_stat_infer` subclass object, typically `cld_exec@data`.

- ...:

  Currently unused. Passed to the dispatched method.

## Value

A tibble with `metric` and `value` columns, one row per effect-size
quantity.

## Details

Register a method on your output class to participate:

    S7::method(auto_gauge, my_test_result) = function(x, ...) {
        tibble::tibble(metric = "cohens_d", value = ...)
    }

A variant whose `fn` returns the same result class as `baseline`
inherits `auto_gauge()` for free via S7's parent chain.

## See also

[`gauge()`](https://s7-stats.github.io/statim/dev/reference/gauge.md),
[`making_gauge()`](https://s7-stats.github.io/statim/dev/reference/making_gauge.md),
[`method_gauge()`](https://s7-stats.github.io/statim/dev/reference/method_gauge.md),
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md)
