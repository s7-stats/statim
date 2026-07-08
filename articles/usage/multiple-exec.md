# Applications of multiple model layouts with \`write_models()\`

## The Convenience of `write_models()`

The
[`write_models()`](https://s7-stats.github.io/statim/reference/write_models.md)
function is good at its job. It handles multiple `<var_id>` object
layouts or mappers, and you can perform:

1.  Multiple executions
2.  ANOVA models
3.  Comparison between models (soon)

These mappers must share the same `<STAT_FN>` estimation method, else
the execution will be aborted.

## How to load

Just like this
[vignette](https://s7-stats.github.io/statim/articles/usage/htest.md),
let us use the usual workflow of
[statim](https://github.com/s7-stats/statim)’s author in his daily basis
on statistical analysis, where [box](https://klmr.me/box/) is a main
tool to handle code reusability and package imports.

``` r

box::use(
    statim[
        write_models, prepare, anova, conclude, via, 
        T_TEST, COR_TEST, LINEAR_REG, 
        x_by, rel, pairwise
    ]
)
```

``` r

iris |> 
    write_models(
        mod1 = rel(Sepal.Length, Petal.Width), 
        mod2 = pairwise(where(is.numeric))
    )
```


    -- Models ---------------------------------------------------------------------- 

      mod1 : Sepal.Length ; Petal.Width
      mod2 : where(is.numeric)

``` r

mtcars |> 
    write_models(
        f1 = mpg ~ 1, 
        f2 = update(f1, ~ . + disp),
        f3 = update(f2, ~ . + hp),
        f4 = update(f3, ~ . + drat), 
        f5 = update(f4, ~ . + wt)
    ) |> 
    prepare(LINEAR_REG) |> 
    anova()
```

``` fansi

== ANOVA · F =================================================================== 

-- ANOVA Table -----------------------------------------------------------------

───────────────────────────────────────────────────────────
  model  res_df  deviance  df  dev_diff  f_value  p_value  
───────────────────────────────────────────────────────────
   f1      31    1126.047                                  
   f2      30    317.159   1   808.888   119.450  <0.001   
   f3      29    283.493   1    33.665    4.971    0.034   
   f4      28    253.346   1    30.148    4.452    0.044   
   f5      27    182.838   1    70.508   10.412   <0.001   
───────────────────────────────────────────────────────────
```
