# \`\<var_id\>\` objects

## Rationale

What’s the use of writing new `<var_id>` objects, rather than relying on
the existing `<formula>` (`~`) interface? Why need to write another? Not
all types of inference in R can be fully described by `<formula>`
objects. In fact, [ggplot2](https://ggplot2.tidyverse.org) doesn’t fully
manifest `<formula>` objects to describe the shape of the model you want
to visualize within [ggplot2](https://ggplot2.tidyverse.org) pipelines.
The existing `<var_id>` objects from
[statim](https://s7-stats.github.io/statim/) shape the model to be
analyzed in the statistical inference pipelines, which act like mappers,
just like
[`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html).

The existing `<formula>` objects in R is often used to describe the
relationship between variables. Depending on the implementation, if you
have `y ~ x`, this tells you to describe the relationship of `x` to `y`.
In case you didn’t know yet, `~` is also a function that captures the
code to retrieve and parse its abstract syntax tree (AST). That’s not
the whole reality, in fact, you can use `<formula>` but interpreted
differently.

`<var_id>` objects share this same lazy-capture nature — bare variable
names like `extra` or `group` aren’t evaluated at the moment
`x_by(extra, group)` is called, just as `~` doesn’t evaluate `extra` or
`group` in `extra ~ group`. The difference is in how that captured
expression is *resolved*: a `<formula>` is resolved on demand by
whatever consumes it
([`stats::terms()`](https://rdrr.io/r/stats/terms.html),
[`model.frame()`](https://rdrr.io/r/stats/model.frame.html), and so on),
while a `<var_id>` is always resolved the same way, through
[`model_processor()`](https://s7-stats.github.io/statim/dev/reference/model-processor.md)
— a single generic dispatched by
[`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md)
that turns the captured expressions into a list of data structures
(usually data frames), ready for the rest of the
[statim](https://s7-stats.github.io/statim/) pipeline.

## What are Variable Mappers

`<var_id>` objects, or the variable mappers, are built on top of S7, and
serve as “mappers”, similar to how
[`ggplot2::aes()`](https://ggplot2.tidyverse.org/reference/aes.html)
(aesthetic mappings) works. Where `aes()` maps variables to plot
aesthetics (`x`, `y`, `colour`, …), a `<var_id>` maps variables to the
roles a statistical model needs (e.g. a response and a grouping variable
for [`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md),
or a predictor and a response for
[`rel()`](https://s7-stats.github.io/statim/dev/reference/rel.md)).
[`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md)
then takes that mapping, resolves it via
[`model_processor()`](https://s7-stats.github.io/statim/dev/reference/model-processor.md),
and bundles the result into a `def_model` object that the rest of the
inference pipeline operates on.

## Existing objects

[statim](https://s7-stats.github.io/statim/) has built-in `<var_id>`
objects you can use to describe the shape of the model you want to
analyze during statistical inference.

- `x_by(x, group)`: compare `x` by `group`, e.g. `x_by(extra, group)`.
- `rel(x, resp)`: describe the relationship of `x` to `resp`,
  e.g. `rel(speed, dist)`.
- `pairwise(...)`: generate all unique pairwise combinations of a set of
  variables.
- `prop(x, n)`: describe a proportion test from a count `x` out of `n`
  trials.
- `on(...)`: independently tests the selected variables.

Each of these is a `var_id` subclass, and each is paired with a
[`model_processor()`](https://s7-stats.github.io/statim/dev/reference/model-processor.md)
method that resolves the variables into a list of data structures
(usually data frames), ready to be picked up by
[`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md).

## Writing new Variable Mappers

Writing a new `<var_id>` object is easy but strict — it always requires
[`model_processor()`](https://s7-stats.github.io/statim/dev/reference/model-processor.md)
to be dispatched, because you need to retrieve the data and store it in
a data structure — by default, a list. While there’s a
[`var_id_info()`](https://s7-stats.github.io/statim/dev/reference/var_id_info.md)
generic, it is not always required. The `var_id` is an abstract S7 class
used as a parent class for `<var_id>` objects. The following namespaces
are required:
[`S7::new_class()`](https://rconsortium.github.io/S7/reference/new_class.html),
[`S7::method()`](https://rconsortium.github.io/S7/reference/method.html),
[`statim::var_id`](https://s7-stats.github.io/statim/dev/reference/var_id.md),
and
[`statim::model_processor()`](https://s7-stats.github.io/statim/dev/reference/model-processor.md).
For example, you want to describe another model that describes 3
variables at once during the analysis, naming this `<var_id>` object
`xyz`.

Two simple steps are required:

1.  To write a new `<var_id>` mapper, use
    [`S7::new_class()`](https://rconsortium.github.io/S7/reference/new_class.html)
    constructor, and put
    [`statim::var_id`](https://s7-stats.github.io/statim/dev/reference/var_id.md)
    under `parent` argument. Using `constructor` argument is optional
    unless required.

    ``` r

    xyz = S7::new_class(
        "xyz",
        parent = statim::var_id,
        properties = list(
            x = S7::class_numeric,
            y = S7::class_numeric,
            z = S7::class_numeric
        )
    )
    ```

2.  Extract the info you need by dispatching
    [`model_processor()`](https://s7-stats.github.io/statim/dev/reference/model-processor.md)
    with the newly created `xyz` `<var_id>` object. Two arguments needed
    to place within the dispatched functions: `x`, `data` (which is
    optional), and the unused ellipsis `...`.

&nbsp;

    ``` r
    S7::method(model_processor, xyz) = function(var_id, ...) {
        list(
            x = var_id@x,
            y = var_id@y,
            z = var_id@z
        )
    }
    #> Warning: model_processor(<xyz>) doesn't have argument `data`
    ```

At this point, `xyz` is a fully functional `<var_id>`. It can be passed
straight into
[`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md):

    ``` r
    m = xyz(x = 1, y = 2, z = 3)
    def = define_model(m)
    def@processed
    #> $x
    #> [1] 1
    #> 
    #> $y
    #> [1] 2
    #> 
    #> $z
    #> [1] 3
    ```

## A bit more complicated: capturing unevaluated expressions

The example above is simple — `x`, `y`, and `z` are plain numeric
properties, evaluated eagerly at construction, so `xyz(1, 2, 3)` works
but `xyz(extra, group, ID)` would fail (`extra` isn’t a value in
[`globalenv()`](https://rdrr.io/r/base/environment.html)).

The built-in `<var_id>` objects
([`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md),
[`rel()`](https://s7-stats.github.io/statim/dev/reference/rel.md),
[`pairwise()`](https://s7-stats.github.io/statim/dev/reference/pairwise.md))
instead capture *unevaluated* expressions with
[`rlang::enquo()`](https://rlang.r-lib.org/reference/enquo.html), so
that bare variable names can be resolved later against a `data` frame
supplied to
[`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md),
or against the calling environment if `data` is omitted.

If your `<var_id>` needs this “lazy” behavior — e.g. accepting bare
column names like `x_by(extra, group)` does — capture each argument with
[`rlang::enquo()`](https://rlang.r-lib.org/reference/enquo.html) in a
custom `constructor`, and store the resulting quosure as the property
value:

``` r

xyz = S7::new_class(
    "xyz",
    parent = statim::var_id,
    properties = list(
        x = S7::class_any,
        y = S7::class_any,
        z = S7::class_any
    ),
    constructor = function(x, y, z) {
        S7::new_object(
            S7::S7_object(),
            x = rlang::enquo(x),
            y = rlang::enquo(y),
            z = rlang::enquo(z)
        )
    }
)
```

Then, in
[`model_processor()`](https://s7-stats.github.io/statim/dev/reference/model-processor.md),
resolve each quosure against `data` (or the calling environment when
`data` is `NULL`). The internal helper `resolve_quo()` does exactly this
for the built-in `<var_id>` objects, handling bare names,
[`c()`](https://rdrr.io/r/base/c.html) selections,
[`I()`](https://rdrr.io/r/base/AsIs.html) inline expressions, and
[`inlines()`](https://s7-stats.github.io/statim/dev/reference/inlines.md).
But for a first custom `<var_id>`, a simpler
[`rlang::eval_tidy()`](https://rlang.r-lib.org/reference/eval_tidy.html)
is enough:

``` r

S7::method(model_processor, xyz) = function(var_id, data = NULL, ...) {
    resolve = function(quo) {
        if (is.null(data)) {
            rlang::eval_tidy(quo)
        } else {
            data[[rlang::as_label(rlang::quo_get_expr(quo))]]
        }
    }

    list(
        x = resolve(var_id@x),
        y = resolve(var_id@y),
        z = resolve(var_id@z)
    )
}
#> Overwriting method model_processor(<xyz>)
```

To register a friendlier summary, with custom `args`, extra metadata in
`other_info`, and variable previews in `vars`, write a method for your
class. Return a `<class_var_inform>` object via
[`class_var_inform()`](https://s7-stats.github.io/statim/dev/reference/class_var_inform.md),
and set `registered = TRUE`:

``` r

S7::method(var_id_info, xyz) = function(.var_id, processed = NULL, ...) {
    other_info = list()
    vars = list()

    if (!is.null(processed) && length(processed)) {
        other_info = list(n_vars = length(processed))
        vars = lapply(names(processed), function(nm) {
            val = processed[[nm]]
            list(
                name = nm,
                preview = paste0("<", pillar::type_sum(val), " [", length(val), "]>")
            )
        })
    }

    class_var_inform(
        var_id = .var_id,
        args = paste0(
            "x = ", rlang::as_label(.var_id@x),
            ", y = ", rlang::as_label(.var_id@y),
            ", z = ", rlang::as_label(.var_id@z)
        ),
        other_info = other_info,
        vars = vars,
        registered = TRUE
    )
}
```

Now
[`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md)
prints a fuller summary:

``` r

define_model(xyz(extra, group, ID), sleep)
#> 
#> -- Model Definition ------------------------------------------------------------ 
#> 
#> Variable Mapper : xyz 
#> Args : x = extra, y = group, z = ID 
#> Other info:
#>     n_vars : 3 
#> Variables :
#>     x : <dbl [20]> 
#>     y : <fct [20]> 
#>     z : <fct [20]>
```

## Summary

To write a new `<var_id>` object:

1.  Define an S7 class with
    [`S7::new_class()`](https://rconsortium.github.io/S7/reference/new_class.html),
    with `parent = statim::var_id`.
2.  Register a
    [`model_processor()`](https://s7-stats.github.io/statim/dev/reference/model-processor.md)
    method for your class. This is the only required step, and it’s what
    [`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md)
    dispatches on to populate `processed`.
3.  If the `<var_id>` should capture bare variable names lazily
    (recommended for anything that will be paired with a `data` frame),
    use a custom `constructor` that wraps each argument with
    [`rlang::enquo()`](https://rlang.r-lib.org/reference/enquo.html),
    and resolve the quosures inside
    [`model_processor()`](https://s7-stats.github.io/statim/dev/reference/model-processor.md).
4.  Optionally, register a
    [`var_id_info()`](https://s7-stats.github.io/statim/dev/reference/var_id_info.md)
    method for a friendlier
    [`print()`](https://rdrr.io/r/base/print.html) summary, returning a
    `class_var_inform` object with `registered = TRUE`.

With these in place, your new `<var_id>` works seamlessly with
[`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md)
and the rest of the [statim](https://s7-stats.github.io/statim/)
pipeline — exactly like
[`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md),
[`rel()`](https://s7-stats.github.io/statim/dev/reference/rel.md),
[`pairwise()`](https://s7-stats.github.io/statim/dev/reference/pairwise.md),
and [`prop()`](https://s7-stats.github.io/statim/dev/reference/prop.md).
