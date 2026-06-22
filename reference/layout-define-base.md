# Define a layout supplied by a Variable Mapper

`define_model()` captures a variable mapper `<var_id>` and optional data
into a `def_var` object that can be passed into
[`prepare_test()`](https://s7-stats.github.io/statim/reference/prepare-test.md).

## Usage

``` r
define_model(.x, ...)
```

## Arguments

- .x:

  A variable mapper `<var_id>` object from
  [`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md),
  [`rel()`](https://s7-stats.github.io/statim/reference/rel.md),
  [`pairwise()`](https://s7-stats.github.io/statim/reference/pairwise.md),
  or a formula. It is also dispatched for a data frame class when using
  the data-first pipe style.

- ...:

  Currently unused.

## Value

A `def_var` S3 object containing `var_id` and `processed`.

## Details

Two dispatch methods are available depending on how `.x` is supplied:

- **A "Variable Mapper" first**: `.x` is a Variable Mapper or formula.
  Accepts `data`, a data frame (defaults to
  [`parent.frame()`](https://rdrr.io/r/base/sys.parent.html)).

- **DataFrame-first**: `.x` is a data frame. Accepts `to_analyze`, a
  variable mapper or formula, as the second argument.

## Examples

``` r
# model-ID first
define_model(x_by(extra, group), sleep)
#> 
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Variable Mapper : x_by 
#> Args : extra | group 
#> Other info:
#>     x_vars : 1 
#>     by_vars : 1 
#> Variables :
#>     extra : <dbl [20]> 
#>     group : <fct [20]> 
#> 

# data-frame first (pipe-friendly)
sleep |> define_model(x_by(extra, group))
#> 
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Variable Mapper : x_by 
#> Args : extra | group 
#> Other info:
#>     x_vars : 1 
#>     by_vars : 1 
#> Variables :
#>     extra : <dbl [20]> 
#>     group : <fct [20]> 
#> 
```
