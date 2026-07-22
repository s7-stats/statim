# Extract contrast coefficients from a null claim

Decomposes the hypothesis into a named numeric vector of coefficients,
one per `param_obj` term, plus the hypothesized scalar value and
operator.

## Usage

``` r
claim_contrast_coefs(claim, filter = NULL)
```

## Arguments

- claim:

  A `null_claim` object.

- filter:

  Optional. The name of a conditioning slot (e.g. `"given"`) that every
  `param_obj` term must supply. If a term's class declares that slot as
  an optional constructor argument (default `NULL`) but the slot is
  unset on the node, an error is raised. If `NULL` (the default), the
  slot to enforce is auto-detected per term by inspecting its class
  constructor's optional formals (those defaulting to `NULL`) and
  requiring the first such slot found.

## Value

A list with fields `coefs`, `scalar`, and `op`.
