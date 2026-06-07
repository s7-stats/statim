# \`\<model_id\>\` objects

## Rationale

What’s the use of writing new `<model_id>` objects, rather than relying
on the existing `<formula>` (`~`) interface? Why need to write another?
Not all types of inference in R cannot fully manifest `<formula>`
objects. In fact, [ggplot2](https://ggplot2.tidyverse.org) doesn’t fully
manifest `<formula>` objects to specify the variables you want to
visualize. The existing `<model_id>` objects from
[statim](https://github.com/s7-stats/statim) shapes the model to be
analyzed in the statistical inference pipelines, which acts like
mappers, just like `ggplot2::aes()`.

The existing `<formula>` objects in R is often used to describe the
relationship between variables. Depending on the implementation, if you
have `y ~ x`, this tells you to describe the relationship of `x` to `y`.
In case you didn’t know yet, `~` are also function that captures the
code to retrieve and parse its abstract syntax tree (AST).

The current `<model_id>` objects from
[statim](https://github.com/s7-stats/statim) are already evaluated,
unlike `<formula>`, and that’s because of
[`model_processor()`](https://s7-stats.github.io/statim/reference/model-processor.md)
generics which resolves the data you mapped in `<model_id>` objects.
