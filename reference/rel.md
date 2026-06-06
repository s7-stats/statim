# Describe the relationship between two variables

`rel()` creates a `rel` model ID that reads as "relationship between `x`
and `resp`". Expressions are captured unevaluated, similar to how
`ggplot2::aes()` captures aesthetics.

## Usage

``` r
rel(x, resp)
```

## Arguments

- x:

  The predictor variable. Accepts a bare name, a
  [`c()`](https://rdrr.io/r/base/c.html) of bare names, a tidyselect
  helper (requires `data` in
  [`define_model()`](https://joshuamarie.github.io/statim/reference/model-define-base.md)),
  or `I(expr)` for inline data.

- resp:

  The response variable. Same rules as `x`.

## Value

A `rel` / `model_id` S7 object.

## Examples

``` r
rel(speed, dist)
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Model ID : rel 
#> Args : speed ; dist 
```
