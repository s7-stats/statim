# Declare an alternative implementation of a test or model

`variant()` declares a named alternative implementation reachable only
via [`via()`](https://s7-stats.github.io/statim/reference/via.md). Never
runs on the eager path.

## Usage

``` r
variant(fn, print = NULL)
```

## Arguments

- fn:

  A function whose first argument must be `.proc`, the processed model
  output from
  [`model_processor()`](https://s7-stats.github.io/statim/reference/model-processor.md).
  The keys available on `.proc` depend on the model ID used:

  - `x_by`: `$x_data`, `$group_data`

  - `rel`: `$x_data`, `$resp_data`

  - `pairwise`: `$var_names`, `$pairs`, `$data`

  - `formula`: `$data`, `$vars`, `$formula`

  Try run this to explore the structure:
  `names(model_processor(<model_id>, <data>))`.

    

  Additional named arguments are user-supplied statistical parameters
  (e.g. `.mu`, `.ci`). See
  [`model_processor()`](https://s7-stats.github.io/statim/reference/model-processor.md)
  for the full `.proc` schema per model type.

      variant(
          fn = function(.proc, n = 1000L, seed = NULL) {
              x = .proc$x_data[[1]]
              group_data = .proc$group_data
              # ...
          }
      )

  A variant whose `fn` returns the same
  [class_stat_infer](https://s7-stats.github.io/statim/reference/class_stat_infer.md)
  subclass as `baseline` inherits
  [`auto_tidy()`](https://s7-stats.github.io/statim/reference/auto_tidy.md)
  and all future `auto_*()` methods automatically via S7's parent chain.
  A variant returning a subclass can override selectively:

      # inherits `auto_tidy()` from `new_out` S7 class
      variant(fn = function(.proc, ...) { new_out(...) })

      # overrides auto_tidy() via subclass
      variant(fn = function(.proc, ...) { new_out_boot(...) })

      # intentionally plain
      variant(fn = function(.proc, ...) { list(...) })

- print:

  A function with signature `function(x, ...)`. `x` is a `cld_exec`
  object. `NULL` falls back to `print(x@data)`.

## Value

A `variant` S7 object.

## See also

[`baseline()`](https://s7-stats.github.io/statim/reference/baseline.md),
[`agendas()`](https://s7-stats.github.io/statim/reference/agendas.md),
[`via()`](https://s7-stats.github.io/statim/reference/via.md),
[`model_processor()`](https://s7-stats.github.io/statim/reference/model-processor.md),
[class_stat_infer](https://s7-stats.github.io/statim/reference/class_stat_infer.md),
[`auto_tidy()`](https://s7-stats.github.io/statim/reference/auto_tidy.md)
