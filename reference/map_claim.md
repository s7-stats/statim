# Build a claim translator from named resolver functions

`map_claim()` produces a translator function by mapping impl `fn` formal
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
