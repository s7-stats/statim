# Validate that param nodes in a claim reference declared model variables

Dispatches on the model ID class. Called inside `attach_claim_to_lazy`
after the compatible-param guard. Default method is a no-op, so model
types that carry no named columns (e.g. `prop`) pass through silently.

## Usage

``` r
validate_claim_vars(model_id, ...)
```

## Arguments

- model_id:

  The model ID object from `lazy@model_id`.

- processed:

  The processed list from `lazy@processed`.

- claims:

  A single `null_claim` or a `null_claims` object.
