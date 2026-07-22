# Extract a scalar hypothesis value from a null claim

Rearranges a hypothesis of the form `c * PARAM + d == scalar` by moving
all numeric terms to the right-hand side. Unlike
[`claim_contrast_coefs()`](https://s7-stats.github.io/statim/dev/reference/claim_contrast_coefs.md),
this does not require or validate a linear combination — it is suitable
for single-parameter claims involving any
[param_obj](https://s7-stats.github.io/statim/dev/reference/param_obj.md)
subclass (e.g.
[`MU()`](https://s7-stats.github.io/statim/dev/reference/MU.md),
[`PI()`](https://s7-stats.github.io/statim/dev/reference/PI.md),
[`RHO()`](https://s7-stats.github.io/statim/dev/reference/RHO.md)).

## Usage

``` r
claim_scalar(claim, solve_coef = FALSE)
```

## Arguments

- claim:

  A `null_claim` object.

- solve_coef:

  Logical. If `TRUE`, divides the scalar by the parameter's coefficient
  `c`, fully solving for the parameter value `(scalar - d) / c`. Errors
  if `c == 0`. If `FALSE`, returns `scalar - d` only, leaving `c` on the
  parameter side. Default `FALSE`.

## Value

A list with fields:

- `coefs`:

  Named numeric vector of length 1: the coefficient `c` on the parameter
  term.

- `scalar`:

  Numeric. The resolved scalar value after rearrangement.

- `op`:

  Character. The (possibly flipped) relational operator.

## See also

[`claim_contrast_coefs()`](https://s7-stats.github.io/statim/dev/reference/claim_contrast_coefs.md)
