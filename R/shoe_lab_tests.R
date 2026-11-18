#' Laboratory measurements of running shoe models
#'
#' Seventeen laboratory measurements taken on 260 shoe models of a fictitious
#' manufacturer, Fhoenix Footwear. The data set is the teaching example for
#' unsupervised methods: principal component analysis, factor analysis,
#' multidimensional scaling and cluster analysis.
#'
#' @format A tibble with 260 rows and 20 variables:
#' \describe{
#'   \item{modell_id}{chr model identifier, `M001` to `M260`}
#'   \item{linie}{fct product line: Running, Basketball, Outdoor, Lifestyle}
#'   \item{preisklasse}{fct price tier: Einstieg, Mittel, Premium}
#'   \item{daempfung_mm}{dbl cushioning travel under load, in millimetres}
#'   \item{energieruckgabe_pct}{dbl energy return, in percent}
#'   \item{rueckprall_pct}{dbl rebound resilience, in percent}
#'   \item{sohlendichte_gcm3}{dbl midsole density, in grams per cubic centimetre}
#'   \item{zehenbox_ml}{dbl toe box volume, in millilitres}
#'   \item{abrieb_mg}{dbl outsole abrasion loss, in milligrams}
#'   \item{zugfestigkeit_n}{dbl tensile strength of the upper, in newtons}
#'   \item{nahtfestigkeit_n}{dbl seam strength, in newtons}
#'   \item{sohlenhaerte_shore}{dbl midsole hardness, in Shore A}
#'   \item{gewicht_g}{dbl mass of one shoe, in grams}
#'   \item{torsionssteif_nm}{dbl torsional stiffness, in newton metres}
#'   \item{biegesteif_nm}{dbl forefoot bending stiffness, in newton metres}
#'   \item{fersenkappe_n}{dbl heel counter rigidity, in newtons}
#'   \item{schafthoehe_mm}{dbl collar height above the footbed, in millimetres}
#'   \item{atmungsaktiv_cfm}{dbl air permeability, in cubic feet per minute}
#'   \item{feuchtetransport}{dbl moisture transport index, higher is faster}
#'   \item{wasseraufnahme_pct}{dbl water uptake after immersion, in percent}
#' }
#'
#' @details
#' The data are simulated, and the generating process is documented so that an
#' analysis can be checked against a known truth rather than merely believed.
#'
#' **Four latent factors** produce the seventeen measurements: cushioning
#' (*Daempfung*), durability (*Haltbarkeit*), stability (*Stabilitaet*) and
#' climate (*Klima*). Factor scores differ by product line both in profile and
#' in level: the line explains 58 percent of the variance of the quality
#' composite, which is why `linie` carries real predictive weight in
#' [shoe_season_sales] and why the clusters recover the lines at all.
#'
#' Each measurement carries a residual term with standard deviation 0.45 on the
#' factor scale, which works out to a **mean uniqueness of 0.22** — about 22
#' percent unique variance per measurement, not 45. The factors are therefore
#' recoverable, but not trivially so.
#'
#' **Two cross-loadings are deliberate:** `sohlenhaerte_shore` and `gewicht_g`
#' load on durability *and* stability. Without them the factor solution would
#' be artificially clean and there would be nothing to interpret.
#'
#' What a correct analysis finds, for reference: the first principal component
#' explains 58.3 percent of the variance and contrasts *robust, stiff, heavy*
#' against *cushioned, breathable, light*; four components explain 83.2
#' percent, while Kaiser's criterion retains three. A varimax factor solution
#' with four factors reaches Tucker congruences of 0.95, 0.94, 0.93 and 0.88
#' with the loading matrix that built the data, and `factanal()` and
#' `psych::fa()` agree to a congruence of 1.000. k-means with k = 4 assigns
#' 83.1 percent of models to their own product line without ever seeing it —
#' at a mean silhouette width of only 0.175, because the lines overlap
#' geometrically even where they are substantively distinct.
#'
#' The factor scores and the loading matrix are **not** part of the package.
#' Recovering them is the exercise.
#'
#' @source Simulated. The generating scripts are `data-raw/shoe_lab_tests_load.R`
#'   and `data-raw/labor_erzeugen.R`, which holds the loading matrix.
"shoe_lab_tests"
