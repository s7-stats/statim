# Model evaluator

A function for development use to extract the information in Variable
Mappers.

## Usage

``` r
model_processor(var_id, data = NULL, ...)
```

## Arguments

- var_id:

  The Variable Mappers to be extracted.

- data:

  Optional. Only passed when a certain data structure (normally it's
  data frame) is required.

- ...:

  Passed through S7 method compatibility.

## Value

A named list. The default method returns an empty list; each registered
method returns a list shaped for its `var_id` subclass (for example,
`x_data`/`group_data` for
[`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md), or
`x`/`n` for
[`prop()`](https://s7-stats.github.io/statim/dev/reference/prop.md)).

## Details

Methods accept an optional `data` argument — a data frame, or `NULL` to
resolve variables from the calling environment.
