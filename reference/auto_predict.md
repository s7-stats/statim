# Automatically predict from a statistical result

`auto_predict()` is the protocol generic for producing predictions from
result objects produced by `fn` in
[`baseline()`](https://s7-stats.github.io/statim/reference/baseline.md)
and
[`variant()`](https://s7-stats.github.io/statim/reference/variant.md).
It is called automatically by
[`predict()`](https://s7-stats.github.io/statim/reference/predict.md)
when the result stored in `cld_exec@data` is a `class_stat_infer`
subclass.

## Usage

``` r
auto_predict(x, ...)
```

## Arguments

- x:

  A `class_stat_infer` subclass object, typically `cld_exec@data`.

- ...:

  Currently unused. Passed to the dispatched method.

- new_data:

  A data frame. `NULL` defaults to the training data.

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

[`predict()`](https://s7-stats.github.io/statim/reference/predict.md),
[`making_predict()`](https://s7-stats.github.io/statim/reference/making_predict.md),
[`method_predict()`](https://s7-stats.github.io/statim/reference/method_predict.md),
[class_stat_infer](https://s7-stats.github.io/statim/reference/class_stat_infer.md)
