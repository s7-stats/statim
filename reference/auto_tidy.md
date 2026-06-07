# Automatically tidy a statistical result

`auto_tidy()` is the protocol generic for tidying result objects
produced by `fn` in
[`baseline()`](https://s7-stats.github.io/statim/reference/baseline.md)
and
[`variant()`](https://s7-stats.github.io/statim/reference/variant.md).
It is called automatically by
[`tidy()`](https://s7-stats.github.io/statim/reference/tidy.md) when the
result stored in `cld_exec@data` is a
[class_stat_infer](https://s7-stats.github.io/statim/reference/class_stat_infer.md)
subclass.

## Usage

``` r
auto_tidy(x, ...)
```

## Arguments

- x:

  A
  [class_stat_infer](https://s7-stats.github.io/statim/reference/class_stat_infer.md)
  subclass object, typically `cld_exec@data`.

- ...:

  Currently unused. Passed to the dispatched method.

## Value

A tibble.

## Details

Register a method on your output class to participate in the protocol:

    example_out = S7::new_class("example_out", parent = class_stat_infer)

    S7::method(auto_tidy, example_out) = function(x, ...) {
        tibble::tibble(...)
    }

When a variant's `fn` returns the same output class as `baseline`, it
inherits `auto_tidy()` automatically via S7's parent chain. When it
returns a subclass, it can override selectively:

    new_boot_class = S7::new_class("new_boot_class", parent = example_out)

    # override only for boot
    # everything else inherited from `example_out`
    S7::method(auto_tidy, new_boot_class) = function(x, ...) {
        tibble::tibble(...)
    }

If no `auto_tidy()` method is found and no
[`making_tidy()`](https://s7-stats.github.io/statim/reference/making_tidy.md)
entry exists,
[`tidy()`](https://s7-stats.github.io/statim/reference/tidy.md) falls
back to an informative error.

## See also

[`tidy()`](https://s7-stats.github.io/statim/reference/tidy.md),
[`making_tidy()`](https://s7-stats.github.io/statim/reference/making_tidy.md),
[`method_tidy()`](https://s7-stats.github.io/statim/reference/method_tidy.md),
[class_stat_infer](https://s7-stats.github.io/statim/reference/class_stat_infer.md)
