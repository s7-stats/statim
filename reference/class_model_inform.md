# Output class for model ID metadata

`class_model_inform` is the S7 output class returned by
[`model_id_info()`](https://s7-stats.github.io/statim/reference/model_id_info.md).
`model_type` is derived automatically from the stored `model_id` object.
All other properties default to empty / unknown values, which are filled
in by registered
[`model_id_info()`](https://s7-stats.github.io/statim/reference/model_id_info.md)
methods for known subclasses.
