# Build a hypothesis test function

`HTEST_FN()` is a developer-interface constructor for user-facing test
functions like
[`T_TEST()`](https://s7-stats.github.io/statim/dev/reference/T_TEST.md).
It returns a function with a consistent signature that routes to the
correct implementation based on the variable mapper `<var_id>` and
method variant.

## Usage

``` r
HTEST_FN(cls, defs, .name)
```

## Arguments

- cls:

  A string naming the test class, e.g. `"ttest"`.

- defs:

  A list of
  [`stat_define()`](https://s7-stats.github.io/statim/dev/reference/stat-infer-definer.md)
  objects.

- .name:

  A string used as the test title in output.

## Value

A function with signature `function(.var_id, .data, ...)`.

## See also

[`MODEL_FN()`](https://s7-stats.github.io/statim/dev/reference/MODEL_FN.md),
[`stat_define()`](https://s7-stats.github.io/statim/dev/reference/stat-infer-definer.md),
[`prepare_test()`](https://s7-stats.github.io/statim/dev/reference/prepare-test.md),
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md),
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
