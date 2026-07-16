# Beyond Equality: Custom Hypotheses with {statim}

## Why this vignette exists

`vignette("htest", package = "statim")` covers the plain case: is one
mean different from a fixed value, are two means different from each
other, is a correlation zero. Every null hypothesis in that vignette
reduces to `MU(a) == MU(b)` or its one-sample cousin. That’s most of
what an intro course asks, but it isn’t all a textbook asks.

This vignette is about *using* weighted, non-zero-threshold claims, not
about how
[`state_null()`](https://s7-stats.github.io/statim/reference/null-hyp.md)
parses them. For the parsing mechanics, see
`vignette("hypothesis-expressions", package = "statim")` — this explains
how a coefficient and comparison value are pulled out of an expression
like `2 * MU(x) - MU(y) <= 0`, and why group order in that expression
matters.

Kutner, Nachtsheim, Neter, and Li’s *Applied Linear Statistical Models*
poses a different kind of question throughout its inference chapters:
not “are these equal,” but “is a specific weighted combination of these
parameters above, below, or at some threshold.” That’s a linear
contrast, and [statim](https://github.com/s7-stats/statim) supports it
through `via("contrast")` on the
[`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md) layout,
accepting arbitrary weights (`.w`) and a comparison value (`.mu`) rather
than the fixed `+1`/`-1` split a plain two-sample test assumes.

This vignette isn’t reproducing a specific textbook problem. The book’s
own contrast examples mostly involve three or more groups (its ANOVA
chapters, already covered by
`vignette("anova-mod", package = "statim")`), while `TTEST`’s
[`x_by()`](https://s7-stats.github.io/statim/reference/x_by.md)’s
`contrast` variant is built for exactly two. What it does share with the
book is the *question type*: a weighted, non-zero-threshold claim
instead of a plain equality. The two questions below work that question
type through [statim](https://github.com/s7-stats/statim), using the
same Welch-Satterthwaite machinery the book’s contrast tests are built
on.

### Sample Problem

The dataset: `ToothGrowth`, built into base R. Guinea pig odontoblast
(tooth cell) length under two delivery methods for vitamin C:

- Ascorbic acid (`VC`)
- Orange juice (`OJ`)

The data is bundled with R itself, so this vignette builds without a
network call or an external file.

The questions, framed the way a textbook exercise would:

1.  [Does orange juice outperform ascorbic acid by a specific,
    clinically meaningful margin, not just “any” amount?](#q1)
2.  [Is the delivery-method gap at most half of a fixed reference
    length?](#q2)

## Setup

``` r

box::use(
    statim[
        T_TEST, define_model, prepare, via, state_null, conclude,
        x_by, MU
    ]
)
```

`ToothGrowth` ships with R, so no import step is needed beyond loading
it:

``` r

data(ToothGrowth)
```

## Question 1: Does OJ beat VC by more than 2 units?

H_0: \mu\_{\text{OJ}} - \mu\_{\text{VC}} \leq 2 \qquad H_1:
\mu\_{\text{OJ}} - \mu\_{\text{VC}} \> 2

A plain two-sample test only asks whether the two means differ at all. A
textbook contrast question is sharper: is OJ’s advantage over VC big
enough to matter, not just big enough to be non-zero. Stating `2` as the
comparison value, rather than `0`, is what turns this into a genuine
contrast rather than a relabeled equality test.

``` r

ToothGrowth |>
    define_model(x_by(len, supp)) |>
    prepare(T_TEST) |>
    state_null(
        MU(len, supp == "OJ") - MU(len, supp == "VC") <= 2
    ) |>
    via("contrast") |>
    conclude()
```

``` fansi

== Model ======================================================================= 

Variable Mapper : x_by 
Args : len | supp 
    x_vars : 1 
    by_vars : 1 

== T-Test · contrast =========================================================== 

-- Summary ---------------------------------------------------------------------

──────────────────────────────────────────
  group  estimate  t_stat    df    p_val  
──────────────────────────────────────────
  supp    3.700    0.880   55.310  0.191  
──────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

─────────────────────────────
  group  lower_95  upper_95  
─────────────────────────────
  supp    0.468      Inf     
─────────────────────────────
```

Interpretation:

- The estimated OJ-VC gap is 3.70, above the 2-unit bar, but `t_stat`
  (0.880) and `p_val` (0.191) are testing the gap *against* that bar,
  not against zero. At \alpha = 0.05, `p_val` is too large to reject
  H_0: there isn’t enough evidence that OJ beats VC by more than 2
  units. The one-sided 95% lower bound of 0.468 makes the same point —
  the true gap could plausibly be well under 2.

## Question 2: Does twice OJ’s mean still fall short of VC’s?

H_0: 2\cdot\mu\_{\text{OJ}} - \mu\_{\text{VC}} \leq 0 \qquad H_1:
2\cdot\mu\_{\text{OJ}} - \mu\_{\text{VC}} \> 0

Unlike Question 1, the two sides here carry different weights — `2` on
one group, `1` on the other — so this isn’t a rescaled version of the
same claim. There’s no way to hand base R’s
[`t.test()`](https://rdrr.io/r/stats/t.test.html) a coefficient per
group; the comparison has to be pre-computed by hand before the call.
Here the coefficients live directly in the claim:

``` r

ToothGrowth |>
    define_model(x_by(len, supp)) |>
    prepare(T_TEST) |>
    state_null(
        # If no coefficient 
        # it is hidden and it contains a coefficient of 1
        2 * MU(len, supp == "OJ") - MU(len, supp == "VC") <= 0
    ) |>
    via("contrast") |>
    conclude()
```

``` fansi

== Model ======================================================================= 

Variable Mapper : x_by 
Args : len | supp 
    x_vars : 1 
    by_vars : 1 

== T-Test · contrast =========================================================== 

-- Summary ---------------------------------------------------------------------

───────────────────────────────────────────
  group  estimate  t_stat    df    p_val   
───────────────────────────────────────────
  supp    24.363   8.563   48.690  <0.001  
───────────────────────────────────────────


-- Confidence Interval ---------------------------------------------------------

─────────────────────────────
  group  lower_95  upper_95  
─────────────────────────────
  supp    19.593     Inf     
─────────────────────────────
```

Interpretation:

- `estimate` (24.363) is 2 \cdot \bar{x}\_{\text{OJ}} -
  \bar{x}\_{\text{VC}} itself, since `.mu` is 0 here. `p_val` is below
  `0.001`, so H_0 is rejected: twice OJ’s mean does not fall short of
  VC’s — it’s well above it. The 95% lower bound of 19.593 says the same
  thing, since it sits nowhere near 0.

## References

Kutner, M. H., Nachtsheim, C. J., Neter, J., & Li, W. (2004). *Applied
Linear Statistical Models* (5th ed.). McGraw-Hill/Irwin.

Welch, B. L. (1947). The generalization of “Student’s” problem when
several different population variances are involved. *Biometrika*,
34(1-2), 28-35.

Satterthwaite, F. E. (1946). An approximate distribution of estimates of
variance components. *Biometrics Bulletin*, 2(6), 110-114.
