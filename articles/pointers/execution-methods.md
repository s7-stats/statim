# Execution and Retrieval of Outputs

## Rationale

This is only applied on piped/grammar syntax pipelines. The functions
you’ll be using are the shared grammars and cannot be accessed with
“eager form” syntax. Eager forms like `TTEST(<var_id>, <data>)` directly
executes the outputs but cannot share grammars like
[`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md)
and [`tidy()`](https://s7-stats.github.io/statim/reference/tidy.md) to
retrieve the outputs.

## Structure

The output from “eager form” syntax and output from the piped/grammar
syntax have the same structure, only differs from their classes

## 
