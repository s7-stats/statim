# Extract contrast coefficients from a null claim

Decomposes the hypothesis into a named numeric vector of coefficients,
one per `param_obj` term, plus the hypothesized scalar value and
operator.

## Usage

``` r
claim_contrast_coefs(claim)
```

## Arguments

- claim:

  A `null_claim` object.

## Value

A list with fields `coefs`, `scalar`, and `op`.
