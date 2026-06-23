# Add or remove stat_define implementations on a test or model function

These are developer-interface functions intended for package authors
extending the `statim` framework with new model types.

`add_stat_define()` registers a new
[`stat_define()`](https://s7-stats.github.io/statim/reference/stat-infer-definer.md)
for a stat function, enabling it to handle a previously unsupported
variable mapper `<var_id>`. Registering a model type that already exists
— whether baked-in or previously registered — is an error.

`remove_stat_define()` removes a previously registered
`"user"`-originated entry. `"package"`-scoped entries are self-cleaning
via
[`purge_stat_defines()`](https://s7-stats.github.io/statim/reference/purge_stat_defines.md)
called in the registering package's `.onUnload()`.

## Usage

``` r
add_stat_define(
  stat_fn,
  model_type,
  impl,
  compatible_params = list(),
  origin = c("user", "package"),
  .pkg = NULL
)

remove_stat_define(stat_fn, model_type)
```

## Arguments

- stat_fn:

  A test or model function built with
  [`HTEST_FN()`](https://s7-stats.github.io/statim/reference/HTEST_FN.md)
  or
  [`MODEL_FN()`](https://s7-stats.github.io/statim/reference/MODEL_FN.md)
  (e.g. `TTEST`, `P_TEST`).

- model_type:

  An S7 `<var_id>` class (e.g. `x_by`,
  [`S7::class_formula`](https://rconsortium.github.io/S7/reference/base_s3_classes.html)).

- impl:

  An
  [`agendas()`](https://s7-stats.github.io/statim/reference/agendas.md)
  object.

- compatible_params:

  A list of param S7 classes (e.g. `list(MU)`). Defaults to
  [`list()`](https://rdrr.io/r/base/list.html).

- origin:

  One of `"user"` (default) or `"package"`. Use `"user"` for interactive
  or script-level registration scoped to the current session. Use
  `"package"` inside your package's `.onLoad()`, paired with
  `.pkg = pkgname` — see the **Package authors** section below.

- .pkg:

  The registering package name. Required when `origin = "package"`;
  ignored otherwise. Pass the `pkgname` argument that R supplies to
  `.onLoad()` / `.onAttach()`. This is used to attribute the entry and
  to enable
  [`purge_stat_defines()`](https://s7-stats.github.io/statim/reference/purge_stat_defines.md)
  to clean it up on unload.

## Value

`NULL`, invisibly.

## Scoping and lifecycle

Registrations have two scopes:

- *`"user"`-scoped* entries live for the duration of the R session (or
  until explicitly removed with `remove_stat_define()`). Use this for
  interactive work or in scripts.

- *`"package"`-scoped* entries are intended for package authors who ship
  extensions to `statim`. They must be registered in `.onLoad()` and
  cleaned up in `.onUnload()` via
  [`purge_stat_defines()`](https://s7-stats.github.io/statim/reference/purge_stat_defines.md).
  This keeps the registry tidy when the extending package is unloaded.

## Package authors

To ship an extension as a package, register in `zzz.R` (or any file
loaded early):

    .onLoad = function(libname, pkgname) {
        statim::add_stat_define(
            P_TEST,
            my_var_id,
            impl = agendas(
                base = baseline(
                    fn = function(.proc, .p = 0.5, .alt = "two.sided", .ci = 0.95) {
                        # your implementation
                    }
                )
            ),
            compatible_params = list(PI),
            origin = "package",
            .pkg = pkgname
        )
    }

    .onUnload = function(libpath) {
        statim::purge_stat_defines("yourpackage")
    }

The `.pkg = pkgname` argument is how `statim` knows which package owns
the entry. Without it, `origin = "package"` is an error. Never hard-code
the string yourself — always forward the `pkgname` R passes to
`.onLoad()`.

## See also

[`stat_define()`](https://s7-stats.github.io/statim/reference/stat-infer-definer.md),
[`agendas()`](https://s7-stats.github.io/statim/reference/agendas.md),
`remove_stat_define()`,
[`purge_stat_defines()`](https://s7-stats.github.io/statim/reference/purge_stat_defines.md)

## Examples

``` r
# Session-scoped registration (interactive use or scripts)
mt = S7::new_class("my_var", parent = var_id)

add_stat_define(
    P_TEST,
    mt,
    impl = agendas(
        base = baseline(
            fn = function(.proc, .value = 1) list(value = .value)
        )
    )
)

# Clean up when done
remove_stat_define(P_TEST, mt)
```
