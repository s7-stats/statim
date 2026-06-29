# Hypothesis Testing with {statim}

## Brief Introduction

This vignette not just to showcase how
[statim](https://github.com/s7-stats/statim) addresses the real-world
problem involving statistical inference, this also compares
[statim](https://github.com/s7-stats/statim) against different packages,
namely the base R itself and
[rstatix](https://rpkgs.datanovia.com/rstatix/).

## The Problem

Here’s a hypothetical real world scenario: Each question maps directly
to a standard inferential testLet’s say a cardiologist hands you a
dataset of 303 patients from the Cleveland Clinic. She has three
questions:

1.  Is the average resting blood pressure of patients **different from
    the clinical normal of 120 mmHg**?

2.  Do men and women differ in their maximum heart rate achieved during
    stress testing?

3.  Is there a linear relationship between age and maximum heart rate?

4.  Are male patients more likely to have fasting blood sugar **above
    120 mg/dL** than female patients?

> Note: This vignette tries to evaluate the readability,
> reproducibility, and the abundance of boilerplate codes of the chosen
> packages here while doing it. These problems are derived from a
> dataset from Daniel Bourke’s “zero-to-mastery-ml” GitHub repository
> called “heart disease”.

## Setup

Let us derive the usual workflow of
[statim](https://github.com/s7-stats/statim)’s author in his daily basis
on statistical analysis. Here, he uses [box](https://klmr.me/box/)
package, another package import system into R, because it enforces
explicit imports, which makes the pipeline written in R is more
manageable. Here are the imports:

``` r

box::use(
    stats[t.test, cor.test, binom.test],
    statim[
        TTEST, CORTEST, P_TEST, 
        # Current grammars
        define_model, prepare, via, state_null, conclude, 
        # Mappers
        x_by, rel, prop, on, 
        MU, RHO, PI
    ],
    rstatix[t_test, cor_test, binom_test]
)
```

Then here are the imports for the miscellaneous things:

``` r

box::use(
    dplyr[keep_when = filter, mutate],
    readr[read_csv]
)
```

Let us import `heart-disease.csv` from this
[link](https://github.com/mrdbourke/zero-to-mastery-ml/blob/master/data/heart-disease.csv)
using
[`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html)

``` r

heart = read_csv("https://raw.githubusercontent.com/mrdbourke/zero-to-mastery-ml/master/data/heart-disease.csv") |> 
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

A quick look at the variables we care about:

| Column     | Type       | Description                                        |
|------------|------------|----------------------------------------------------|
| `trestbps` | Continuous | Resting blood pressure (mm Hg)                     |
| `thalach`  | Continuous | Maximum heart rate achieved                        |
| `age`      | Continuous | Age in years                                       |
| `sex`      | Binary     | Sex (0 = Female, 1 = Male)                         |
| `fbs`      | Binary     | Fasting blood sugar \> 120 mg/dL (0 = No, 1 = Yes) |

## Question 1

> *Is the mean resting blood pressure different from 120 mmHg?*

The clinical reference for normal systolic blood pressure is 120 mmHg.
We want to test whether patients in this cohort are systematically
elevated. This is a classic one-sample t-test example.

Here’s the null hypothesis we want to test:

H_0: \mu=120

Against:

H_1: \mu\neq120

- statim
- rstatix
- Base R
- Interpretation of the codes

There are two ways to make this done using this package:

1.  We can use either the main semantic:

    1.  [`on()`](https://s7-stats.github.io/statim/reference/on.md)

        ``` r

        heart |> 
            define_model(on(trestbps)) |> 
            prepare(TTEST) |> 
            conclude()
        ```

        ``` fansi

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
         
        ```

    2.  `<formula>`

        ``` r

        heart |> 
            define_model(trestbps ~ 1) |> 
            prepare(TTEST) |> 
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

        ──────────────────────────────────────────────────────────
          groups     type     est_type    est    t-stat    pval   
        ──────────────────────────────────────────────────────────
            1     one sample     mu     131.624  130.639  <0.001  
        ──────────────────────────────────────────────────────────


        -- Confidence Interval ---------------------------------------------------------

        ──────────────────────────────────────────
          groups     type     lower_95  upper_95  
        ──────────────────────────────────────────
            1     one sample  129.641   133.606   
        ──────────────────────────────────────────
        ```

2.  Or the eager form:

    ``` r

    TTEST(on(trestbps), heart, .mu = 120)
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

    ``` r

    TTEST(trestbps ~ 1, heart, .mu = 120)
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

This can be done with a one-liner:

``` r

t_test(heart, trestbps ~ 1, mu = 120)
```

``` fansi
# A tibble: 1 × 7
  .y.      group1 group2         n statistic    df        p
* <chr>    <chr>  <chr>      <int>     <dbl> <dbl>    <dbl>
1 trestbps 1      null model   303      11.5   302 9.34e-26
```

This can be done with a one-liner, as well. But there are two
approaches:

1.  Using a vector-supplied argument

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

2.  A formula:

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

------------------------------------------------------------------------

All of the packages are using `<formula>` interface. This is how R
addresses the simple problem with just one line of code — it just shows
how high level R can be, making a problem much simpler. There’s an
exception, [statim](https://github.com/s7-stats/statim) has an approach
which leverages the piped/grammar syntax form, which brings a new
approach for a readable and composable pipeline, inheriting the spirit
of [ggplot2](https://ggplot2.tidyverse.org) semantics.

## Question 2

> *Do men and women achieve different maximum heart rates during stress
> testing?*

Maximum heart rate (`thalach`) is a continuous outcome; `sex` is our
grouping variable with two independent levels. This is addressed using
independent two-sample t-test.

Here’s the null hypothesis we want to test:

H_0: \mu\_{\text{thalach}\| \text{sex=Female}}=\mu\_{\text{thalach}\|
\text{sex=Male}}

Against:

H_1: \mu\_{\text{thalach}\| \text{sex=Female}} \neq
\mu\_{\text{thalach}\| \text{sex=Male}}

- statim
- rstatix
- Base R
- Interpretation of the codes

There are two ways to make this done using this package:

1.  The piped/grammar syntax.

    1.  Using
        [`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md)

        ``` r

        heart |> 
            define_model(x_by(thalach, sex)) |> 
            prepare(TTEST) |> 
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

    2.  `<formula>`

        ``` r

        heart |> 
            define_model(x_by(thalach, sex)) |> 
            prepare(TTEST) |> 
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

2.  Eager form

    ``` r

    TTEST(x_by(thalach, sex), heart)
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

    ``` r

    TTEST(thalach ~ sex, heart)
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

This package easily addresses this with its `<formula>` interface.

``` r

t_test(heart, thalach ~ sex)
```

``` fansi
# A tibble: 1 × 8
  .y.     group1 group2    n1    n2 statistic    df     p
* <chr>   <chr>  <chr>  <int> <int>     <dbl> <dbl> <dbl>
1 thalach Female Male      96   207     0.818  220. 0.414
```

Two approaches:

1.  Bare vector-supplied argument

    ``` r

    # Fast but loses the readability form
    t.test(
        heart$thalach[heart$sex == "Female"],
        heart$thalach[heart$sex == "Male"]
    )
    ```


            Welch Two Sample t-test

        data:  heart$thalach[heart$sex == "Female"] and heart$thalach[heart$sex == "Male"]
        t = 0.8178, df = 219.79, p-value = 0.4144
        alternative hypothesis: true difference in means is not equal to 0
        95 percent confidence interval:
         -3.050537  7.377831
        sample estimates:
        mean of x mean of y 
         151.1250  148.9614 

2.  Formula

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

------------------------------------------------------------------------

`<formula>` object is such a good convenient tool that makes statistical
modelling much easier. Except
[statim](https://github.com/s7-stats/statim) has another way to shape
the pipeline into different layout which also be able call the columns:
a `<var_id>` mapper called
[`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md). This
mapper is another good function that declares the column `x` being
compared by the grouping column `group`. The categorical groups under
`group` column are used as a reference on population parameter
`<param_obj>` objects,
i.e. [`MU()`](https://s7-stats.github.io/statim/reference/MU.md) in this
case.

As for the declaration of null hypothesis part: Both base R and
[rstatix](https://rpkgs.datanovia.com/rstatix/) do not have an ability
to declare the null hypothesis in algebraic form, rather they use
`alternative =` and `mu =`. [statim](https://github.com/s7-stats/statim)
brings this feature — declaration of null hypothesis in algebraic form.
This is implemented so that the intent of the null hypothesis we test is
more transparent. This is the newest feature of a declaration of the
null hypothesis in R, only in
[statim](https://github.com/s7-stats/statim) package.

## Question 3

> *Is there a linear relationship between age and maximum heart rate?*

Here, use a correlation test to address the problem. We expect an
inverse relationship: older patients tend to have lower maximum heart
rates. A Pearson correlation test lets us assess whether this
relationship is statistically distinguishable from zero.

Here’s the null hypothesis we want to test:

H_0: \rho\_{\text{thalach, age}}=0

Against:

H_1: \rho\_{\text{thalach, age}} \neq 0

- statim
- rstatix
- Base R
- Interpretation of the codes

There are two ways to make this done using this package:

1.  The piped/grammar syntax.

    1.  Using
        [`rel()`](https://s7-stats.github.io/statim/reference/rel.md)

        ``` r

        heart |> 
            define_model(rel(thalach, age)) |> 
            prepare(CORTEST) |> 
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

    2.  `<formula>`

        ``` r

        heart |> 
            define_model(thalach ~ age) |> 
            prepare(CORTEST) |> 
            conclude()
        ```

        ``` fansi

        == Model ======================================================================= 

        Variable Mapper : formula 
        Args : thalach ~ age 
            left_var : 1 
            right_var : 1 

        == Correlation Test ============================================================ 

        -- Summary ---------------------------------------------------------------------

        ───────────────────────────────────────────────────
              pair       estimate  statistic  df   p_val   
        ───────────────────────────────────────────────────
          thalach ~ age   -0.398    -7.539    301  <0.001  
        ───────────────────────────────────────────────────


        -- Confidence Interval ---------------------------------------------------------

        ─────────────────────────────────────
              pair       lower_95  upper_95  
        ─────────────────────────────────────
          thalach ~ age   -0.489    -0.299   
        ─────────────────────────────────────
        ```

2.  Eager form

    ``` r

    CORTEST(rel(thalach, age), heart)
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

    CORTEST(thalach ~ age, heart)
    ```

    ``` fansi
    -- Summary ---------------------------------------------------------------------

    ───────────────────────────────────────────────────
          pair       estimate  statistic  df   p_val   
    ───────────────────────────────────────────────────
      thalach ~ age   -0.398    -7.539    301  <0.001  
    ───────────────────────────────────────────────────


    -- Confidence Interval ---------------------------------------------------------

    ─────────────────────────────────────
          pair       lower_95  upper_95  
    ─────────────────────────────────────
      thalach ~ age   -0.489    -0.299   
    ─────────────────────────────────────
    ```

This package easily addresses this with its `<formula>` interface.

``` r

rstatix::cor_test(heart, age, thalach)
```

``` fansi
# A tibble: 1 × 8
  var1  var2      cor statistic        p conf.low conf.high method 
  <chr> <chr>   <dbl>     <dbl>    <dbl>    <dbl>     <dbl> <chr>  
1 age   thalach  -0.4     -7.54 5.63e-13   -0.489    -0.299 Pearson
```

Two approaches:

1.  Bare vector-supplied argument

    ``` r

    cor.test(heart$thalach, heart$age)
    ```


            Pearson's product-moment correlation

        data:  heart$thalach and heart$age
        t = -7.5386, df = 301, p-value = 5.628e-13
        alternative hypothesis: true correlation is not equal to 0
        95 percent confidence interval:
         -0.4892312 -0.2992831
        sample estimates:
               cor 
        -0.3985219 

2.  Formula

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

------------------------------------------------------------------------

Both [statim](https://github.com/s7-stats/statim) and base R are
leveraging high level API on defining the layout of the model being
analyzed — the former uses
[`rel()`](https://s7-stats.github.io/statim/reference/rel.md) (can also
use `<formula>` interface) and the latter uses `<formula>` interface,
except it follows not the `v ~ u` form, rather the `~ u + v` form, where
`u` is a numeric vector signifying the independent variable while `v` is
a numeric vector signifying the dependent variable.
[rstatix](https://rpkgs.datanovia.com/rstatix/) is oddly different from
these 2: it’s still high level except it follows the
[`dplyr::select()`](https://dplyr.tidyverse.org/reference/select.html)
selection method and the operation always interpreted in pairwise
method.

As usual from [statim](https://github.com/s7-stats/statim),
[`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md)
is used on
[`CORTEST()`](https://s7-stats.github.io/statim/reference/CORTEST.md)
and the only compatible `<param_obj>` is
[`RHO()`](https://s7-stats.github.io/statim/reference/RHO.md), which
refers to the population correlation \rho — the representation is
algebraic form, not in `alternative =` gotcha.

## Question 4

> *Is the proportion of male patients with high fasting blood sugar
> different from the population baseline of 15%?*

Here, use the binomial test to address this. Among male patients, we
want to test whether the observed rate of fasting blood sugar above 120
mg/dL deviates from an assumed baseline of 15%.

Let’s prepare the required data for this example:

- `males`` ``=`` ``keep_when``(``heart``, ``sex`` ``==`` ``"Male"``)`` ``n_high_fbs`` ``=`` `[`sum`](https://rdrr.io/r/base/sum.html)`(``males``$``fbs`` ``==`` ``"High"``)`` ``n_males`` ``=`` `[`nrow`](https://rdrr.io/r/base/nrow.html)`(``males``)`
- statim
- rstatix
- Base R
- Interpretation of the codes

Take note that the default (`base`) of
[`P_TEST()`](https://s7-stats.github.io/statim/reference/P_TEST.md)
always performs the binomial test. There are two ways to make this done
using this package:

1.  The piped/grammar syntax.

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

2.  Eager form

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

This package has `binom_test()` and has `x` and `n` as the first 2
arguments. Supply `n_high_fbs` to `x` (number of successes) and
`n_males` to `n` (number of trials), then set `p = 0.15` to test the
null hypothesis.

``` r

binom_test(n_high_fbs, n_males, p = 0.15)
```

``` fansi
# A tibble: 1 × 6
      n estimate conf.low conf.high     p p.signif
* <int>    <dbl>    <dbl>     <dbl> <dbl> <chr>   
1   207    0.159    0.112     0.217 0.697 ns      
```

`{stats}` standard library already has
[`binom.test()`](https://rdrr.io/r/stats/binom.test.html). The usage is
almost similar to
[`rstatix::binom_test()`](https://rpkgs.datanovia.com/rstatix/reference/binom_test.html).

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

------------------------------------------------------------------------

Pending…
