# Specify variables for independent testing

`on()` creates an `on` Variable Mapper that describes one or more
variables to be tested independently. Expressions are captured
unevaluated, similar to how
[`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html)
captures aesthetics.

## Usage

``` r
on(..., .block = NULL)
```

## Arguments

- ...:

  Bare variable names, tidyselect helpers (requires `data` in
  [`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md)),
  or `I(expr)` for inline data.

- .block:

  Optional. The blocking variable identifying experimental units.
  Accepts a bare name, a tidyselect helper, or `I(expr)` for inline
  data. When supplied, rows are sorted by this variable before injection
  into the test function. Required for tests such as "repeated measures
  ANOVA".

## Value

An `on` / `var_id` S7 object.

## Details

When multiple variables are supplied, the intended test is run once per
variable with no pairwise combinations formed — for that, use
[`pairwise()`](https://s7-stats.github.io/statim/dev/reference/pairwise.md).

The optional `.block` argument identifies the experimental unit (e.g. a
subject ID column). When supplied, rows in the extracted data are
aligned by block before the test is run — this is required for blocked
designs such as the Friedman test where row position encodes block
identity.

## See also

[`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md),
[`rel()`](https://s7-stats.github.io/statim/dev/reference/rel.md),
[`pairwise()`](https://s7-stats.github.io/statim/dev/reference/pairwise.md),
[`prop()`](https://s7-stats.github.io/statim/dev/reference/prop.md)

## Examples

``` r
# Single variable
on(x)
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Variable Mapper : on 
#> Args : x 

# Multiple variables — test on independently
on(a, b, c)
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Variable Mapper : on 
#> Args : a, b, c 

# Multiple variables — With a blocking factor
on(pre, post, followup, .block = subject)
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Variable Mapper : on 
#> Args : pre, post, followup | block: subject 

# Tidyselect (requires data in define_model())
on(where(is.numeric))
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Variable Mapper : on 
#> Args : where(is.numeric) 
```
