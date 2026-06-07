# \`\<model_id\>\` objects

## Rationale

What’s the use of writing new `<model_id>` objects, rather than relying
on the existing `<formula>` (`~`) interface? Why need to write another?
Not all types of inference in R cannot fully manifest `<formula>`
objects. In fact, [ggplot2](https://ggplot2.tidyverse.org) doesn’t fully
manifest `<formula>` objects to describe the shape of the model you want
to visualize within [ggplot2](https://ggplot2.tidyverse.org) pipelines.
The existing `<model_id>` objects from
[statim](https://github.com/s7-stats/statim) shapes the model to be
analyzed in the statistical inference pipelines, which acts like
mappers, just like `ggplot2::aes()`.

The existing `<formula>` objects in R is often used to describe the
relationship between variables. Depending on the implementation, if you
have `y ~ x`, this tells you to describe the relationship of `x` to `y`.
In case you didn’t know yet, `~` is also a function that captures the
code to retrieve and parse its abstract syntax tree (AST).

The current `<model_id>` objects from
[statim](https://github.com/s7-stats/statim) are already evaluated,
unlike `<formula>`, and that’s because of
[`model_processor()`](https://s7-stats.github.io/statim/reference/model-processor.md)
generics which resolves the data you mapped in `<model_id>` objects.

## What are model IDs

The `<model_id>` objects are built at top of S7, serves as “mappers”,
similar to how `ggplot2::aes()` (or aesthetic mappings) works

## Existing objects

[statim](https://github.com/s7-stats/statim) has built-in `<model_id>`
objects you can use to describe the shape of the model you want to
analyze during statistical inference.

## Writing new model IDs

Writing another `<model_id>` objects is easy but strict — requires
[`model_processor()`](https://s7-stats.github.io/statim/reference/model-processor.md)
and
[`model_id_info()`](https://s7-stats.github.io/statim/reference/model_id_info.md)
to be dispatched. The `model_id` is an abstract S7 class used as a
parent class for `<model_id>` object. Without complying these,
[statim](https://github.com/s7-stats/statim) will complain.
