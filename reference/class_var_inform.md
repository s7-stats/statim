# Output class for Variable Mapper metadata

`class_var_inform` is the S7 output class returned by
[`var_id_info()`](https://s7-stats.github.io/statim/reference/var_id_info.md).
`model_type` is derived automatically from the stored `var_id` object.
All other properties default to empty / unknown values, which are filled
in by registered
[`var_id_info()`](https://s7-stats.github.io/statim/reference/var_id_info.md)
methods for known subclasses.
