# Validate hypothesis parameter references against a model's declared variables

An S7 generic dispatched on the variable mapper `<var_id>` class. Called
automatically inside
[`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md)
after the compatible-param guard. Implement a method for any new
[var_id](https://s7-stats.github.io/statim/reference/var_id.md) subclass
you define.

## Usage

``` r
validate_claim_vars(var_id, processed, claims, ...)

check_param_nodes(claims, x_vars, by_vars)

validate_one_param_node(node, ...)

check_x_and_given(x_quo, given_quo, x_vars, by_vars, cls_name)
```

## Arguments

- var_id:

  A \<[var_id](https://s7-stats.github.io/statim/reference/var_id.md)\>
  object (usually carried by
  [`define_model()`](https://s7-stats.github.io/statim/reference/layout-define-base.md)).

- processed:

  The processed list from `lazy@processed`, as returned by
  [`model_processor()`](https://s7-stats.github.io/statim/reference/model-processor.md).

- claims:

  A `null_claim` object.

- ...:

  Currently unused.

- x_vars:

  A character vector of declared x-variable names, or `NULL` to skip
  x-variable validation.

- by_vars:

  A character vector of declared grouping variable names, or `NULL` to
  skip grouping variable validation.

- node:

  A `param_obj` instance.

- x_quo:

  A quosure holding the `x` slot value, or `NULL`.

- given_quo:

  A quosure holding the `given` slot value, or `NULL`.

- cls_name:

  A string naming the param class, used in error messages.

## Value

`invisible(NULL)`, or aborts with a consolidated error.

## Details

`check_param_nodes()` is the shared walker used by all built-in
`validate_claim_vars()` methods. It collects every `param_obj` node,
runs `validate_one_param_node()` on each, deduplicates errors, and
aborts with a consolidated message. Call this inside your own
`validate_claim_vars()` method rather than re-implementing the walking
and accumulation logic.

`validate_one_param_node()` is an S7 generic dispatched on `param_obj`.
Returns a character vector of error strings — empty if valid. The
default method on `param_obj` returns `character(0)`, so unknown
subclasses pass through safely. Implement a method for any new
`param_obj` subclass whose slots should be checked against the model's
declared variables.

`check_x_and_given()` is the standard building block for
`validate_one_param_node()` methods on `param_obj` subclasses that
follow the `MU(x, given)` slot convention. It checks an `x` quosure
against `x_vars` and a `given` quosure against `by_vars`.

## Implementing a new method

By default, unknown variable mapper `<var_id>` subclasses pass through
without validation. To add validation for a new
[var_id](https://s7-stats.github.io/statim/reference/var_id.md)
subclass, implement a method and delegate to `check_param_nodes()`:

    S7::method(validate_claim_vars, <var_id>) = function(var_id, processed, claims) {
        check_param_nodes(
            claims,
            x_vars = names(processed$x_data),
            by_vars = names(processed$group_data)
        )
    }

## Implementing `validate_one_param_node` for a new param class

For a subclass with `x` and `given` slots, delegate to
`check_x_and_given()`:

    S7::method(validate_one_param_node, MY_PARAM) = function(node, x_vars, by_vars) {
        check_x_and_given(node@x, node@given, x_vars, by_vars, "MY_PARAM")
    }

For a subclass with two variable slots (like
[`RHO()`](https://s7-stats.github.io/statim/reference/RHO.md)):

    S7::method(validate_one_param_node, MY_PARAM) = function(node, x_vars, by_vars) {
        errors = character(0)
        for (slot_quo in list(node@x, node@y)) {
            lbl = rlang::as_label(slot_quo)
            if (!is.null(x_vars) && !lbl %in% x_vars) {
                errors = c(errors, cli::format_inline(
                    "Unknown variable {.val {lbl}} in {.cls MY_PARAM}. ",
                    "Model declares x-variable{?s}: {.and {.val {x_vars}}}."
                ))
            }
        }
        errors
    }

## See also

[`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md),
[`MU()`](https://s7-stats.github.io/statim/reference/MU.md),
[`RHO()`](https://s7-stats.github.io/statim/reference/RHO.md),
[`PI()`](https://s7-stats.github.io/statim/reference/PI.md),
[`param_obj()`](https://s7-stats.github.io/statim/reference/param_obj.md),
[`var_id()`](https://s7-stats.github.io/statim/reference/var_id.md)
