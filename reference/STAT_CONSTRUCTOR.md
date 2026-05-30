# Main foundation for inferential statistics

This function is a developer-interface function, a constructor for
user-facing test functions like
[`HTEST_FN()`](https://joshuamarie.github.io/statim/reference/HTEST_FN.md).
It returns a function with a consistent signature that routes to the
correct implementation based on the model ID and method variant.

## Usage

``` r
STAT_CONSTRUCTOR(cls, defs, .name, spec_class)
```

## Arguments

- cls:

  A string naming the test class, e.g. `"ttest"`.

- defs:

  A list of `test_define` objects declaring the implementations.

- .name:

  A string used as the test title in output.

- spec_class:

  Base class of the type of statistical inference. Must be an S7.

## Value

A function with signature `function(.model, .data, ...)`.

## See also

[`test_define()`](https://joshuamarie.github.io/statim/reference/stat-infer-definer.md),
[`prepare_test()`](https://joshuamarie.github.io/statim/reference/prepare-test.md),
[`via()`](https://joshuamarie.github.io/statim/reference/via.md),
[`conclude()`](https://joshuamarie.github.io/statim/reference/conclude.md)
