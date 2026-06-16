# Writing new estimation method for inferential statistics

## Rationale

[statim](https://github.com/s7-stats/statim) is designed for
extrapolation of estimation methods in statistical inference, attempting
to bring barely known methods into
[statim](https://github.com/s7-stats/statim) pipelines, while harnessing
syntactic sugars when writing
[statim](https://github.com/s7-stats/statim) syntax. `stat_define` is
another but the main data structure of
[statim](https://github.com/s7-stats/statim) that keeps the
implementation and the rest of the metadata which describes the
pipeline.

## Anatomy of stat_define

This is the containerization of the existing methods while being called
in a single line. We have:

1.  `model_type` - you must supply a
    [`<model_id>`](https://s7-stats.github.io/statim/articles/pointers/model_id.html)
    that

2.  `impl` - a list of methods to be used in a single `<stat_fn>`

3.  `compatible_params`

4.  `claim_translator`

## How it is used

## Extending stat_define objects
