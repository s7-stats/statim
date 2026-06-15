# State a null hypothesis in the pipeline

`state_null()` captures a hypothesis expression and attaches it to a
`test_lazy` object. Accepts either a single expression or a `more_h0()`
block for multiple named hypotheses.

## Usage

``` r
state_null(.x, ...)
```

## Arguments

- .x:

  A `test_lazy` object from
  [`prepare_test()`](https://s7-stats.github.io/statim/reference/prepare-test.md).

- ...:

  Currently unused.

## Value

The modified `test_lazy` object.

## Slots

- `expr`:

  A hypothesis expression, or a `more_h0()` block. It is passed after
  `prepare_test(...)` to supply the hypothesis expression, e.g.
  `... |> prepare_test(TTEST) |> state_null(expr = MU(x) == 0)`

## Examples

``` r
sleep |>
    define_model(extra %by% group) |>
    prepare_test(TTEST) |>
    state_null(MU(extra) == 0) |>
    conclude()
#> Error in r(claim, processed): T-test for `x_by()` only supports two-sample mean differences.
#> ℹ Found contrast coefficients: 1.
#> ℹ Use `via("contrast")` for weighted/contrast hypotheses,
#> ℹ or use a formula model for one-sample tests.

if (FALSE) { # \dontrun{
sleep |>
    define_model(extra %by% group) |>
    prepare_test(TTEST) |>
    state_null(more_h0(
        h01 = MU(extra) == 2,
        h02 = MU(extra) == 3
    )) |>
    conclude()
} # }
```
