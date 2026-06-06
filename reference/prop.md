# Define a proportion test model

`prop()` creates a `prop` model ID for proportion tests. Both arguments
are scalar constants — expressions are not captured.

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

A `prop` / `model_id` S7 object.

## Examples

``` r
prop(45, 100)
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Model ID : prop 
#> Args : 45 / 100 
```
