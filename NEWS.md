# statim (development version)

## Bug Fixes

-  `state_null()` now resolves external variables referenced in a hypothesis
   expression (e.g. `MU(x) <= 0.20 * some_var`) using the environment
   captured by `rlang::enquo()` instead of `rlang::caller_env()`. The latter
   depended on the exact shape of the call stack and silently failed to find
   the variable whenever `state_null()` was invoked from inside a function,
   `local()`, or a knitr chunk (i.e. any vignette render), even though it
   happened to work when called at the top level of an interactive script.

## Minor Improvements

-  "Installation" from `README` fixed its consistency
-  Small revisions from `vignettes`, improving the quality. 

    -  Fixing `usage/` (examples) explanations. 
    -  `statim.Rmd` has clarifications on its comparison to other packages. 

# statim 0.1.0

-  Initial CRAN submission.
-  New and much modern approach to statistical inference in R
-  Core API built with S7, taking advantage of formal classes and constructors. 
-  Two complementary interfaces:

    1.  Eager Form Approach:
    
        ``` r
        <<STAT_FN>>(<var_id>, <data>)
        ```
    
    2.  Piped/Grammar Syntax
    
        ``` r
        ... |>
            define_model(<data/var_id>, <data/var_id>) |> 
            prepare_*(<<STAT_FN>>) |> 
            state_null(<expr>) |> 
            via("<method>") |> 
            conclude() |> 
            <output-process-fn>()
        ```


