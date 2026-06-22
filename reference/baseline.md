# Declare the canonical implementation of a test or model

`baseline()` declares the default implementation of a statistical
procedure. It is always the default and is the only implementation
reachable on the eager path.

## Usage

``` r
baseline(fn, print = NULL, claim_parser = NULL)
```

## Arguments

- fn:

  A function whose first argument must be `.proc`, the processed model
  output from
  [`model_processor()`](https://s7-stats.github.io/statim/reference/model-processor.md).
  The keys available on `.proc` depend on the variable mapper `<var_id>`
  used:

  - `x_by`: `$x_data`, `$group_data`

  - `rel`: `$x_data`, `$resp_data`

  - `pairwise`: `$var_names`, `$pairs`, `$data`

  - `formula`: `$data`, `$vars`, `$formula`

  Try run this to explore the structure:
  `names(model_processor(<var_id>, <data>))`.

    

  Additional named arguments are user-supplied statistical parameters
  (e.g. `.mu`, `.ci`). See
  [`model_processor()`](https://s7-stats.github.io/statim/reference/model-processor.md)
  for the full `.proc` schema per model type.

      baseline(
          fn = function(.proc, .mu = 0, .ci = 0.95) {
              # ...
              <your-own-class>(...)   # return a class_stat_infer subclass
          }
      )

  When `fn` returns a
  [class_stat_infer](https://s7-stats.github.io/statim/reference/class_stat_infer.md)
  subclass,
  [`auto_tidy()`](https://s7-stats.github.io/statim/reference/auto_tidy.md)
  and future `auto_*()` generics dispatch automatically on the result.
  Otherwise, register a tidy method via
  [`making_tidy()`](https://s7-stats.github.io/statim/reference/making_tidy.md).

- print:

  A function with signature `function(x, ...)` for formatting the
  result. `x` is a `cld_exec` object — read your result from `x@data`.
  `NULL` falls back to `print(x@data)`.

- claim_parser:

  A
  [`map_claim()`](https://s7-stats.github.io/statim/reference/map_claim.md)
  object that maps a `null_claim` to named arguments injected into `fn`
  alongside `.proc`. `NULL` (the default) if this implementation does
  not support
  [`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md).

## Value

A `baseline` S7 object.

## See also

[`variant()`](https://s7-stats.github.io/statim/reference/variant.md),
[`agendas()`](https://s7-stats.github.io/statim/reference/agendas.md),
[`stat_define()`](https://s7-stats.github.io/statim/reference/stat-infer-definer.md),
[`model_processor()`](https://s7-stats.github.io/statim/reference/model-processor.md),
[`map_claim()`](https://s7-stats.github.io/statim/reference/map_claim.md),
[class_stat_infer](https://s7-stats.github.io/statim/reference/class_stat_infer.md),
[`auto_tidy()`](https://s7-stats.github.io/statim/reference/auto_tidy.md)
