# Define a statistical procedure implementation

`stat_define()` declares a single implementation of a statistical
procedure for a given model type. Multiple `stat_define` objects are
passed to
[`HTEST_FN()`](https://joshuamarie.github.io/statim/reference/HTEST_FN.md)
or
[`MODEL_FN()`](https://joshuamarie.github.io/statim/reference/MODEL_FN.md)
via `defs`. This is the main extension point for adding new tests or
models.

## Usage

``` r
stat_define(
  model_type = NULL,
  impl = NULL,
  compatible_params = list(),
  claim_translator = NULL
)

test_define(
  model_type = NULL,
  impl = NULL,
  compatible_params = list(),
  claim_translator = NULL
)

model_infer_define(
  model_type = NULL,
  impl = NULL,
  compatible_params = list(),
  claim_translator = NULL
)
```

## Arguments

- model_type:

  A model ID class this implementation handles (e.g. `x_by`,
  [`S7::class_formula`](https://rconsortium.github.io/S7/reference/base_s3_classes.html)).

- impl:

  An
  [`agendas()`](https://joshuamarie.github.io/statim/reference/agendas.md)
  object collecting all implementations. The `fn` of each
  [`baseline()`](https://joshuamarie.github.io/statim/reference/baseline.md)
  and
  [`variant()`](https://joshuamarie.github.io/statim/reference/variant.md)
  inside receives `.proc` as its first argument. See
  [`baseline()`](https://joshuamarie.github.io/statim/reference/baseline.md)
  for the expected signature and
  [`model_processor()`](https://joshuamarie.github.io/statim/reference/model-processor.md)
  for the keys available on `.proc` per model type.

- compatible_params:

  A list of S7 param classes (e.g. `list(MU, PI)`) this implementation
  accepts in hypothesis claims. An empty list (the default) disables the
  check entirely. Useful when a test is param-agnostic or the
  restriction has not yet been declared.

- claim_translator:

  A `claim_translate` object or function that maps a `ClaimDef` to named
  arguments injected into the implementation alongside `.proc`. `NULL`
  if `write_claim()` is not supported.

## Value

A `stat_define` S7 object.

## See also

[`agendas()`](https://joshuamarie.github.io/statim/reference/agendas.md),
[`baseline()`](https://joshuamarie.github.io/statim/reference/baseline.md),
[`variant()`](https://joshuamarie.github.io/statim/reference/variant.md),
[`model_processor()`](https://joshuamarie.github.io/statim/reference/model-processor.md),
[`HTEST_FN()`](https://joshuamarie.github.io/statim/reference/HTEST_FN.md),
[`MODEL_FN()`](https://joshuamarie.github.io/statim/reference/MODEL_FN.md)
