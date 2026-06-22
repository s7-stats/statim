# Compare a variable by group

`x_by()` (and its infix alias `%by%`) creates an `x_by` Variable Mapper
that reads as "compare `x` by `group`". Expressions are captured
unevaluated, similar to how `ggplot2::aes()` captures aesthetics.

## Usage

``` r
x_by(x, group)

x %by% group
```

## Arguments

- x:

  The response variable. Accepts a bare name, a
  [`c()`](https://rdrr.io/r/base/c.html) of bare names, a tidyselect
  helper (requires `data` in
  [`define_model()`](https://s7-stats.github.io/statim/reference/layout-define-base.md)),
  or `I(expr)` for inline data.

- group:

  The grouping variable. Same rules as `x`.

## Value

An `x_by` / `var_id` S7 object.

## Examples

``` r
# Bare names — resolved later from the data or environment
x_by(extra, group)
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Variable Mapper : x_by 
#> Args : extra | group 

# Infix alias: identical to x_by(extra, group)
extra %by% group
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Variable Mapper : x_by 
#> Args : extra | group 

# Inline data via I()
x_by(I(rnorm(30)), I(rep(c("a", "b"), each = 15)))
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Variable Mapper : x_by 
#> Args : <inline> | <inline> 

# Named inline data
x_by(I(score = rnorm(30)), I(grp = rep(c("a", "b"), each = 15)))
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Variable Mapper : x_by 
#> Args : <inline> | <inline> 
```
