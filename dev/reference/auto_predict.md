# Automatically predict from a statistical result

`auto_predict()` is the protocol generic for producing predictions from
result objects produced by `fn` in
[`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md)
and
[`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md).
It is called automatically by
[`predict()`](https://s7-stats.github.io/statim/dev/reference/predict.md)
when the result stored in `cld_exec@data` is a `class_stat_infer`
subclass.

## Usage

``` r
auto_predict(x, new_data = NULL, ...)
```

## Arguments

- x:

  A `class_stat_infer` subclass object, typically `cld_exec@data`.

- new_data:

  A data frame. `NULL` defaults to the training data.

- ...:

  Passed to the dispatched method. Methods typically accept a `new_data`
  argument (a data frame; `NULL` defaults to the training data) plus any
  method-specific options — see the individual result class's
  documentation (e.g.
  [`?class_lm_object`](https://s7-stats.github.io/statim/dev/reference/class_lm_object.md))
  for what it accepts.

## Value

A data frame with at minimum a `.pred` column.

## Details

Register a method on your output class to participate:

    S7::method(auto_predict, my_model_result) = function(x, new_data = NULL, ...) {
        tibble::tibble(.pred = ...)
    }

A variant whose `fn` returns the same result class as `baseline`
inherits `auto_predict()` for free via S7's parent chain.

## See also

[`predict()`](https://s7-stats.github.io/statim/dev/reference/predict.md),
[`making_predict()`](https://s7-stats.github.io/statim/dev/reference/making_predict.md),
[`method_predict()`](https://s7-stats.github.io/statim/dev/reference/method_predict.md),
[class_stat_infer](https://s7-stats.github.io/statim/dev/reference/class_stat_infer.md)
