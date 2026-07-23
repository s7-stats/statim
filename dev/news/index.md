# Changelog

## statim (development version)

### Minor Improvements

- “Installation” from `README` fixed its consistency

- Small revisions from `vignettes`, improving the quality.

  - Fixing `usage/` (examples) explanations.
  - `statim.Rmd` has clarifications on its comparison to other packages.

## statim 0.1.0

- Initial CRAN submission.

- New and much modern approach to statistical inference in R

- Core API built with S7, taking advantage of formal classes and
  constructors.

- Two complementary interfaces:

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
