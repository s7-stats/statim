# Build a claim parser from named resolver functions

`map_claim()` produces a parser function by mapping impl `fn` formal
names to resolver functions. Each resolver receives `(claim, processed)`
and returns the value for its argument. Resolvers that only need `claim`
can simply ignore `processed`.

## Usage

``` r
map_claim(...)
```

## Arguments

- ...:

  Named resolver functions. Names must match formals of the impl's `fn`.
  Each resolver has signature `function(claim, processed)`.

## Value

A function of class `"map_claim"` with signature
`function(claim, processed)`.

## Details

Pass the result as `claim_parser` to
[`baseline()`](https://s7-stats.github.io/statim/dev/reference/baseline.md)
or
[`variant()`](https://s7-stats.github.io/statim/dev/reference/variant.md).
A variant without a `claim_parser` simply does not support
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md);
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
raises an error if a claim was stated but the active variant has none.
