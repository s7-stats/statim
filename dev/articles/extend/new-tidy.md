# Writing new \`tidy()\` method

## Rationale

[statim](https://s7-stats.github.io/statim/) is so extendable, you can
extend the existing methods or write your own and make it extensive.

Here, I plan to extend
[`T_TEST()`](https://s7-stats.github.io/statim/dev/reference/T_TEST.md)
with another bootstrapping by simply adding another variation:

``` r

add_variant(T_TEST, x_by, "another_boot") %<-% variant(
    fn = function(.proc, .n = 1000L) {
        x = .proc$x_data[[1]]
        group_data = .proc$group_data
        
        grp = as.character(group_data[[1]])
        lvls = unique(grp)
        x1 = x[grp == lvls[[1]]]
        x2 = x[grp == lvls[[2]]]
        boot_fn = function(d, i) mean(d[i, 1]) - mean(d[i, 2])
        b = boot::boot(data.frame(x1, x2), boot_fn, R = .n)
        boot::boot.ci(b, type = "perc")
    }
)

another_boot_tt = 
    sleep |> 
    define_model(extra %by% group) |> 
    prepare_test(T_TEST) |> 
    via("another_boot") |> 
    conclude()

another_boot_tt
#> 
#> == Model ======================================================================= 
#> 
#> Variable Mapper : x_by 
#> Args : extra | group 
#>     x_vars : 1 
#>     by_vars : 1 
#> 
#> == T-Test · another_boot ======================================================= 
#> 
#> BOOTSTRAP CONFIDENCE INTERVAL CALCULATIONS
#> Based on 1000 bootstrap replicates
#> 
#> CALL : 
#> boot::boot.ci(boot.out = b, type = "perc")
#> 
#> Intervals : 
#> Level     Percentile     
#> 95%   (-2.44, -0.95 )  
#> Calculations and Intervals on Original Scale
```

[statim](https://s7-stats.github.io/statim/) has built-in output [S7
classes](https://joshuamarie.com/statim/reference/index.html#base-statistical-inference-output-class)
support, which you can use them to register your own method into that
specific class in order to be automatically processed into
[statim](https://s7-stats.github.io/statim/) internals, like extracting
your output in tibble format with
[`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md).
Otherwise, you must register them by your own.

An example above doesn’t register with one of built-in output S7
classes, so
[`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md) will
fail. Fortunately, you can bring it down by using
`making_tidy(<stat_fn>, <model_id / S7::class_formula>) %<-% method_tidy(...)`type
of registry:

``` r

making_tidy(T_TEST, x_by) %<-% method_tidy(
    another_boot = function(.x, ...) {
        dat = .x@data
        tibble::tibble(
            R = dat$R, 
            t0 = dat$t0
        )
    }
)

another_boot_tt |> tidy()
#> # A tibble: 1 × 2
#>       R    t0
#>   <int> <dbl>
#> 1  1000 -1.58
```

You can clean the
[`T_TEST()`](https://s7-stats.github.io/statim/dev/reference/T_TEST.md)
in `x_by` model pipeline slate by simply using
[`remove_variant()`](https://s7-stats.github.io/statim/dev/reference/add-variant.md).

``` r

remove_variant(T_TEST, x_by, "another_boot")
```
