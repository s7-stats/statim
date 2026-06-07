# Model define constructor

`define_model()` captures a model ID and optional data into a
`def_model` object that can be passed into
[`prepare_test()`](https://s7-stats.github.io/statim/reference/prepare-test.md).

## Usage

``` r
define_model(.x, ...)
```

## Arguments

- .x:

  A model ID object from
  [`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md),
  [`rel()`](https://s7-stats.github.io/statim/reference/rel.md),
  [`pairwise()`](https://s7-stats.github.io/statim/reference/pairwise.md),
  or a formula. It is also dispatched for a data frame class when using
  the data-first pipe style.

- ...:

  Currently unused.

## Value

A `def_model` S3 object containing `model_id` and `processed`.

## Details

Two dispatch methods are available depending on how `.x` is supplied:

- **Model-ID first**: `.x` is a model ID or formula. Accepts `data`, a
  data frame (defaults to
  [`parent.frame()`](https://rdrr.io/r/base/sys.parent.html)).

- **Data-first**: `.x` is a data frame. Accepts `to_analyze`, a model ID
  or formula, as the second argument.

## Examples

``` r
# model-ID first
define_model(x_by(extra, group), sleep)
#> 
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Model ID : x_by 
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
#> Model ID : x_by 
#> Args : extra | group 
#> Other info:
#>     x_vars : 1 
#>     by_vars : 1 
#> Variables :
#>     extra : <dbl [20]> 
#>     group : <fct [20]> 
#> 
```
