# Base class for population parameters

`param_obj` is the base S7 class for all population parameter objects,
analogous to
[`model_id()`](https://joshuamarie.github.io/statim/reference/model_id.md).
Concrete subclasses (`MU`, `PI`, `SIGMA`, `RHO`) inherit from it. The
base class is a pure marker — each subclass declares its own properties.

## Usage

``` r
param_obj()
```
