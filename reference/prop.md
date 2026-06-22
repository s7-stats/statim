# Define a proportion test model

`prop()` creates a `prop` Variable Mapper for proportion tests. Both
arguments are scalar constants, and this implies the arguments are
expressions that are not captured.

## Usage

``` r
prop(x, n)
```

## Arguments

- x:

  Number of successes. A non-negative integer scalar, `x <= n`.

- n:

  Total number of trials. A positive integer scalar.

## Value

A `prop` / `var_id` S7 object.

## Examples

``` r
prop(45, 100)
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Variable Mapper : prop 
#> Args : 45 / 100 
```
