# Model evaluator

A function for development use to extract the information in Variable
Mappers.

## Usage

``` r
model_processor(x, data = NULL, ...)
```

## Arguments

- x:

  The Variable Mappers to be extracted.

- data:

  Optional. Only passed when a certain data structure (normally it's
  data frame) is required.

- ...:

  Passed through S7 method compatibility.

## Details

Methods accept an optional `data` argument — a data frame, or `NULL` to
resolve variables from the calling environment.
