# Package index

## High Level API

Main functions for interactive use

### Model definition and data preparation

Verbs that describe the model you want to analyze

- [`define_model()`](https://joshuamarie.github.io/statim/reference/model-define-base.md)
  : Model define constructor
- [`write_models()`](https://joshuamarie.github.io/statim/reference/write_models.md)
  : Write multiple model definitions from a data frame

### Model IDs

Mappers similar to formula in R to shape the model you want to describe.
Formula also allowed.

- [`x_by()`](https://joshuamarie.github.io/statim/reference/x_by.md)
  [`` `%by%` ``](https://joshuamarie.github.io/statim/reference/x_by.md)
  : 'Variable compared by groups' model mapping
- [`rel()`](https://joshuamarie.github.io/statim/reference/rel.md) :
  'Relationship between two variables' model mapping
- [`pairwise()`](https://joshuamarie.github.io/statim/reference/pairwise.md)
  : 'Pairs between variables' model mapping

### Statistical Inference Parameterization

Verbs used for preparing and parameterize the equation of statistical
inference

- [`define_model()`](https://joshuamarie.github.io/statim/reference/model-define-base.md)
  : Model define constructor
- [`prepare_test()`](https://joshuamarie.github.io/statim/reference/prepare-test.md)
  : Lazily prepare a single test
- [`prepare_model()`](https://joshuamarie.github.io/statim/reference/prepare-model.md)
  : Lazily prepare a model inference
- [`state_null()`](https://joshuamarie.github.io/statim/reference/null-hyp.md)
  [`more_h0()`](https://joshuamarie.github.io/statim/reference/null-hyp.md)
  : State a null hypothesis in the pipeline
- [`via()`](https://joshuamarie.github.io/statim/reference/via.md) :
  Recalibrate the method variant
- [`conclude()`](https://joshuamarie.github.io/statim/reference/conclude.md)
  : Execute a lazy pipeline

### "Population parameter" definer

Functions that emulate the population parameter, close to textbook
notations

- [`` `%=%` ``](https://joshuamarie.github.io/statim/reference/equal-op.md)
  : Chained equality operator for null hypotheses
- [`MU()`](https://joshuamarie.github.io/statim/reference/MU.md) : Mean
  of a variable, optionally conditioned on a subgroup
- [`PI()`](https://joshuamarie.github.io/statim/reference/PI.md) :
  Proportion of a variable, optionally conditioned on a subgroup
- [`SIGMA()`](https://joshuamarie.github.io/statim/reference/SIGMA.md) :
  Variance of a variable, optionally conditioned on a subgroup
- [`RHO()`](https://joshuamarie.github.io/statim/reference/RHO.md) :
  Population correlation between two variables

### ANOVA for Linear Models

Verbs used to perform ANOVA for linear models

- [`anova()`](https://joshuamarie.github.io/statim/reference/anova-mod.md)
  : ANOVA table for linear model comparisons
- [`write_models()`](https://joshuamarie.github.io/statim/reference/write_models.md)
  : Write multiple model definitions from a data frame
- [`prepare_model()`](https://joshuamarie.github.io/statim/reference/prepare-model.md)
  : Lazily prepare a model inference

### Result retrieval

Verbs used to retrieve outputs in standard R’s data structure

- [`tidy()`](https://joshuamarie.github.io/statim/reference/tidy.md) :
  Tidy a concluded statistical result

### H-test container and executioner

Container and an eager executioner of a prepared H-test function

- [`TTEST()`](https://joshuamarie.github.io/statim/reference/TTEST.md) :
  T-Test
- [`CORTEST()`](https://joshuamarie.github.io/statim/reference/CORTEST.md)
  : Correlation Test
- [`ANOVA()`](https://joshuamarie.github.io/statim/reference/anova.md) :
  ANOVA

### Model-based inference container and executioner

Container and an eager executioner of a prepared model-based inference
function

- [`LINEAR_REG()`](https://joshuamarie.github.io/statim/reference/LINEAR_REG.md)
  : Linear regression
- [`GLM()`](https://joshuamarie.github.io/statim/reference/GLM.md) :
  Generalized linear model

### Multiple Inline Codes

Analogue to [`I()`](https://rdrr.io/r/base/AsIs.html), but only captures
the expression and accepts multiple inline codes.

- [`inlines()`](https://joshuamarie.github.io/statim/reference/inlines.md)
  : Inline multiple expressions in a model ID

### Output renderer and saver

Capture the printed output in specific formats

- [`save_excel()`](https://joshuamarie.github.io/statim/reference/save_excel.md)
  : Save statistical output to Excel

## Low-level / Developer facing API

Functions for building and extending test implementations

### Model ID helpers

Classes and internal functions

- [`model_id()`](https://joshuamarie.github.io/statim/reference/model_id.md)
  : Attach a model-ID class to an object
- [`model_processor()`](https://joshuamarie.github.io/statim/reference/model-processor.md)
  : Model evaluator
- [`model_id_info()`](https://joshuamarie.github.io/statim/reference/model_id_info.md)
  : Extract metadata from a model ID

### Implementation containers

Declare how a test runs

- [`agendas()`](https://joshuamarie.github.io/statim/reference/agendas.md)
  : Collect implementations for a statistical procedure
- [`baseline()`](https://joshuamarie.github.io/statim/reference/baseline.md)
  : Declare the canonical implementation of a test or model
- [`variant()`](https://joshuamarie.github.io/statim/reference/variant.md)
  : Declare an alternative implementation of a test or model

### Base statistical inference output class

Requires within the pipeline,
e.g. [`tidy()`](https://joshuamarie.github.io/statim/reference/tidy.md)

- [`class_stat_infer()`](https://joshuamarie.github.io/statim/reference/class_stat_infer.md)
  : Base class for all statistical result objects
- [`lm_object`](https://joshuamarie.github.io/statim/reference/lm_object.md)
  : Structured result container for linear model fits
- [`glm_object`](https://joshuamarie.github.io/statim/reference/glm_object.md)
  : Structured result container for GLM fits

### Test definition

Register a new test implementation

- [`stat_define()`](https://joshuamarie.github.io/statim/reference/stat-infer-definer.md)
  [`test_define()`](https://joshuamarie.github.io/statim/reference/stat-infer-definer.md)
  [`model_infer_define()`](https://joshuamarie.github.io/statim/reference/stat-infer-definer.md)
  : Define a statistical procedure implementation
- [`STAT_CONSTRUCTOR()`](https://joshuamarie.github.io/statim/reference/STAT_CONSTRUCTOR.md)
  : Main foundation for inferential statistics
- [`HTEST_FN()`](https://joshuamarie.github.io/statim/reference/HTEST_FN.md)
  : Build a hypothesis test function
- [`MODEL_FN()`](https://joshuamarie.github.io/statim/reference/MODEL_FN.md)
  : Build a model inference function

### Session-scoped variant management

Add or replace variants on existing test functions

- [`add_variant()`](https://joshuamarie.github.io/statim/reference/add-variant.md)
  [`remove_variant()`](https://joshuamarie.github.io/statim/reference/add-variant.md)
  : Add or remove variant implementations on a test or model function
- [`` `%<-%` ``](https://joshuamarie.github.io/statim/reference/modifying-assignment.md)
  : Apply a method_tidy to a making_tidy target

### Modelled hypothesis "population parameter" definer

Core class of "population parameter" definer

- [`param_obj()`](https://joshuamarie.github.io/statim/reference/param_obj.md)
  : Base class for population parameters

### Modelled hypothesis management

Core helpers to parse the modelled hypotheses, objects from
[`state_null()`](https://joshuamarie.github.io/statim/reference/null-hyp.md)

- [`claim_scalar_diff()`](https://joshuamarie.github.io/statim/reference/claim_scalar_diff.md)
  : Extract the hypothesized scalar value from a null claim
- [`claim_contrast_coefs()`](https://joshuamarie.github.io/statim/reference/claim_contrast_coefs.md)
  : Extract contrast coefficients from a null claim

### Modelled hypothesis translator and container

Core function to contain the implementation to translate modelled
hypothesis, placed under `claim_translator` from `stat_define`

- [`claim_translate()`](https://joshuamarie.github.io/statim/reference/claim_translate.md)
  : Declare per-variant claim translators
- [`map_claim()`](https://joshuamarie.github.io/statim/reference/map_claim.md)
  : Build a claim translator from named resolver functions

### Tidy implementation container

Add or replace
[`tidy()`](https://joshuamarie.github.io/statim/reference/tidy.md)
method for following `STAT_CONSTRUCTOR` objects

- [`auto_tidy()`](https://joshuamarie.github.io/statim/reference/auto_tidy.md)
  : Automatically tidy a statistical result
- [`making_tidy()`](https://joshuamarie.github.io/statim/reference/making_tidy.md)
  : Declare tidy methods for a stat and model type
- [`method_tidy()`](https://joshuamarie.github.io/statim/reference/method_tidy.md)
  : Declare tidy methods for a stat result
- [`` `%<-%` ``](https://joshuamarie.github.io/statim/reference/modifying-assignment.md)
  : Apply a method_tidy to a making_tidy target

### Exclusive for linear models only

Containerization of linear model outputs in S7 classes

- [`lm_object`](https://joshuamarie.github.io/statim/reference/lm_object.md)
  : Structured result container for linear model fits
- [`glm_object`](https://joshuamarie.github.io/statim/reference/glm_object.md)
  : Structured result container for GLM fits
