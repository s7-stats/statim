# Base class for population parameters

`param_obj` is the abstract base S7 class for all population parameter
objects, analogous to
[`var_id()`](https://s7-stats.github.io/statim/dev/reference/var_id.md).
Concrete subclasses (`MU`, `PI`,`RHO`) inherit from it. The base class
is a pure marker — each subclass declares its own properties.

## Usage

``` r
param_obj()
```

## Value

An S7 abstract class generator. `param_obj` cannot be instantiated
directly, so calling it raises an error. It exists only as a parent
class for the concrete parameter classes (`MU`, `PI`, `RHO`).
