# Extract the hypothesized scalar value from a null claim

Rearranges the hypothesis by moving all `param_obj` terms to the left
and all scalar terms to the right. Returns the resulting scalar and the
(possibly flipped) operator.

## Usage

``` r
claim_scalar_diff(claim)
```

## Arguments

- claim:

  A `null_claim` object.

## Value

A list with fields `scalar` and `op`.

## Details

Only handles linear combinations of parameters.
