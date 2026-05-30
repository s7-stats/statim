# Mean of a variable, optionally conditioned on a subgroup

Mean of a variable, optionally conditioned on a subgroup

## Usage

``` r
MU(x, given = NULL)
```

## Arguments

- x:

  A bare variable name.

- given:

  An optional filter predicate as a bare expression.

## Value

A `MU` / `param_obj` S7 object.

## Examples

``` r
MU(extra)
#> <param: MU>
#> 
#> -  x => extra
#> 
MU(extra, group == "1")
#> <param: MU>
#> 
#> -  x     => extra
#> -  given => group == "1"
#> 
```
