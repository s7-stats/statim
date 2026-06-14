# Extract metadata from a model ID

`model_id_info()` extracts a consistent metadata structure from a model
ID object. When `processed` is supplied, variable previews and
count-based metadata are included in the result.

## Usage

``` r
model_id_info(.model_id, processed = NULL, ...)
```

## Arguments

- .model_id:

  A model ID object from
  [`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md),
  [`rel()`](https://s7-stats.github.io/statim/reference/rel.md),
  [`pairwise()`](https://s7-stats.github.io/statim/reference/pairwise.md),
  or a formula.

- processed:

  A named list returned by
  [`model_processor()`](https://s7-stats.github.io/statim/reference/model-processor.md),
  or `NULL`. When `NULL`, count-based fields in `other_info` and `vars`
  are omitted.

- ...:

  Currently unused.

## Value

A `class_model_inform` S7 object with fields:

- `model_id`:

  The original model ID object.

- `model_type`:

  Derived from the class name of `model_id`.

- `args`:

  A formatted string summarising the model's arguments. Defaults to
  `"<?>"` for unregistered subclasses.

- `other_info`:

  A named list of model-type-specific metadata. Empty for unregistered
  subclasses.

- `vars`:

  A list of lists with `name` and `preview` fields. Empty for
  unregistered subclasses or when `processed` is `NULL`.

## Examples

``` r
# without processed — no vars, no counts
model_id_info(x_by(extra, group))
#> <statim::model_inform>
#>  @ model_id  : <statim::x_by>
#>  .. @ x    : language ~extra
#>  .. .. - attr(*, ".Environment")=<environment: 0x5578d289b0e8> 
#>  .. @ group: language ~group
#>  .. .. - attr(*, ".Environment")=<environment: 0x5578d289b0e8> 
#>  @ model_type: chr "x_by"
#>  @ args      : chr "extra | group"
#>  @ other_info: list()
#>  @ vars      : list()
#>  @ registered: logi TRUE

# with processed — includes vars and counts
dm = define_model(x_by(extra, group), sleep)
model_id_info(dm@model_id, dm@processed)
#> <statim::model_inform>
#>  @ model_id  : <statim::x_by>
#>  .. @ x    : language ~extra
#>  .. .. - attr(*, ".Environment")=<environment: 0x5578d289b0e8> 
#>  .. @ group: language ~group
#>  .. .. - attr(*, ".Environment")=<environment: 0x5578d289b0e8> 
#>  @ model_type: chr "x_by"
#>  @ args      : chr "extra | group"
#>  @ other_info:List of 2
#>  .. $ x_vars : int 1
#>  .. $ by_vars: int 1
#>  @ vars      :List of 2
#>  .. $ :List of 2
#>  ..  ..$ name   : chr "extra"
#>  ..  ..$ preview: chr "<dbl [20]>"
#>  .. $ :List of 2
#>  ..  ..$ name   : chr "group"
#>  ..  ..$ preview: chr "<fct [20]>"
#>  @ registered: logi TRUE
```
