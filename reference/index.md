# Package index

## High Level API

Main functions for interactive use

### Statistical Inference Layout definer and data preparation

Verbs that describe the model you want to analyze

- [`define_model()`](https://s7-stats.github.io/statim/reference/layout-define-base.md)
  : Define a layout supplied by a Variable Mapper
- [`write_models()`](https://s7-stats.github.io/statim/reference/write_models.md)
  : Write multiple model definitions from a data frame

### Variable Mapper IDs

Mappers similar to formula in R to shape the model you want to describe.
Formula also allowed.

- [`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md)
  [`` `%by%` ``](https://s7-stats.github.io/statim/reference/x_by.md) :
  Compare a variable by group
- [`rel()`](https://s7-stats.github.io/statim/reference/rel.md) :
  Describe the relationship between two variables
- [`pairwise()`](https://s7-stats.github.io/statim/reference/pairwise.md)
  : Define all pairwise variable combinations
- [`prop()`](https://s7-stats.github.io/statim/reference/prop.md) :
  Define a proportion test model

### Statistical Inference Parameterization

Verbs used for preparing and parameterize the equation of statistical
inference

- [`define_model()`](https://s7-stats.github.io/statim/reference/layout-define-base.md)
  : Define a layout supplied by a Variable Mapper
- [`prepare_test()`](https://s7-stats.github.io/statim/reference/prepare-test.md)
  : Lazily prepare a single test
- [`prepare_model()`](https://s7-stats.github.io/statim/reference/prepare-model.md)
  : Lazily prepare a model inference
- [`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md)
  : State a null hypothesis in the pipeline
- [`via()`](https://s7-stats.github.io/statim/reference/via.md) :
  Recalibrate the method variant
- [`conclude()`](https://s7-stats.github.io/statim/reference/conclude.md)
  : Execute a lazy pipeline

### "Population parameter" definer

Functions that emulate the population parameter, close to textbook
notations

- [`MU()`](https://s7-stats.github.io/statim/reference/MU.md) : Mean of
  a variable, optionally conditioned on a subgroup
- [`PI()`](https://s7-stats.github.io/statim/reference/PI.md) :
  Proportion of a variable, optionally conditioned on a subgroup
- [`RHO()`](https://s7-stats.github.io/statim/reference/RHO.md) :
  Population correlation between two variables

### ANOVA for Linear Models

Verbs used to perform ANOVA for linear models

- [`anova()`](https://s7-stats.github.io/statim/reference/anova-mod.md)
  : ANOVA table for linear model comparisons
- [`write_models()`](https://s7-stats.github.io/statim/reference/write_models.md)
  : Write multiple model definitions from a data frame
- [`prepare_model()`](https://s7-stats.github.io/statim/reference/prepare-model.md)
  : Lazily prepare a model inference

### Output retriever and displayer

Verbs used to retrieve outputs in standard R’s data structure

- [`tidy()`](https://s7-stats.github.io/statim/reference/tidy.md) : Tidy
  a concluded statistical result
- [`display()`](https://s7-stats.github.io/statim/reference/display.md)
  : Display individual results

### H-test container and executioner

Container and an eager executioner of a prepared H-test function

- [`TTEST()`](https://s7-stats.github.io/statim/reference/TTEST.md) :
  T-Test
- [`CORTEST()`](https://s7-stats.github.io/statim/reference/CORTEST.md)
  : Correlation Test
- [`P_TEST()`](https://s7-stats.github.io/statim/reference/P_TEST.md) :
  Proportion Test

### Model-based inference container and executioner

Container and an eager executioner of a prepared model-based inference
function

- [`LINEAR_REG()`](https://s7-stats.github.io/statim/reference/LINEAR_REG.md)
  : Linear regression
- [`GLM()`](https://s7-stats.github.io/statim/reference/GLM.md) :
  Generalized linear model

### Multiple Inline Codes

Analogue to [`I()`](https://rdrr.io/r/base/AsIs.html), but only captures
the expression and accepts multiple inline codes.

- [`inlines()`](https://s7-stats.github.io/statim/reference/inlines.md)
  : Inline multiple expressions in a Variable Mapper

### Output renderer and saver

Capture the printed output in specific formats

- [`save_excel()`](https://s7-stats.github.io/statim/reference/save_excel.md)
  : Save statistical output to Excel

## Low-level / Developer facing API

Functions for building and extending test implementations

### Model ID helpers

Classes and internal functions

- [`var_id`](https://s7-stats.github.io/statim/reference/var_id.md) :
  Base class for Variable Mapper objects
- [`model_processor()`](https://s7-stats.github.io/statim/reference/model-processor.md)
  : Model evaluator
- [`var_id_info()`](https://s7-stats.github.io/statim/reference/var_id_info.md)
  : Extract metadata from a Variable Mapper
- [`class_var_inform`](https://s7-stats.github.io/statim/reference/class_var_inform.md)
  : Output class for Variable Mapper metadata

### Implementation containers

Declare how a test runs

- [`agendas()`](https://s7-stats.github.io/statim/reference/agendas.md)
  : Collect implementations for a statistical procedure
- [`baseline()`](https://s7-stats.github.io/statim/reference/baseline.md)
  : Declare the canonical implementation of a test or model
- [`variant()`](https://s7-stats.github.io/statim/reference/variant.md)
  : Declare an alternative implementation of a test or model

### Base statistical inference output class

With different implementation but the same class, the methods,
e.g. [`tidy()`](https://s7-stats.github.io/statim/reference/tidy.md),
will be shareable

- [`class_stat_infer()`](https://s7-stats.github.io/statim/reference/class_stat_infer.md)
  : Base class for all statistical result objects
- [`class_ttest_pairwise`](https://s7-stats.github.io/statim/reference/class_ttest_pairwise.md)
  : Structured result container for pairwise t-tests
- [`class_ttest_two`](https://s7-stats.github.io/statim/reference/class_ttest_two.md)
  : Structured result container for two-sample t-tests
- [`class_p_test`](https://s7-stats.github.io/statim/reference/class_p_test.md)
  : Structured result container for proportion tests
- [`class_corr_two`](https://s7-stats.github.io/statim/reference/class_corr_two.md)
  : Structured result container for two-sample t-tests
- [`class_lm_object`](https://s7-stats.github.io/statim/reference/class_lm_object.md)
  : Structured result container for linear model fits
- [`class_glm_object`](https://s7-stats.github.io/statim/reference/class_glm_object.md)
  : Structured result container for GLM fits

### Test definition

Register a new test implementation

- [`stat_define()`](https://s7-stats.github.io/statim/reference/stat-infer-definer.md)
  [`test_define()`](https://s7-stats.github.io/statim/reference/stat-infer-definer.md)
  [`model_infer_define()`](https://s7-stats.github.io/statim/reference/stat-infer-definer.md)
  : Define a statistical procedure implementation
- [`STAT_CONSTRUCTOR()`](https://s7-stats.github.io/statim/reference/STAT_CONSTRUCTOR.md)
  : Main foundation for inferential statistics
- [`HTEST_FN()`](https://s7-stats.github.io/statim/reference/HTEST_FN.md)
  : Build a hypothesis test function
- [`MODEL_FN()`](https://s7-stats.github.io/statim/reference/MODEL_FN.md)
  : Build a model inference function

### stat_define add-ons management

Add or remove estimation method on existing test functions

- [`add_stat_define()`](https://s7-stats.github.io/statim/reference/add-stat-define.md)
  [`remove_stat_define()`](https://s7-stats.github.io/statim/reference/add-stat-define.md)
  : Add or remove stat_define implementations on a test or model
  function
- [`purge_stat_defines()`](https://s7-stats.github.io/statim/reference/purge_stat_defines.md)
  : Purge all package-scoped stat_define registrations for a package

### Session-scoped variant management

Add or replace variants on existing test functions

- [`add_variant()`](https://s7-stats.github.io/statim/reference/add-variant.md)
  [`remove_variant()`](https://s7-stats.github.io/statim/reference/add-variant.md)
  : Add or remove variant implementations on a test or model function
- [`` `%<-%` ``](https://s7-stats.github.io/statim/reference/modifying-assignment.md)
  : Apply a method_tidy to a making_tidy target

### Modelled hypothesis "population parameter" definer

Core class of "population parameter" definer

- [`param_obj()`](https://s7-stats.github.io/statim/reference/param_obj.md)
  : Base class for population parameters

### Modelled hypothesis management and validators

Core helpers to parse the modelled hypotheses, objects from
[`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md)

- [`validate_claim_vars()`](https://s7-stats.github.io/statim/reference/claim-vars-validators.md)
  [`check_param_nodes()`](https://s7-stats.github.io/statim/reference/claim-vars-validators.md)
  [`validate_one_param_node()`](https://s7-stats.github.io/statim/reference/claim-vars-validators.md)
  [`check_x_and_given()`](https://s7-stats.github.io/statim/reference/claim-vars-validators.md)
  : Validate hypothesis parameter references against a model's declared
  variables
- [`claim_scalar()`](https://s7-stats.github.io/statim/reference/claim_scalar.md)
  : Extract a scalar hypothesis value from a null claim
- [`claim_contrast_coefs()`](https://s7-stats.github.io/statim/reference/claim_contrast_coefs.md)
  : Extract contrast coefficients from a null claim

### Modelled hypothesis translator and container

Core function to contain the implementation to translate modelled
hypothesis, placed under `claim_parser` from
[`baseline()`](https://s7-stats.github.io/statim/reference/baseline.md)
/ [`variant()`](https://s7-stats.github.io/statim/reference/variant.md)

- [`map_claim()`](https://s7-stats.github.io/statim/reference/map_claim.md)
  : Build a claim parser from named resolver functions
- [`baseline()`](https://s7-stats.github.io/statim/reference/baseline.md)
  : Declare the canonical implementation of a test or model
- [`variant()`](https://s7-stats.github.io/statim/reference/variant.md)
  : Declare an alternative implementation of a test or model

### Tidy implementation container

Add or replace
[`tidy()`](https://s7-stats.github.io/statim/reference/tidy.md) method
for following `STAT_CONSTRUCTOR` objects

- [`auto_tidy()`](https://s7-stats.github.io/statim/reference/auto_tidy.md)
  : Automatically tidy a statistical result
- [`making_tidy()`](https://s7-stats.github.io/statim/reference/making_tidy.md)
  : Declare tidy methods for a stat and model type
- [`method_tidy()`](https://s7-stats.github.io/statim/reference/method_tidy.md)
  : Declare tidy methods for a stat result
- [`` `%<-%` ``](https://s7-stats.github.io/statim/reference/modifying-assignment.md)
  : Apply a method_tidy to a making_tidy target
