# Purge all package-scoped stat_define registrations for a package

Call this from your package's `.onUnload()` to clean up entries
registered via `add_stat_define(..., origin = "package")`.

## Usage

``` r
purge_stat_defines(pkg)
```

## Arguments

- pkg:

  A string. The package name, typically the `pkgname` argument passed to
  `.onUnload()`.

## Value

`NULL`, invisibly.

## Examples

``` r
# In your package's zzz.R:
.onUnload = function(libpath) {
    statim::purge_stat_defines("yourpackage")
}
```
