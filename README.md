# adsdata

Data sets for the **Advanced Data Science** module at the Münster School of
Business (FH Münster).

The module teaches unsupervised and supervised methods on one world: a
fictitious running-shoe manufacturer, *Fhoenix Footwear*. Both data sets
describe the same 260 shoe models — first as laboratory measurements, then as
commercial outcomes over six selling seasons. A method shown on one is
practised on the other, and the join between them is part of the lesson.

## Installation

```r
# install.packages("remotes")
remotes::install_github("mchlbckr/adsdata")
```

## The two data sets

| | rows | columns | target | used for |
|---|---|---|---|---|
| `shoe_lab_tests` | 260 | 20 | none | PCA, factor analysis, MDS, clustering |
| `shoe_season_sales` | 839 | 29 | `abverkauf_pct`, `nachbestellt` | regression and classification |

```r
library(adsdata)
?shoe_lab_tests
?shoe_season_sales
```

`shoe_season_sales` carries **two targets on the same row** — a sell-through
rate and a reorder decision — so regression and classification can be compared
on one case instead of two unrelated examples.

## Why simulated data

Both data sets are simulated from a written generating process. That is the
point: an analysis can be **checked against a known truth** rather than merely
believed. Each help page states what a correct analysis finds, so a result can
be compared against it.

What is built into `shoe_lab_tests`: four latent factors (cushioning,
durability, stability, climate), two deliberate cross-loadings, and factor
scores that differ by product line. A varimax solution with four factors
recovers the built-in loading matrix at Tucker congruences of 0.95, 0.94, 0.93
and 0.88; k-means with k = 4 assigns 83.1 % of models to their own product line
without ever seeing it.

What is built into `shoe_season_sales`: six drivers of deliberately different
shape — a saturating marketing effect, a **U-shaped** price-quality mismatch,
two **interactions** (season by line, cushioning within Running), and two
linear terms. Residual noise puts the theoretical ceiling at R² = 0.801.

The factor scores, the loading matrix, the latent quality and the systematic
part are **not** part of the package. Recovering them is the exercise.

## Two traps, on purpose

**Target leakage.** `nachbestellt` is a noised threshold on `abverkauf_pct`.
Fitting `nachbestellt ~ .` reaches an AUC of 0.953 and has learnt nothing. The
other target must be excluded.

**A row is not a case.** Each model appears in two to five seasons, so rows
within a model are not independent. A split grouped by `modell_id` is more
defensible than a split by row.

Both are easier to meet here, under supervision, than in a thesis.

## Regenerating the data

The scripts in `data-raw/` rebuild both data sets from scratch:
`labor_erzeugen.R` holds the loading matrix shared by both,
`shoe_lab_tests_load.R` and `shoe_season_sales_load.R` write the `.rda` files.
They are seeded, so a rebuild reproduces the shipped data byte for byte.

```r
source("data-raw/shoe_lab_tests_load.R")
source("data-raw/shoe_season_sales_load.R")
```

## Tests

The figures quoted in the help pages are not decoration — they are asserted in
`tests/testthat/`, so a change to the generating process that moves them fails
the test suite rather than quietly invalidating the documentation.

```r
devtools::test()
```

## Licence

GPL (>= 3). The data are fictitious; any resemblance to an actual shoe
manufacturer is unintended.
