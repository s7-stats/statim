# Declare an alternative implementation of a test or model

`variant()` declares a named alternative implementation reachable only
via [`via()`](https://joshuamarie.github.io/statim/reference/via.md).
Never runs on the eager path.

## Usage

``` r
variant(fn, print = NULL)
```

## Arguments

- fn:

  A function whose first argument must be `.proc`, the processed model
  output from
  [`model_processor()`](https://joshuamarie.github.io/statim/reference/model-processor.md).
  The keys available on `.proc` depend on the model ID used:

  - `x_by`: `$x_data`, `$group_data`

  - `rel`: `$x_data`, `$resp_data`

  - `pairwise`: `$var_names`, `$pairs`, `$data`

  - `formula`: `$data`, `$vars`, `$formula`

  Try run this to explore the structure:
  `names(model_processor(<model_id>, <data>))`.

    

  Additional named arguments are user-supplied statistical parameters
  (e.g. `.mu`, `.ci`). See
  [`model_processor()`](https://joshuamarie.github.io/statim/reference/model-processor.md)
  for the full `.proc` schema per model type.

      variant(
          fn = function(.proc, n = 1000L, seed = NULL) {
              x = .proc$x_data[[1]]
              group_data = .proc$group_data
              # ...
          }
      )

- print:

  A function with signature `function(x, ...)` for formatting the
  result. `x` is a `cld_exec` object — read your result from `x@data`.
  `NULL` falls back to `print(x@data)`.

      variant(
          fn = function(.proc, ...) { ... },
          print = function(x, ...) {
              dat = x@data
              # render dat
              invisible(x)
          }
      )

## Value

A `variant` S7 object.

## See also

[`baseline()`](https://joshuamarie.github.io/statim/reference/baseline.md),
[`agendas()`](https://joshuamarie.github.io/statim/reference/agendas.md),
[`via()`](https://joshuamarie.github.io/statim/reference/via.md),
[`model_processor()`](https://joshuamarie.github.io/statim/reference/model-processor.md),
`cld_exec`
