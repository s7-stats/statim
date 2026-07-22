# Define a statistical procedure implementation

`stat_define()` declares a single implementation of a statistical
procedure for a given model type. Multiple `stat_define` objects are
passed to
[`HTEST_FN()`](https://s7-stats.github.io/statim/dev/reference/HTEST_FN.md)
or
[`MODEL_FN()`](https://s7-stats.github.io/statim/dev/reference/MODEL_FN.md)
via `defs`. This is the main extension point for adding new tests or
models.

## Usage

``` r
stat_define(model_type = NULL, impl = NULL, compatible_params = list())

test_define(model_type = NULL, impl = NULL, compatible_params = list())

model_infer_define(model_type = NULL, impl = NULL, compatible_params = list())
```

## Arguments

- model_type:

  A variable mapper `<var_id>` class this implementation handles (e.g.
  `x_by`,
  [`S7::class_formula`](https://rconsortium.github.io/S7/reference/base_s3_classes.html)).

- impl:

  An
  [`agendas()`](https://s7-stats.github.io/statim/dev/reference/agendas.md)
  object collecting all implementations. The `fn` of each
  [`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md)
  and
  [`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md)
  inside receives `.proc` as its first argument. See
  [`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md)
  for the expected signature and
  [`model_processor()`](https://s7-stats.github.io/statim/dev/reference/model-processor.md)
  for the keys available on `.proc` per model type.

- compatible_params:

  A list of S7 param classes (e.g. `list(MU, PI)`) this implementation
  accepts in hypothesis claims. An empty list (the default) disables the
  check entirely. Useful when a test is param-agnostic or the
  restriction has not yet been declared. Applies to every variant in
  `impl`.

## Value

A `stat_define` S7 object.

## See also

[`agendas()`](https://s7-stats.github.io/statim/dev/reference/agendas.md),
[`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md),
[`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md),
[`model_processor()`](https://s7-stats.github.io/statim/dev/reference/model-processor.md),
[`HTEST_FN()`](https://s7-stats.github.io/statim/dev/reference/HTEST_FN.md),
[`MODEL_FN()`](https://s7-stats.github.io/statim/dev/reference/MODEL_FN.md)
