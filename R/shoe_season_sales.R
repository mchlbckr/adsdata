#' Sell-through of shoe models by season
#'
#' Commercial outcomes for the shoe models in [shoe_lab_tests], observed over
#' six selling seasons. The data set is the teaching example for supervised
#' methods and carries **two targets on the same row**, so regression and
#' classification become comparable on one case.
#'
#' @format A tibble with 839 rows and 29 variables:
#' \describe{
#'   \item{modell_id}{chr model identifier, joins to [shoe_lab_tests]}
#'   \item{saison}{fct selling season, FS2024 to HW2026 (FS = spring/summer, HW = autumn/winter)}
#'   \item{linie}{fct product line: Running, Basketball, Outdoor, Lifestyle}
#'   \item{preisklasse}{fct price tier: Einstieg, Mittel, Premium}
#'   \item{uvp}{dbl recommended retail price, in euro}
#'   \item{marketing_teur}{dbl marketing budget for the model and season, in thousand euro}
#'   \item{farbvarianten}{dbl number of colourways offered}
#'   \item{haendlerbreite}{dbl number of retailers supplied}
#'   \item{rabatt_pct}{dbl average trade discount granted, in percent}
#'   \item{vorgaenger_abv}{dbl sell-through of the predecessor model, in percent}
#'   \item{daempfung_mm, energieruckgabe_pct, rueckprall_pct, sohlendichte_gcm3,
#'         zehenbox_ml, abrieb_mg, zugfestigkeit_n, nahtfestigkeit_n,
#'         sohlenhaerte_shore, gewicht_g, torsionssteif_nm, biegesteif_nm,
#'         fersenkappe_n, schafthoehe_mm, atmungsaktiv_cfm, feuchtetransport,
#'         wasseraufnahme_pct}{dbl the seventeen laboratory measurements, see [shoe_lab_tests]}
#'   \item{abverkauf_pct}{dbl sell-through rate, in percent — the regression target}
#'   \item{nachbestellt}{fct did the trade reorder, `nein`/`ja` — the classification target}
#' }
#'
#' @details
#' **The two targets are not independent, and that matters for every model.**
#' `nachbestellt` is a noised threshold on `abverkauf_pct`: the trade reorders
#' when sell-through plus noise exceeds 58 percent. That is how the trade
#' behaves, but it means **the other target must be excluded** from any model.
#' On its own, `abverkauf_pct` reaches an AUC of 0.953 for `nachbestellt`. A
#' model fitted as `nachbestellt ~ .` therefore looks excellent and has learnt
#' nothing — which makes this data set a good place to meet that mistake under
#' supervision rather than in a thesis.
#'
#' **A row is a model in a season, not an independent case.** Each model
#' appears in two to five seasons. A grouped split by `modell_id` is therefore
#' more defensible than a split by row, and the difference is worth discussing
#' rather than hiding.
#'
#' The data are simulated. Six drivers are built in, deliberately differing in
#' shape, with their share of the variance of the systematic part:
#'
#' \tabular{lll}{
#'   **Driver** \tab **Shape** \tab **Share** \cr
#'   marketing budget \tab logarithmic, saturating \tab 25 percent \cr
#'   seasonal fit by product line \tab **interaction** \tab 24 percent \cr
#'   price-quality mismatch \tab **U-shaped** \tab 20 percent \cr
#'   cushioning, in Running only \tab **interaction** \tab 12 percent \cr
#'   predecessor's success \tab linear \tab 9 percent \cr
#'   discount and colourways \tab linear and logarithmic \tab 7 percent
#' }
#'
#' Residual noise has a standard deviation of 5 percentage points, which puts
#' the **theoretical ceiling at R-squared 0.801**.
#'
#' What a correct analysis finds, for reference. Feature work pays in steps,
#' each one defensible on its own: master data alone give 0.371, adding the 17
#' raw measurements make it **worse** at 0.333 — seventeen parameters for
#' signal that sits in four factors — a quality index recovers 0.379, the
#' *absolute value* of the price-quality mismatch lifts it to 0.451 because the
#' effect points downwards at both ends, logarithms give 0.514, the
#' cushioning-by-line interaction 0.526, and the season-by-line interaction
#' 0.716. Naively carrying the predecessor's rate forward
#' is worse than the mean, at −1.062.
#'
#' How the quality index is built decides the outcome: summing the four varimax
#' factor scores reaches r = 0.845 with the true construct, the first principal
#' component only r = 0.444, because PC1 is the trade-off axis rather than
#' overall quality. For the classification target, AUC runs 0.774 on master
#' data, 0.761 with raw measurements and 0.828 with constructed features.
#'
#' Note what permutation importance does **not** show: `saison` scores −0.006
#' in a main-effects model and is nonetheless the second strongest driver.
#' Outdoor sells 66.4 percent in autumn against 52.3 in spring, Running the
#' other way round. The season has no main effect, only interactions, and they
#' cancel on average.
#'
#' The price-quality mismatch, the latent quality and the systematic part are
#' **not** part of the package. Constructing them is the exercise.
#'
#' @source Simulated. The generating scripts are
#'   `data-raw/shoe_season_sales_load.R` and `data-raw/labor_erzeugen.R`.
#' @seealso [shoe_lab_tests] for the laboratory measurements of the same models.
"shoe_season_sales"
