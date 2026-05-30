# Build a model inference function

`MODEL_FN()` is a developer-interface constructor for user-facing model
functions like
[`LINEAR_REG()`](https://joshuamarie.github.io/statim/reference/LINEAR_REG.md).
It returns a function that routes to the correct implementation based on
the model ID and method variant.

## Usage

``` r
MODEL_FN(cls, defs, .name)
```

## Arguments

- cls:

  A string naming the model class, e.g. `"linear_reg"`.

- defs:

  A list of
  [`stat_define()`](https://joshuamarie.github.io/statim/reference/stat-infer-definer.md)
  objects.

- .name:

  A string used as the model title in output.

## Value

A function with signature `function(.model, .data, ...)`.

## See also

[`HTEST_FN()`](https://joshuamarie.github.io/statim/reference/HTEST_FN.md),
[`stat_define()`](https://joshuamarie.github.io/statim/reference/stat-infer-definer.md),
[`prepare_model()`](https://joshuamarie.github.io/statim/reference/prepare-model.md),
[`via()`](https://joshuamarie.github.io/statim/reference/via.md),
[`conclude()`](https://joshuamarie.github.io/statim/reference/conclude.md)
