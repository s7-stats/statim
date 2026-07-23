# Hypothesis Testing with {statim}

## Rationale

While `t.test(x, alternative = "less")` works and is simple, there are
times you won’t remember the intent of the function call, e.g. which
side of the inequality “less” refers to:

- Is `x` hypothesized to be less than `mu`, or `mu` less than `x`?

[statim](https://s7-stats.github.io/statim/) takes a different approach
on how statistical inference in R is done. For instance,
[statim](https://s7-stats.github.io/statim/) has another way to write
the null hypothesis itself as an algebraic expression instead
(e.g. `MU(x) < 120`, `RHO(x, y) == 0`), so the code declares what the
null hypothesis is, direction included, rather than which argument slot
lives in.

[statim](https://s7-stats.github.io/statim/) is fully declarative,
mainly through piped/grammar sementics like
[ggplot2](https://ggplot2.tidyverse.org), including on how you declare
the estimation method in a statistical inference you want to perform.
The question is, does that actually pay off?

This vignette is a showcase of
[statim](https://s7-stats.github.io/statim/) which runs four questions
from a real dataset through
[statim](https://s7-stats.github.io/statim/), base R, and
[rstatix](https://rpkgs.datanovia.com/rstatix/), and is honest about
where the extra syntax doesn’t earn its keep. These four are the
straightforward cases; the harder one, where the syntax stops being
optional, is covered in the Conclusion below.

### Sample Problem

The dataset: 303 patients from the Cleveland Clinic. Originally
collected by Robert Detrano, M.D., Ph.D., and hosted at the UCI Machine
Learning Repository (Heart Disease dataset, Cleveland subset). This copy
was redistributed by Daniel Bourke’s “zero-to-mastery-ml” repo, and is
bundled with this package at `inst/extdata/heart-disease.csv` so the
vignette builds without a network call.

The questions, framed as a cardiologist would ask them:

1.  [Is average resting blood pressure **different from the clinical
    normal of 120 mmHg**?](#q1)
2.  [Do men and women differ in maximum heart rate achieved during
    stress testing?](#q2)
3.  [Is there a linear relationship between age and maximum heart
    rate?](#q3)
4.  [Is the proportion of male patients with fasting blood sugar **above
    120 mg/dL** different from an assumed population baseline of
    15%?](#q4)

They are answered by: one-sample t-test, two-sample t-test, correlation
test, one-sample proportion test, respectively.

## Setup

[statim](https://s7-stats.github.io/statim/)’s author reaches for
[box](https://klmr.me/box/) day to day. It’s an R package that bring an
another but better import system that forces every dependency to be
declared explicitly, so a script’s imports double as its own dependency
graph.

``` r

box::use(
    stats[t.test, cor.test, binom.test],
    statim[
        T_TEST, COR_TEST, P_TEST,
        # Current grammars
        define_model, prepare, via, state_null, conclude,
        # Multiple executions
        write_models, display,
        # Mappers
        x_by, rel, prop, on,
        # "Parameters" object callers
        MU, RHO, PI
    ],
    rstatix[t_test, cor_test, binom_test]
)

box::use(
    dplyr[keep_when = filter, mutate, glimpse],
    readr[read_csv]
)
```

Then import the CSV file from this package:

``` r

heart = read_csv(system.file("extdata", "heart-disease.csv", package = "statim")) |>
    mutate(
        sex = factor(sex, levels = c(0, 1), labels = c("Female", "Male")),
        fbs = factor(fbs, levels = c(0, 1), labels = c("Normal", "High"))
    )
```

     [1mRows:  [22m [34m303 [39m  [1mColumns:  [22m [34m14 [39m
     [36m── [39m  [1mColumn specification [22m  [36m──────────────────────────────────────────────────────── [39m
     [1mDelimiter: [22m ","
     [32mdbl [39m (14): age, sex, cp, trestbps, chol, fbs, restecg, thalach, exang, oldpea...

     [36mℹ [39m Use `spec()` to retrieve the full column specification for this data.
     [36mℹ [39m Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r

glimpse(heart)
```

``` fansi
Rows: 303
Columns: 14
$ age      <dbl> 63, 37, 41, 56, 57, 57, 56, 44, 52, 57, 54, 48, 49, 64, 58, 5…
$ sex      <fct> Male, Male, Female, Male, Female, Male, Female, Male, Male, M…
$ cp       <dbl> 3, 2, 1, 1, 0, 0, 1, 1, 2, 2, 0, 2, 1, 3, 3, 2, 2, 3, 0, 3, 0…
$ trestbps <dbl> 145, 130, 130, 120, 120, 140, 140, 120, 172, 150, 140, 130, 1…
$ chol     <dbl> 233, 250, 204, 236, 354, 192, 294, 263, 199, 168, 239, 275, 2…
$ fbs      <fct> High, Normal, Normal, Normal, Normal, Normal, Normal, Normal,…
$ restecg  <dbl> 0, 1, 0, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1…
$ thalach  <dbl> 150, 187, 172, 178, 163, 148, 153, 173, 162, 174, 160, 139, 1…
$ exang    <dbl> 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0…
$ oldpeak  <dbl> 2.3, 3.5, 1.4, 0.8, 0.6, 0.4, 1.3, 0.0, 0.5, 1.6, 1.2, 0.2, 0…
$ slope    <dbl> 0, 0, 2, 2, 2, 1, 1, 2, 2, 2, 2, 2, 2, 1, 2, 1, 2, 0, 2, 2, 1…
$ ca       <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0…
$ thal     <dbl> 1, 2, 2, 2, 2, 1, 2, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3…
$ target   <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1…
```

Here’s an overview for the columns to be used:

| Column     | Type       | Description                                        |
|------------|------------|----------------------------------------------------|
| `trestbps` | Continuous | Resting blood pressure (mm Hg)                     |
| `thalach`  | Continuous | Maximum heart rate achieved                        |
| `age`      | Continuous | Age in years                                       |
| `sex`      | Binary     | Sex (0 = Female, 1 = Male)                         |
| `fbs`      | Binary     | Fasting blood sugar \> 120 mg/dL (0 = No, 1 = Yes) |

## Question 1: Is resting blood pressure elevated?

H_0: \mu=120 \qquad H_1: \mu\neq120

This is the simplest case, so it’s worth showing every entry point once.

### Codes

- statim
- rstatix
- Base R

There are two layouts to perform one-sample t-test:

Using `on()`

``` r

heart |>
    define_model(on(trestbps)) |>
    prepare(T_TEST, .mu = 120) |>
    conclude()
```

``` fansi

== Model ======================================================================= 

Variable Mapper : on 
Args : trestbps 

== T-Test ====================================================================== 

-- Summary ---------------------------------------------------------------------

───────────────────────────────────────────────
    term    estimate  true_mu  t_stat  p_val   
───────────────────────────────────────────────
  trestbps  131.624     120    11.537  <0.001  
───────────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

────────────────────────────────
    term    lower_95  upper_95  
────────────────────────────────
  trestbps  129.641   133.607   
────────────────────────────────
```

``` r

T_TEST(on(trestbps), heart, .mu = 120)
```

``` fansi
-- Summary ---------------------------------------------------------------------

───────────────────────────────────────────────
    term    estimate  true_mu  t_stat  p_val   
───────────────────────────────────────────────
  trestbps  131.624     120    11.537  <0.001  
───────────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

────────────────────────────────
    term    lower_95  upper_95  
────────────────────────────────
  trestbps  129.641   133.607   
────────────────────────────────
```

Using formula syntax

``` r

heart |>
    define_model(trestbps ~ 1) |>
    prepare(T_TEST, .mu = 120) |>
    # update(.mu = 120) |> 
    conclude()
```

``` fansi

== Model ======================================================================= 

Variable Mapper : formula 
Args : trestbps ~ 1 
    left_var : 1 
    right_var : 0 

== T-Test ====================================================================== 

-- Summary ---------------------------------------------------------------------

─────────────────────────────────────────────────────────
  groups     type     est_type    est    t-stat   pval   
─────────────────────────────────────────────────────────
    1     one sample     mu     131.624  11.537  <0.001  
─────────────────────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

──────────────────────────────────────────
  groups     type     lower_95  upper_95  
──────────────────────────────────────────
    1     one sample  129.641   133.606   
──────────────────────────────────────────
```

``` r

T_TEST(trestbps ~ 1, heart, .mu = 120)
```

``` fansi
-- Summary ---------------------------------------------------------------------

─────────────────────────────────────────────────────────
  groups     type     est_type    est    t-stat   pval   
─────────────────────────────────────────────────────────
    1     one sample     mu     131.624  11.537  <0.001  
─────────────────────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

──────────────────────────────────────────
  groups     type     lower_95  upper_95  
──────────────────────────────────────────
    1     one sample  129.641   133.606   
──────────────────────────────────────────
```

``` r

t_test(heart, trestbps ~ 1, mu = 120)
```

``` fansi
# A tibble: 1 × 7
  .y.      group1 group2         n statistic    df        p
* <chr>    <chr>  <chr>      <int>     <dbl> <dbl>    <dbl>
1 trestbps 1      null model   303      11.5   302 9.34e-26
```

``` r

t.test(heart$trestbps, mu = 120)
```


        One Sample t-test

    data:  heart$trestbps
    t = 11.537, df = 302, p-value < 2.2e-16
    alternative hypothesis: true mean is not equal to 120
    95 percent confidence interval:
     129.6411 133.6065
    sample estimates:
    mean of x 
     131.6238 

``` r

t.test(trestbps ~ 1, heart, mu = 120)
```


        One Sample t-test

    data:  trestbps
    t = 11.537, df = 302, p-value < 2.2e-16
    alternative hypothesis: true mean is not equal to 120
    95 percent confidence interval:
     129.6411 133.6065
    sample estimates:
    mean of x 
     131.6238 

### Verdict

All of the packages addresses the problem by performing one-sample
t-test in a single line of code — it’s good since it is easy,
nonetheless. However, what [statim](https://s7-stats.github.io/statim/)
buys instead is legibility of intent:
[`define_model()`](https://s7-stats.github.io/statim/dev/reference/layout-define-base.md),
[`prepare()`](https://s7-stats.github.io/statim/dev/reference/prepare.md),
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
— chain them and it reads like a sentence, and you can do more with
[statim](https://s7-stats.github.io/statim/)’s main API, whereas
`t.test(x, mu = 120)` reads like an API you have to already know. And
also, `ttest-on` can utilize
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md),
but it is not covered for the reason being the usage is not too
different on declaring `.mu` argument.

Interpretation: 131.6 mmHg average, significantly above 120 (p \<
0.001). This cohort runs elevated.

## Question 2: Does max heart rate differ by sex?

H_0:
\mu\_{\text{thalach}\mid\text{sex=Female}}=\mu\_{\text{thalach}\mid\text{sex=Male}}
\qquad H_1: \mu\_{\text{thalach}\mid\text{sex=Female}} \neq
\mu\_{\text{thalach}\mid\text{sex=Male}}

### Codes

- statim
- rstatix
- Base R

There are three layouts to perform two-sample t-test:

Using `on()`

This version requires `via("two_sample")` after `prepare(T_TEST)` to
perform two-sample t-test. Since it requires `via("two_sample")`, you
can’t use its eager form/one liner code.

``` r

female = heart$thalach[heart$sex == "Female"]
male = heart$thalach[heart$sex == "Male"]

# Requires via("two_sample")
# To perform two-sample t-test with `on()` layout
define_model(on(female, male)) |>
    prepare(T_TEST) |>
    via("two_sample") |>
    state_null(
        MU(female) == MU(male)
    ) |>
    conclude()
```

``` fansi

== Model ======================================================================= 

Variable Mapper : on 
Args : female, male 

== T-Test · two_sample ========================================================= 

-- Summary ---------------------------------------------------------------------

────────────────────────────────────────────────────────
        group         estimate  t_stat    df     p_val  
────────────────────────────────────────────────────────
  1*female + -1*male   2.164    0.818   219.790  0.414  
────────────────────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

──────────────────────────────────────────
        group         lower_95  upper_95  
──────────────────────────────────────────
  1*female + -1*male   -3.050    7.378    
──────────────────────────────────────────
```

*Note: Using
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md)
is optional, unless the full null hypothesis expression is required.*

Using `x_by()`

``` r

heart |>
    define_model(x_by(thalach, sex)) |>
    prepare(T_TEST) |>
    state_null(
        MU(thalach, sex == "Female") == MU(thalach, sex == "Male")
    ) |>
    conclude()
```

``` fansi

== Model ======================================================================= 

Variable Mapper : x_by 
Args : thalach | sex 
    x_vars : 1 
    by_vars : 1 

== T-Test ====================================================================== 

-- Summary ---------------------------------------------------------------------

───────────────────────────────────────────
  group  estimate  t_stat    df     p_val  
───────────────────────────────────────────
   sex    2.164    0.818   219.790  0.414  
───────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

─────────────────────────────
  group  lower_95  upper_95  
─────────────────────────────
   sex    -3.050    7.378    
─────────────────────────────
```

``` r

T_TEST(x_by(thalach, sex), heart)
```

``` fansi
-- Summary ---------------------------------------------------------------------

───────────────────────────────────────────
  group  estimate  t_stat    df     p_val  
───────────────────────────────────────────
   sex    -2.164   -0.818  219.790  0.414  
───────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

─────────────────────────────
  group  lower_95  upper_95  
─────────────────────────────
   sex    -7.378    3.050    
─────────────────────────────
```

*Note: Using
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md)
is optional, unless the full null hypothesis expression is required.*

Using formula syntax

Currently, the `<formula>` layout doesn’t have translation for
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md).

``` r

heart |>
    define_model(thalach ~ sex) |>
    prepare(T_TEST) |>
    conclude()
```

``` fansi

== Model ======================================================================= 

Variable Mapper : formula 
Args : thalach ~ sex 
    left_var : 1 
    right_var : 1 

== T-Test ====================================================================== 

-- Summary ---------------------------------------------------------------------

──────────────────────────────────────────────────────
  groups     type     est_type   est   t-stat  pval   
──────────────────────────────────────────────────────
   sex    two sample  mu_diff   2.164  0.818   0.414  
──────────────────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

──────────────────────────────────────────
  groups     type     lower_95  upper_95  
──────────────────────────────────────────
   sex    two sample   -3.051    7.378    
──────────────────────────────────────────
```

``` r

T_TEST(thalach ~ sex, heart)
```

``` fansi
-- Summary ---------------------------------------------------------------------

──────────────────────────────────────────────────────
  groups     type     est_type   est   t-stat  pval   
──────────────────────────────────────────────────────
   sex    two sample  mu_diff   2.164  0.818   0.414  
──────────────────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

──────────────────────────────────────────
  groups     type     lower_95  upper_95  
──────────────────────────────────────────
   sex    two sample   -3.051    7.378    
──────────────────────────────────────────
```

``` r

t_test(heart, thalach ~ sex)
```

``` fansi
# A tibble: 1 × 8
  .y.     group1 group2    n1    n2 statistic    df     p
* <chr>   <chr>  <chr>  <int> <int>     <dbl> <dbl> <dbl>
1 thalach Female Male      96   207     0.818  220. 0.414
```

Two forms, but the `<formula>` interface is usually more preferred than
the regular vector one. For the regular vector, we can use the same
vector from the [statim](https://s7-stats.github.io/statim/) section.

Regular Vector

``` r

t.test(female, male)
```


        Welch Two Sample t-test

    data:  female and male
    t = 0.8178, df = 219.79, p-value = 0.4144
    alternative hypothesis: true difference in means is not equal to 0
    95 percent confidence interval:
     -3.050537  7.377831
    sample estimates:
    mean of x mean of y 
     151.1250  148.9614 

Formula Syntax

``` r

t.test(thalach ~ sex, data = heart)
```


        Welch Two Sample t-test

    data:  thalach by sex
    t = 0.8178, df = 219.79, p-value = 0.4144
    alternative hypothesis: true difference in means between group Female and group Male is not equal to 0
    95 percent confidence interval:
     -3.050537  7.377831
    sample estimates:
    mean in group Female   mean in group Male 
                151.1250             148.9614 

### Verdict

This is where the two designs actually diverge, not just in syntax.
Empirically, [statim](https://s7-stats.github.io/statim/),
[rstatix](https://rpkgs.datanovia.com/rstatix/), and base R treat
“compare two groups” as something the `<formula>` already encodes,
`thalach ~ sex` says everything. However,
[statim](https://s7-stats.github.io/statim/) goes beyond that with the
occurence of
[`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md) and
[`on()`](https://s7-stats.github.io/statim/dev/reference/on.md).

- [`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md)
  says the same thing, but then lets you go further: this layout has
  [`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md)
  translation, and you can write out
  `MU(thalach, sex == "Female") == MU(thalach, sex == "Male")` as an
  actual algebraic expression, group filters and all. There’s an infix
  version `%by%` (e.g. `thalach %by% sex`) which combines the depiction
  of formula syntax and the logic of
  [`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md).
- [`on()`](https://s7-stats.github.io/statim/dev/reference/on.md), on
  the other hand, is another form of `<var_id>` mapper as
  [`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md).
  It treats the variables to be independent to each other, and its null
  hypothesis expression doesn’t use the `<sex == "Male">` `given`
  argument, rather something like `MU(female) == MU(male)`.

[statim](https://s7-stats.github.io/statim/) has more “typing” for a
question this simple. But “more typing” has more “signal” and has less
“noise” (i.e. this package intends to strengthen the signal to noise
ratio to conduct hypothesis testing), and starts becoming convenient for
an actual null hypothesis testing, i.e. the moment the hypothesis isn’t
a straight group comparison anymore.

Interpretation: no difference (p = 0.414). Sex isn’t doing any
explanatory work here.

## Question 3: Does max heart rate fall with age?

H_0: \rho\_{\text{thalach, age}}=0 \qquad H_1: \rho\_{\text{thalach,
age}} \neq 0

### Code

- statim
- rstatix
- Base R

There are two layouts to perform correlation test:

Using `rel()`

``` r

heart |>
    define_model(rel(thalach, age)) |>
    prepare(COR_TEST) |>
    state_null(
        RHO(thalach, age) == 0
    ) |>
    conclude()
```

``` fansi

== Model ======================================================================= 

Variable Mapper : rel 
Args : thalach ; age 
    x_vars : 1 
    resp_vars : 1 

== Correlation Test ============================================================ 

-- Summary ---------------------------------------------------------------------

───────────────────────────────────────────────────
      pair       estimate  statistic  df   p_val   
───────────────────────────────────────────────────
  age ~ thalach   -0.398    -7.539    301  <0.001  
───────────────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

─────────────────────────────────────
      pair       lower_95  upper_95  
─────────────────────────────────────
  age ~ thalach   -0.489    -0.299   
─────────────────────────────────────
```

``` r

COR_TEST(rel(thalach, age), heart)
```

``` fansi
-- Summary ---------------------------------------------------------------------

───────────────────────────────────────────────────
      pair       estimate  statistic  df   p_val   
───────────────────────────────────────────────────
  age ~ thalach   -0.398    -7.539    301  <0.001  
───────────────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

─────────────────────────────────────
      pair       lower_95  upper_95  
─────────────────────────────────────
  age ~ thalach   -0.489    -0.299   
─────────────────────────────────────
```

*Note: Using
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md)
is optional, unless the full null hypothesis expression is required.*

Using formula syntax

``` r

heart |>
    define_model(age ~ thalach) |>
    prepare(COR_TEST) |>
    conclude()
```

``` fansi

== Model ======================================================================= 

Variable Mapper : formula 
Args : age ~ thalach 
    left_var : 1 
    right_var : 1 

== Correlation Test ============================================================ 

-- Summary ---------------------------------------------------------------------

───────────────────────────────────────────────────
      pair       estimate  statistic  df   p_val   
───────────────────────────────────────────────────
  age ~ thalach   -0.398    -7.539    301  <0.001  
───────────────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

─────────────────────────────────────
      pair       lower_95  upper_95  
─────────────────────────────────────
  age ~ thalach   -0.489    -0.299   
─────────────────────────────────────
```

``` r

COR_TEST(age ~ thalach, heart)
```

``` fansi
-- Summary ---------------------------------------------------------------------

───────────────────────────────────────────────────
      pair       estimate  statistic  df   p_val   
───────────────────────────────────────────────────
  age ~ thalach   -0.398    -7.539    301  <0.001  
───────────────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

─────────────────────────────────────
      pair       lower_95  upper_95  
─────────────────────────────────────
  age ~ thalach   -0.489    -0.299   
─────────────────────────────────────
```

``` r

rstatix::cor_test(heart, age, thalach)
```

``` fansi
# A tibble: 1 × 9
  var1  var2      cor statistic    df        p conf.low conf.high method 
  <chr> <chr>   <dbl>     <dbl> <int>    <dbl>    <dbl>     <dbl> <chr>  
1 age   thalach  -0.4     -7.54   301 5.63e-13   -0.489    -0.299 Pearson
```

``` r

cor.test(~ thalach + age, heart)
```


        Pearson's product-moment correlation

    data:  thalach and age
    t = -7.5386, df = 301, p-value = 5.628e-13
    alternative hypothesis: true correlation is not equal to 0
    95 percent confidence interval:
     -0.4892312 -0.2992831
    sample estimates:
           cor 
    -0.3985219 

### Verdict

Small warning: the convention of base R’s `<formula>` here is
`~ thalach + age`, not `thalach ~ age`. There’s no dependent variable in
a correlation, so the usual left/right convention doesn’t mean anything,
but it’s easy to assume it does and misread the formula. Consequently,
`{rel(thalach, age)}` sidesteps the ambiguity by just naming both
variables. [rstatix](https://rpkgs.datanovia.com/rstatix/) takes some
roundabout by borrowing
[`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html)-style
column picking, and the selected variables always parsed in pairwise
combination (*Note: all the combinations themselves*).

Interpretation: a real, moderate negative correlation (r = -0.398, p \<
0.001). Heart rate ceiling drops with age, as expected.

## Question 4: Is high fasting blood sugar unusually common in men?

H_0: \pi=0.15 \qquad H_1: \pi\neq0.15

Take note that all of the packages require “constants” (at least for now
for [statim](https://s7-stats.github.io/statim/)) as givens, namely the
number of successes (`n_high_fbs`) and the number of observations
(`n_males`). Let us prepare the data first:

``` r

males = keep_when(heart, sex == "Male")
n_high_fbs = sum(males$fbs == "High")
n_males = nrow(males)
```

### Code

- statim
- rstatix
- Base R

By default,
[`P_TEST()`](https://s7-stats.github.io/statim/dev/reference/P_TEST.md)
performs a binomial test.

``` r

define_model(prop(n_high_fbs, n_males)) |>
    prepare(P_TEST) |>
    state_null(
        PI() == 0.15
    ) |>
    conclude()
```

``` fansi

== Model ======================================================================= 

Variable Mapper : prop 
Args : 33 / 207 
    x : 33 
    n : 207 

== Proportion Test ============================================================= 

-- Summary ---------------------------------------------------------------------

───────────────────────────────────────────────
  x    n   true_p  estimate  statistic  p_val  
───────────────────────────────────────────────
  33  207  0.150    0.159       33      0.697  
───────────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

──────────────────────
  lower_95  upper_95  
──────────────────────
   0.112     0.216    
──────────────────────
```

``` r

P_TEST(prop(n_high_fbs, n_males), .p = 0.15)
```

``` fansi
-- Summary ---------------------------------------------------------------------

───────────────────────────────────────────────
  x    n   true_p  estimate  statistic  p_val  
───────────────────────────────────────────────
  33  207  0.150    0.159       33      0.697  
───────────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

──────────────────────
  lower_95  upper_95  
──────────────────────
   0.112     0.216    
──────────────────────
```

*Note: Using
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md)
here highly is optional, as you can just supply `.p` argument, unless
either the full null hypothesis expression is required or you want to be
explicit.*

``` r

binom_test(n_high_fbs, n_males, p = 0.15)
```

``` fansi
# A tibble: 1 × 6
      n estimate conf.low conf.high     p p.signif
* <int>    <dbl>    <dbl>     <dbl> <dbl> <chr>   
1   207    0.159    0.112     0.217 0.697 ns      
```

``` r

binom.test(n_high_fbs, n_males, p = 0.15)
```


        Exact binomial test

    data:  n_high_fbs and n_males
    number of successes = 33, number of trials = 207, p-value = 0.6969
    alternative hypothesis: true probability of success is not equal to 0.15
    95 percent confidence interval:
     0.1123500 0.2165365
    sample estimates:
    probability of success 
                 0.1594203 

### Verdict

No `<formula>` anywhere in this section because the givens are
“constants”, not assigned in “variables”. A proportion test is just two
numbers, `x` and `n`, and all three packages treat it that way. The only
real question is where those two numbers live: as positional arguments
(`x, n, p =`) in base R and
[rstatix](https://rpkgs.datanovia.com/rstatix/), or wrapped in
[`prop()`](https://s7-stats.github.io/statim/dev/reference/prop.md) so
the pipeline keeps the same shape it had in Questions 1-3. Neither is
more correct; [statim](https://s7-stats.github.io/statim/)’s version is
considered to be only worth it if you’re already committed to the
pipeline for other reasons.

Interpretation: 33 of 207 men (15.9%), not distinguishable from the 15%
baseline (p = 0.697).

## Multiple Executions

Every question above ran one test through one layout.
[statim](https://s7-stats.github.io/statim/) has another way:
[`write_models()`](https://s7-stats.github.io/statim/dev/reference/write_models.md)
lets you batch several layouts of the *same* test into a single
pipeline, instead of writing out
`define_model() |> prepare() |> conclude()` once per layout:

``` r

out =
    heart |>
    write_models(
        mod1 = on(trestbps),
        mod2 = x_by(thalach, sex),
        mod3 = thalach ~ sex
    ) |>
    prepare(T_TEST) |>
    conclude()

out
```

``` fansi

── 3 models · T-Test ─────────────────────────────────────────────────────────── 

mod1 : <cld_exec>
mod2 : <cld_exec>
mod3 : <cld_exec>

Use display() to inspect individual results.
```

Each name becomes its own lazy model behind the scenes,
`prepare(T_TEST)` attaches the same test to all three at once, and
[`conclude()`](https://s7-stats.github.io/statim/dev/reference/conclude.md)
runs each independently and hands back a `<multi_exec>`:
[`tidy()`](https://s7-stats.github.io/statim/dev/reference/tidy.md) or
[`display()`](https://s7-stats.github.io/statim/dev/reference/display.md)
on it to inspect the individual results, as covered in [Execution and
Retrieval of
Outputs](https://s7-stats.github.io/statim/dev/articles/pointers/execution-methods.html#multiple-executions).

``` r

display(out, 2)
```

``` fansi

1. mod1

== Model ======================================================================= 

Variable Mapper : on 
Args : trestbps 

== T-Test ====================================================================== 

-- Summary ---------------------------------------------------------------------

────────────────────────────────────────────────
    term    estimate  true_mu  t_stat   p_val   
────────────────────────────────────────────────
  trestbps  131.624      0     130.639  <0.001  
────────────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

────────────────────────────────
    term    lower_95  upper_95  
────────────────────────────────
  trestbps  129.641   133.607   
────────────────────────────────



2. mod2

== Model ======================================================================= 

Variable Mapper : x_by 
Args : thalach | sex 
    x_vars : 1 
    by_vars : 1 

== T-Test ====================================================================== 

-- Summary ---------------------------------------------------------------------

───────────────────────────────────────────
  group  estimate  t_stat    df     p_val  
───────────────────────────────────────────
   sex    -2.164   -0.818  219.790  0.414  
───────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

─────────────────────────────
  group  lower_95  upper_95  
─────────────────────────────
   sex    -7.378    3.050    
─────────────────────────────
```

On a side note,
[`prepare()`](https://s7-stats.github.io/statim/dev/reference/prepare.md)’s
`...` forwards into the spec on a
[`write_models()`](https://s7-stats.github.io/statim/dev/reference/write_models.md)
batch too, the same way it already does on a single `<def_var>`. So
`.mu = 120` below reaches every model in the batch whose `fn` actually
has a `.mu` formal:

``` r

heart |>
    write_models(
        mod1 = on(trestbps),
        mod3 = thalach ~ sex
    ) |>
    prepare(T_TEST, .mu = 120) |>
    conclude()
```

``` fansi

── 2 models · T-Test ─────────────────────────────────────────────────────────── 

mod1 : <cld_exec>
mod3 : <cld_exec>

Use display() to inspect individual results.
```

`mod1` picks it up because its one-sample `fn` declares `.mu`; `mod3`’s
two-sample `fn` doesn’t, so the same argument is simply ignored for that
model rather than erroring — `inject_and_run()` only pulls from
`all_args` what a given `fn`’s formals actually ask for, whether the
model came from a batch or a single-model pipeline.

Two things need extra care once a batch mixes layouts like this, rather
than repeating the same layout across models.

### `state_null()` doesn’t span mixed layouts

Not every layout parses a stated hypothesis the same way. Recall from
[Question 2](#q2): `x_by(thalach, sex)`’s `claim_parser` reads group
filters straight out of the claim (`MU(thalach, sex == "Female")`),
[`on()`](https://s7-stats.github.io/statim/dev/reference/on.md) has no
such filter at all, and the `<formula>` layout has no `claim_parser`
translation of its own yet. A single
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md)
call attached to a
[`write_models()`](https://s7-stats.github.io/statim/dev/reference/write_models.md)
batch would have to mean the same thing across all three shapes at once.
Therefore, right now,
[`state_null()`](https://s7-stats.github.io/statim/dev/reference/null-hyp.md)
isn’t wired up for `<multi_lazy>` objects.

In practice, a
[`write_models()`](https://s7-stats.github.io/statim/dev/reference/write_models.md)
batch is for comparing layouts (or variables) against a test’s own
default hypothesis, not for stating one numeric claim across a batch of
differently-shaped models. If a specific hypothesis needs testing, stick
to one `define_model() |> prepare() |> state_null() |> conclude()`
pipeline per layout, the way Questions 1-3 do it above.

### `via()` applies the same call to every model in the batch

[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md) on a
`<multi_lazy>` doesn’t ask which model it’s talking to — the method name
and any arguments you pass are applied to every model in the batch.
That’s only safe when every layout present shares the same
estimation-method vocabulary.
[`on()`](https://s7-stats.github.io/statim/dev/reference/on.md)’s
one-sample t-test and
[`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md)’s
two-sample t-test don’t:
[`on()`](https://s7-stats.github.io/statim/dev/reference/on.md) needs
`via("two_sample")` to compare two vectors (see [Question 2](#q2)’s
first tab), while
[`x_by()`](https://s7-stats.github.io/statim/dev/reference/x_by.md) is
already two-sample by default and has no reason to register that variant
at all. Mixing the two in one batch and calling
[`via()`](https://s7-stats.github.io/statim/dev/reference/via.md) once
means the variant name has to be registered, with matching arguments,
for every model type present:

``` r

heart |>
    write_models(
        mod1 = on(trestbps),
        mod2 = x_by(thalach, sex)
    ) |>
    prepare(T_TEST) |>
    # registered for on(); 
    # x_by() is two-sample already and 
    # it does not have it
    via("two_sample") |>   
    conclude()
```

     [1m [33mError [39m in `method(via, list(statim::test_lazy, class_character))`: [22m
     [1m [22m [33m! [39m No variant  [34m"two_sample" [39m registered for model type  [34m"x_by" [39m.
     [36mℹ [39m Available variants:  [34m"contrast" [39m,  [34m"multi" [39m,  [34m"boot" [39m, and  [34m"permute" [39m.

The safer default is to keep a batch to layouts that share the same
estimation method: either all left at `base`, or all recalibrated to a
variant every model type in the batch actually registers, and then fall
back to separate single-model pipelines the moment the variants diverge.

## Conclusion

[statim](https://s7-stats.github.io/statim/) is a high-level package for
statistical inference, particularly hypothesis testing, because of the
abstractions similar to [ggplot2](https://ggplot2.tidyverse.org). It
also makes sure the simplicity from base R and other packages like
[rstatix](https://rpkgs.datanovia.com/rstatix/) is carried, otherwise
the steeper learning curve will get you. One-liner codes exist, the
piped/grammar syntax is inherited to make sure the spirits of
[ggplot2](https://ggplot2.tidyverse.org) and
[dplyr](https://dplyr.tidyverse.org) exist on
[statim](https://s7-stats.github.io/statim/) space.

What this vignette hasn’t shown: null hypotheses that aren’t
conventional as you saw on most books, e.g. testing 3 \mu_x =2\mu_y.
This vignette shows the actual bet
[statim](https://s7-stats.github.io/statim/) is making: a consistent
`define_model() |> prepare() |> state_null() |> conclude()` shape you
can extend once, rather than learn a new argument (or a new type of
syntax) convention per test. Four questions above are pretty
straightforward and [statim](https://s7-stats.github.io/statim/) has
strong “flavor” for those questions that simple, so rather ubiquitously
they aren’t the right test of that bet. You can make difference on the
more complex ones. If you wanna know what’s beyond testing the equality
in the null hypothesis, there’s a dedicated
[example](https://s7-stats.github.io/statim/dev/articles/usage/beyond-null.md)
for that.
