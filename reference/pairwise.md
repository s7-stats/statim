# Define all pairwise variable combinations

`pairwise()` creates a `pairwise` model ID from a set of variables,
producing all unique variable pairs. Use `direction` to control which
pairs are retained. Pairs are filtered by lexicographic (alphabetical)
ordering of variable names.

## Usage

``` r
pairwise(..., direction = "lt")
```

## Arguments

- ...:

  Bare variable names, tidyselect helpers (requires `data` in
  [`define_model()`](https://s7-stats.github.io/statim/reference/model-define-base.md)),
  or `I(expr)` for inline data.

- direction:

  A string controlling which pairs are kept:

  - `"lt"` (default): strict lower triangle, i.e. pairs where index(x)
    \< index(y)

  - `"lteq"`: lower triangle including the diagonal (x \<= y)

  - `"gt"`: strict upper triangle (x \> y)

  - `"gteq"`: upper triangle including the diagonal (x \>= y)

  - `"eq"`: diagonal only (x == y), i.e. each variable paired with
    itself

  - `"neq"`: all pairs except the diagonal (x != y)

  - `"all"`: all combinations including both directions and the diagonal

## Value

A `pairwise` / `model_id` S7 object.

## Examples

``` r
pairwise(a, b, c)
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Model ID : pairwise 
#> Args : a, b, c 

# Inline data
pairwise(I(rnorm(30)), I(rnorm(30)), I(rnorm(30)))
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Model ID : pairwise 
#> Args : <inline>, <inline>, <inline> 

# Keep all ordered pairs
pairwise(a, b, c, direction = "all")
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Model ID : pairwise 
#> Args : a, b, c 
```
