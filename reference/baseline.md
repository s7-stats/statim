# Declare the canonical implementation of a test or model

`baseline()` declares the default implementation of a statistical
procedure. It is always the default and is the only implementation
reachable on the eager path.

## Usage

``` r
baseline(fn, print = NULL)
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

      baseline(
          fn = function(.proc, .mu = 0, .alt = "two.sided", .ci = 0.95) {
              x = .proc$x_data
              group_data = .proc$group_data
              # ...
          }
      )

- print:

  A function with signature `function(x, ...)` for formatting the
  result. `x` is a `cld_exec` object — read your result from `x@data`.
  `NULL` falls back to `print(x@data)`.

      baseline(
          fn = function(.proc, ...) { ... },
          print = function(x, ...) {
              dat = x@data
              # render dat
              invisible(x)
          }
      )

## Value

A `baseline` S7 object.

## See also

[`variant()`](https://joshuamarie.github.io/statim/reference/variant.md),
[`agendas()`](https://joshuamarie.github.io/statim/reference/agendas.md),
[`stat_define()`](https://joshuamarie.github.io/statim/reference/stat-infer-definer.md),
[`model_processor()`](https://joshuamarie.github.io/statim/reference/model-processor.md),
`cld_exec`
