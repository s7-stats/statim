# Add or remove variant implementations on a test or model function

These are **developer-interface** functions intended for package authors
extending the `statim` framework with new method variants.

`add_variant()` is used as the left-hand side of the `%<-%` operator to
register a
[`variant()`](https://s7-stats.github.io/statim/reference/variant.md)
for a stat function and model type. `"default"` is frozen and cannot be
added.

`remove_variant()` removes a previously registered `"user"`-originated
variant. `"package"`-level entries are self-cleaning: they exist for the
duration the registering package is loaded and vanish when it is
unloaded.

## Usage

``` r
add_variant(obj, model_type, name, origin = c("user", "package"))

remove_variant(obj, model_type, name)
```

## Arguments

- obj:

  A test or model function built with
  [`HTEST_FN()`](https://s7-stats.github.io/statim/reference/HTEST_FN.md)
  or
  [`MODEL_FN()`](https://s7-stats.github.io/statim/reference/MODEL_FN.md)
  (e.g. `TTEST`). Used to scope the registry key.

- model_type:

  An S7 `<var_id>` class (e.g. `x_by`,
  [`S7::class_formula`](https://rconsortium.github.io/S7/reference/base_s3_classes.html)).

- name:

  A string naming the variant to add.

- origin:

  One of `"user"` (default, session-scoped) or `"package"` (load-scoped,
  intended for `.onLoad()`).

## Value

An `add_variant_call` object, consumed by `%<-%`.

## See also

[`stat_define()`](https://s7-stats.github.io/statim/reference/stat-infer-definer.md),
[`variant()`](https://s7-stats.github.io/statim/reference/variant.md),
[`agendas()`](https://s7-stats.github.io/statim/reference/agendas.md),
[`model_processor()`](https://s7-stats.github.io/statim/reference/model-processor.md)

## Examples

``` r
# Add a bootstrap variant for x_by (user level).
# .proc$x_data[[1]] is the response vector; .proc$group_data is the
# grouping data frame. See ?model_processor for all available keys.
add_variant(TTEST, x_by, "another_boot") %<-% variant(
    fn = function(.proc, .n = 1000L) {
        x = .proc$x_data[[1]]
        grp = as.character(.proc$group_data[[1]])
        lvls = unique(grp)
        x1 = x[grp == lvls[[1]]]
        x2 = x[grp == lvls[[2]]]
        boot_fn = function(d, i) mean(d[i, 1]) - mean(d[i, 2])
        b = boot::boot(data.frame(x1, x2), boot_fn, R = .n)
        boot::boot.ci(b, type = "perc")
    }
)

# Remove it, returning to the original slate
remove_variant(TTEST, x_by, "another_boot")

# Package level (inside .onLoad())
add_variant(TTEST, x_by, "another_boot", origin = "package") %<-% variant(
    fn = function(.proc, .n = 1000L) { ... }
)
```
