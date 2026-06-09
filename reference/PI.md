# Proportion of a variable, optionally conditioned on a subgroup

Proportion of a variable, optionally conditioned on a subgroup

## Usage

``` r
PI(x, given = NULL)
```

## Arguments

- x:

  An empty or a bare variable name.

- given:

  An optional filter predicate as a bare expression.

## Value

A `PI` / `param_obj` S7 object.

## Examples

``` r
PI()
#> <param: PI>
#> 
PI(success)
#> <param: PI>
#> 
#> -  x => success
#> 
PI(success, group == "treatment")
#> <param: PI>
#> 
#> -  x     => success
#> -  given => group == "treatment"
#> 
```
