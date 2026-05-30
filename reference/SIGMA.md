# Variance of a variable, optionally conditioned on a subgroup

Variance of a variable, optionally conditioned on a subgroup

## Usage

``` r
SIGMA(x, given = NULL)
```

## Arguments

- x:

  A bare variable name.

- given:

  An optional filter predicate as a bare expression.

## Value

A `SIGMA` / `param_obj` S7 object.

## Examples

``` r
SIGMA(score)
#> <param: SIGMA>
#> 
#> -  x => score
#> 
SIGMA(score, group == "control")
#> <param: SIGMA>
#> 
#> -  x     => score
#> -  given => group == "control"
#> 
```
