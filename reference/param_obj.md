# Base class for population parameters

`param_obj` is the abstract base S7 class for all population parameter
objects, analogous to
[`var_id()`](https://s7-stats.github.io/statim/reference/var_id.md).
Concrete subclasses (`MU`, `PI`,`RHO`) inherit from it. The base class
is a pure marker — each subclass declares its own properties.

## Usage

``` r
param_obj()
```
