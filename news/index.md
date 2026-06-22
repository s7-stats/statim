# Changelog

## statim (development version)

- Initial development version.

- New and much modern approach to statistical inference in R

- Core API built with S7 — taking advantage of formal classes and
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
          conclude()
      ```
