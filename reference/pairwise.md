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
  [`define_model()`](https://joshuamarie.github.io/statim/reference/model-define-base.md)),
  or `I(expr)` for inline data.

- direction:

  A string controlling which pairs are kept. One of:

  - `"lt"` (default): keep pairs where `name_a` comes before `name_b`
    alphabetically (i.e. unique unordered pairs).

  - `"lteq"`, `"gt"`, `"gteq"`: ordered variants.

  - `"eq"`: keep only self-pairs.

  - `"neq"`: drop self-pairs, keep all others.

  - `"all"`: keep every combination.

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
