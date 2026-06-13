# Recalibrate arguments from the main pipeline

[`update()`](https://rdrr.io/r/stats/update.html) modifies the arguments
of a lazy test pipeline without changing the method variant or engine.

## Arguments

- object:

  A `test_lazy` object.

- ...:

  Named arguments to update.

## Value

The modified `test_lazy` object.

## Examples

``` r
sleep |>
    define_model(extra ~ group) |>
    prepare_test(TTEST) |>
    update(.paired = TRUE) |>
    conclude()
#> Error in inject_and_run(impl = impl, processed = .x@processed, args = all_args): Unknown argument: `.paired`.
#> ℹ Accepted arguments: `.mu`, `.alt`, and `.ci`.
#> ℹ Did you misspell one of the supported arguments?
```
