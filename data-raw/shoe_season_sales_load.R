## Erzeugt `shoe_season_sales`: Artikel je Saison, mit ZWEI Zielgroessen.
##
##   abverkauf_pct  Abverkaufsquote in Prozent  -> Regression
##   nachbestellt   ordert der Handel nach      -> Klassifikation
##
## Beide auf DERSELBEN Zeile, also am gleichen Fall vergleichbar. Mit zwei
## getrennten Datensaetzen war das nicht moeglich.
##
## Konstruktionsgrundsatz: Der UVP ist eine Positionierungs-ENTSCHEIDUNG, nicht
## die Folge der Qualitaet. Nur dadurch entsteht ein echtes Preis-Leistungs-
## Missverhaeltnis - und nur dadurch tragen die Labormessungen zur Prognose
## bei. Im ersten Entwurf war der Preis fast vollstaendig aus der Qualitaet
## gebaut (r = 0,86); das Missverhaeltnis trug dann 4 % der Varianz und die
## Messgroessen brachten nichts.
suppressPackageStartupMessages(library(dplyr))
source(file.path("data-raw", "labor_erzeugen.R"))
lab <- erzeuge_labor()
set.seed(31)
mod <- lab$modelle
FS  <- as.data.frame(lab$F)

# Sechs Saisons: ein Modell lebt zwei bis fuenf Saisons im Sortiment. Das gibt
# ein echtes Panel - bei nur 447 Zeilen lernte ein Baum nichts (R2 0,007).
saisons <- c("FS2024", "HW2024", "FS2025", "HW2025", "FS2026", "HW2026")
rows <- lapply(seq_len(nrow(mod)), function(i) {
  k     <- sample(2:5, 1, prob = c(.30, .30, .25, .15))
  start <- sample(seq_len(length(saisons) - k + 1), 1)
  data.frame(modell_id = mod$modell_id[i], saison = saisons[start:(start + k - 1)])
})
A <- bind_rows(rows) %>% left_join(mod, by = "modell_id") %>%
  bind_cols(FS[match(.$modell_id, mod$modell_id), ])
n <- nrow(A)

# Qualitaet: das latente Konstrukt, das die 17 Labormessungen messen
qualitaet <- with(A, 0.5 * Haltbarkeit + 0.3 * Stabilitaet + 0.4 * Daempfung + 0.2 * Klima)

A <- A %>% mutate(
  uvp            = round(79 + 10 * qualitaet +
                     ifelse(preisklasse == "Premium", 52,
                            ifelse(preisklasse == "Mittel", 20, 0)) +
                     rnorm(n, 0, 26), 2),
  marketing_teur = round(pmax(2, rlnorm(n, log(28), .7)), 1),
  farbvarianten  = pmin(9, 1 + rpois(n, 2.4)),
  haendlerbreite = round(pmax(30, rnorm(n, 260, 80))),
  rabatt_pct     = round(pmax(0, rnorm(n, 8, 6)), 1),
  vorgaenger_abv = round(pmax(5, pmin(95, rnorm(n, 58, 14))), 1),
  fruehjahr      = grepl("^FS", saison))

# --- Sechs eingebaute Treiber, mit Absicht verschieden geformt ------------
#  (1) Preis-Leistungs-Missverhaeltnis   U-FORM, 20 % der Varianz
#  (2) Marketingbudget                   logarithmisch, 25 %
#  (3) Saisonpassung je Linie            WECHSELWIRKUNG, 24 %
#  (4) Daempfung nur bei Running         WECHSELWIRKUNG, 12 %
#  (5) Vorgaengererfolg                  linear, 9 %
#  (6) Rabatt und Farbvarianten          Beiwerk, 7 %
preis_z  <- as.numeric(scale(A$uvp))
qual_z   <- as.numeric(scale(qualitaet))
missverh <- preis_z - qual_z            # positiv = zu teuer fuer das Gebotene
saison_fit <- with(A, case_when(
  linie == "Outdoor"    & !fruehjahr ~  7, linie == "Outdoor"    &  fruehjahr ~ -7,
  linie == "Running"    &  fruehjahr ~  7, linie == "Running"    & !fruehjahr ~ -5,
  linie == "Basketball" & !fruehjahr ~  3, TRUE ~ 0))
terme <- list(
  missverh_u   = -7.0 * (abs(missverh) - mean(abs(missverh))),
  missverh_lin = -1.0 * missverh,
  marketing    =  7.0 * (log(A$marketing_teur) - log(28)),
  saison       =  saison_fit,
  farben       =  3.4 * (log(A$farbvarianten) - log(3)),
  vorgaenger   =  0.22 * (A$vorgaenger_abv - 58),
  rabatt       = -0.35 * (A$rabatt_pct - 8),
  daempf_run   =  ifelse(A$linie == "Running", 7.0 * (A$Daempfung - mean(A$Daempfung)), 0))
mu <- 58 + Reduce(`+`, terme)
A$abverkauf_pct <- round(pmax(3, pmin(99, mu + rnorm(n, 0, 5))), 1)
A$nachbestellt  <- factor(ifelse(A$abverkauf_pct + rnorm(n, 0, 5) > 58, "ja", "nein"),
                          levels = c("nein", "ja"))

# Studierendensicht: KEINE fertige Preis-Leistungs-Spalte und keine Qualitaet.
# Sie aus dem UVP und den Labormessungen zu konstruieren, ist die Aufgabe -
# und es kommt sehr darauf an, wie: ueber die vier Faktorwerte erreicht der
# Qualitaetsindex r = 0,845 zur Wahrheit, ueber die erste Hauptkomponente nur
# r = 0,484, weil PC1 die Zielkonflikt-Achse ist und keine Gesamtqualitaet.
shoe_season_sales <- A %>%
  select(modell_id, saison, linie, preisklasse, uvp, marketing_teur,
         farbvarianten, haendlerbreite, rabatt_pct, vorgaenger_abv,
         all_of(rownames(lab$L)), abverkauf_pct, nachbestellt) %>%
  mutate(saison = factor(saison, levels = saisons)) %>%
  tibble::as_tibble()

# --- Zusicherungen --------------------------------------------------------
stopifnot(
  nrow(shoe_season_sales) == 839,
  dplyr::n_distinct(shoe_season_sales$modell_id) == 260,
  !any(c("preis_leistung", "qualitaet", "mu") %in% names(shoe_season_sales)),
  all(levels(shoe_season_sales$nachbestellt) == c("nein", "ja")),
  all(rownames(lab$L) %in% names(shoe_season_sales)),
  !any(is.na(shoe_season_sales))
)
usethis::use_data(shoe_season_sales, overwrite = TRUE)
