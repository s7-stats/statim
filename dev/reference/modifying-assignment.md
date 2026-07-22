# Apply a method_tidy to a making_tidy target

`%<-%` registers a
[`method_tidy()`](https://s7-stats.github.io/statim/dev/reference/method_tidy.md)
into the tidy registry. The left-hand side must be a
[`making_tidy()`](https://s7-stats.github.io/statim/dev/reference/making_tidy.md)
call.

## Usage

``` r
lhs %<-% rhs
```

## Arguments

- lhs:

  A `making_tidy_call` object from
  [`making_tidy()`](https://s7-stats.github.io/statim/dev/reference/making_tidy.md).

- rhs:

  A
  [`method_tidy()`](https://s7-stats.github.io/statim/dev/reference/method_tidy.md)
  object.

## Value

`NULL` invisibly, called for its side effects.

## Examples

``` r
making_tidy(T_TEST, x_by) %<-% method_tidy(
    default = function(.x, ...) { ... },
    boot = function(.x, ...) { ... }
)
```
