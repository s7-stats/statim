# Declare per-variant claim translators

`claim_translate()` holds a named set of translator functions, one per
variant name. Use `"default"` for the base (no
[`via()`](https://joshuamarie.github.io/statim/reference/via.md)) case.
At
[`conclude()`](https://joshuamarie.github.io/statim/reference/conclude.md)
time, the active variant name is used to look up the right translator.
If no translator is found for the active variant and a claim is present,
an error is raised immediately.

## Usage

``` r
claim_translate(...)
```

## Arguments

- ...:

  Named translator functions or
  [`map_claim()`](https://joshuamarie.github.io/statim/reference/map_claim.md)
  objects.

## Value

An object of class `"claim_translate"`.
