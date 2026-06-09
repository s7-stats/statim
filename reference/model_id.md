# Base class for model ID objects

`model_id` is the abstract parent class for all model ID objects in
`{statim}`. Model IDs emulate R's formula interface, as they capture
variable expressions without evaluating them, describing the structure
of a statistical model to be passed into a pipeline.

## Details

Concrete subclasses include
[`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md),
[`rel()`](https://s7-stats.github.io/statim/reference/rel.md), and
[`pairwise()`](https://s7-stats.github.io/statim/reference/pairwise.md).
You cannot instantiate `model_id` directly; use one of its subclasses.

## See also

[`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md),
[`rel()`](https://s7-stats.github.io/statim/reference/rel.md),
[`pairwise()`](https://s7-stats.github.io/statim/reference/pairwise.md),
[`prop()`](https://s7-stats.github.io/statim/reference/prop.md)
