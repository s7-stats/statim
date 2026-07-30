# Base class for Variable Mapper objects

`var_id` is the abstract parent class for all Variable Mapper objects in
`{statim}`. Variable Mappers emulate R's formula interface, as they
capture variable expressions without evaluating them, describing the
structure of a statistical model to be passed into a pipeline.

## Value

An S7 abstract class generator. `var_id` cannot be instantiated
directly, so calling it raises an error. It exists only as a parent
class for the concrete Variable Mapper subclasses
([`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md),
[`rel()`](https://s7-stats.github.io/statim/dev/reference/rel.md),
[`pairwise()`](https://s7-stats.github.io/statim/dev/reference/pairwise.md),
[`prop()`](https://s7-stats.github.io/statim/dev/reference/prop.md)).

## Details

Concrete subclasses include
[`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md),
[`rel()`](https://s7-stats.github.io/statim/dev/reference/rel.md), and
[`pairwise()`](https://s7-stats.github.io/statim/dev/reference/pairwise.md).
You cannot instantiate `var_id` directly; use one of its subclasses.

## See also

[`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md),
[`rel()`](https://s7-stats.github.io/statim/dev/reference/rel.md),
[`pairwise()`](https://s7-stats.github.io/statim/dev/reference/pairwise.md),
[`prop()`](https://s7-stats.github.io/statim/dev/reference/prop.md)
