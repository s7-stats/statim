# Save statistical output to Excel

`save_excel()` is the terminal pipeline step for writing results to an
`.xlsx` file. It snapshots the console print output and writes it into
an Excel sheet as a formatted monospace report.

## Usage

``` r
save_excel(x, file, sheet = NULL, overwrite = NULL, ...)
```

## Arguments

- x:

  A `cld_exec` object from
  [`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md).

- file:

  Path to the `.xlsx` file to write.

- sheet:

  Sheet name. Defaults to the test name (e.g. `"T-Test"`). Truncated to
  31 characters (Excel limit).

- overwrite:

  Controls overwrite behaviour when `file` already exists. One of
  `"none"` (default, aborts), `"sheet"` (replaces only the matching
  sheet), or `"file"` (replaces the entire workbook). When `NULL`, the
  user is prompted interactively.

- ...:

  Currently unused.

## Value

`x`, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
sleep |>
    define_model(extra ~ group) |>
    prepare_test(TTEST) |>
    conclude() |>
    save_excel("t-test.xlsx")

iris |>
    define_model(pairwise(1:4, direction = "all")) |>
    prepare_test(TTEST) |>
    conclude() |>
    save_excel("t-test.xlsx", sheet = "t-test-pairwise")
} # }
```
