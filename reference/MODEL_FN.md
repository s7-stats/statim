# Build a model inference function

`MODEL_FN()` is a developer-interface constructor for user-facing model
functions like
[`LINEAR_REG()`](https://s7-stats.github.io/statim/reference/LINEAR_REG.md).
It returns a function that routes to the correct implementation based on
the variable mapper `<var_id>` and method variant.

## Usage

``` r
MODEL_FN(cls, defs, .name)
```

## Arguments

- cls:

  A string naming the model class, e.g. `"linear_reg"`.

- defs:

  A list of
  [`stat_define()`](https://s7-stats.github.io/statim/reference/stat-infer-definer.md)
  objects.

- .name:

  A string used as the model title in output.

## Value

A function with signature `function(.var_id, .data, ...)`.

## See also

[`HTEST_FN()`](https://s7-stats.github.io/statim/reference/HTEST_FN.md),
[`stat_define()`](https://s7-stats.github.io/statim/reference/stat-infer-definer.md),
[`prepare_model()`](https://s7-stats.github.io/statim/reference/prepare-model.md),
[`via()`](https://s7-stats.github.io/statim/reference/via.md),
[`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md)
