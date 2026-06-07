# Base class for all statistical result objects

`class_stat_infer` is the base abstract S7 class for all result objects
returned by `fn` in
[`baseline()`](https://s7-stats.github.io/statim/reference/baseline.md)
and
[`variant()`](https://s7-stats.github.io/statim/reference/variant.md).
Concrete result classes like
[class_lm_object](https://s7-stats.github.io/statim/reference/class_lm_object.md)
inherit from it.

## Usage

``` r
class_stat_infer()
```

## Details

Inheriting from `class_stat_infer` is the contract that enables
automatic dispatch for
[`auto_tidy()`](https://s7-stats.github.io/statim/reference/auto_tidy.md),
and future `auto_plot()` and `auto_export()` generics, without any
manual registration via
[`making_tidy()`](https://s7-stats.github.io/statim/reference/making_tidy.md).

## Protocol

Inheriting from `class_stat_infer` is the contract that enables
automatic dispatch for
[`auto_tidy()`](https://s7-stats.github.io/statim/reference/auto_tidy.md),
and future `auto_plot()` and `auto_export()` generics, without any
manual registration via
[`making_tidy()`](https://s7-stats.github.io/statim/reference/making_tidy.md).

When `fn` in
[`baseline()`](https://s7-stats.github.io/statim/reference/baseline.md)
or [`variant()`](https://s7-stats.github.io/statim/reference/variant.md)
returns a `class_stat_infer` subclass,
[`tidy()`](https://s7-stats.github.io/statim/reference/tidy.md) calls
[`auto_tidy()`](https://s7-stats.github.io/statim/reference/auto_tidy.md)
on it automatically. Register a method on your result class to
participate:

    example_out = S7::new_class("example_out", parent = class_stat_infer)

    S7::method(auto_tidy, example_out) = function(x, ...) {
        # return something
    }

## Variant inheritance

A variant whose `fn` returns the same result class as `baseline`
inherits all `auto_*()` methods for free via S7's parent chain. A
variant that returns a subclass overrides only what it needs —
everything else inherits automatically:

    my_result_boot = S7::new_class("my_result_boot", parent = my_result)

    # only auto_tidy() differs
    # all other auto_*() inherited from my_result
    S7::method(auto_tidy, my_result_boot) = function(x, ...) {
        tibble::tibble(...)
    }

## Class hierarchy

The built-in hierarchy is:

    class_stat_infer
        ├── anova_able
        │       └── class_lm_object
        └── <your-own-output-class>
                └── <your-own-subclass>

Downstream packages can extend the hierarchy further by using any
`class_stat_infer` subclass as a `parent` in
[`S7::new_class()`](https://rconsortium.github.io/S7/reference/new_class.html).

## See also

[`baseline()`](https://s7-stats.github.io/statim/reference/baseline.md),
[`variant()`](https://s7-stats.github.io/statim/reference/variant.md),
[`auto_tidy()`](https://s7-stats.github.io/statim/reference/auto_tidy.md),
[class_lm_object](https://s7-stats.github.io/statim/reference/class_lm_object.md)
