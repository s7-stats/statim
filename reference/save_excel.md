# Save statistical output to Excel

`save_excel()` is the terminal pipeline step for writing results to an
`.xlsx` file. It snapshots the console print output and writes it into
an Excel sheet as a formatted monospace report.

## Usage

``` r
save_excel(x, ...)
```

## Arguments

- x:

  A `cld_exec` object from
  [`conclude()`](https://joshuamarie.github.io/statim/reference/conclude.md).

- ...:

  Currently unused.

- file:

  Path to the `.xlsx` file to write.

## Value

`x`, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
sleep |>
    define_model(extra ~ sleep) |>
    prepare_test(TTEST) |>
    conclude() |>
    save_excel("t-test.xlsx")
} # }
```
