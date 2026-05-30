# Declare tidy methods for a stat result

`method_tidy()` collects tidy functions for the base implementation and
any named variants. The `default` function handles results from the base
implementation; additional named arguments handle variant results.

## Usage

``` r
method_tidy(default = NULL, ...)
```

## Arguments

- default:

  A function with signature `function(.x, ...)` for the base
  implementation. Required.

- ...:

  Named functions, one per variant (e.g. `boot =`, `contrast =`). Names
  must match the variant names registered in
  [`agendas()`](https://joshuamarie.github.io/statim/reference/agendas.md).

## Value

A `method_tidy` S7 object.
