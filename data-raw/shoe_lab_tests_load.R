## Erzeugt `shoe_lab_tests`: Labormessungen an Schuhmodellen.
##
## Der datenerzeugende Prozess ist geschrieben, nicht gefunden: VIER latente
## Faktoren (Daempfung, Haltbarkeit, Stabilitaet, Klima) erzeugen 17
## Messgroessen mit 45 % Einzelrestvarianz. Die Ladungsmatrix unten ist die
## Wahrheit, gegen die sich pruefen laesst, ob PCA und Faktoranalyse sie
## zurueckgeben. Faktorwerte und Ladungsmatrix gehen NICHT in das Paket -
## sonst waere die Uebung geloest, bevor sie beginnt.
suppressPackageStartupMessages(library(dplyr))
set.seed(2027)
n      <- 260
linien <- c("Running", "Basketball", "Outdoor", "Lifestyle")
linie  <- sample(linien, n, TRUE, c(.30, .22, .24, .24))

# Faktorwerte je Produktlinie: F1 Daempfung, F2 Haltbarkeit, F3 Stabilitaet,
# F4 Klima. Die Linien unterscheiden sich im Profil, nicht im Niveau.
mu <- list(Running    = c( 1.1, -0.2, -0.6,  0.9),
           Basketball = c( 0.2,  0.7,  1.2, -0.3),
           Outdoor    = c(-0.7,  1.2,  0.8, -1.0),
           Lifestyle  = c( 0.1, -0.8, -0.7,  0.4))
F <- t(sapply(linie, function(l) rnorm(4, mu[[l]], 0.55)))
colnames(F) <- c("Daempfung", "Haltbarkeit", "Stabilitaet", "Klima")

# Ladungsmatrix, 17 Messgroessen x 4 Faktoren. Zwei NEBENLADUNGEN sind
# Absicht: sohlenhaerte_shore und gewicht_g laden auf Haltbarkeit *und*
# Stabilitaet. Ohne sie waere die Faktorloesung kuenstlich sauber und es
# gaebe nichts zu interpretieren.
L <- rbind(
  daempfung_mm        = c( .88,  .00, -.10,  .05),
  energieruckgabe_pct = c( .84,  .10, -.05,  .00),
  rueckprall_pct      = c( .79,  .05,  .00,  .05),
  sohlendichte_gcm3   = c(-.76,  .22,  .18,  .00),
  zehenbox_ml         = c( .55,  .00, -.25,  .20),
  abrieb_mg           = c( .05, -.85,  .00,  .10),
  zugfestigkeit_n     = c(-.05,  .83,  .12,  .00),
  nahtfestigkeit_n    = c( .00,  .80,  .08,  .00),
  sohlenhaerte_shore  = c(-.30,  .62,  .42,  .00),   # Nebenladung
  gewicht_g           = c( .10,  .58,  .45, -.15),   # Nebenladung
  torsionssteif_nm    = c(-.08,  .10,  .87,  .00),
  biegesteif_nm       = c(-.15,  .05,  .84,  .00),
  fersenkappe_n       = c( .00,  .18,  .79,  .00),
  schafthoehe_mm      = c( .00,  .12,  .58, -.20),
  atmungsaktiv_cfm    = c( .05,  .00, -.10,  .89),
  feuchtetransport    = c( .00, -.08,  .00,  .85),
  wasseraufnahme_pct  = c( .00, -.20, -.05,  .71))
X <- F %*% t(L) + matrix(rnorm(n * nrow(L), 0, 0.45), n)   # 45 % Restvarianz

# In realistische Einheiten bringen: Mittelwert und Streuung je Messgroesse
skala <- data.frame(
  v = rownames(L),
  m = c(26, 62, 58, 0.32, 92, 118, 210, 165, 58, 310, 4.2, 3.1, 140, 95, 32, 55, 14),
  s = c( 5,  9, 10, 0.05, 14,  28,  34,  26,  7,  52, 1.1, 0.9,  26, 22,  8, 12,  5))
M <- sapply(seq_len(ncol(X)), function(j) round(skala$m[j] + skala$s[j] * X[, j], 2))
colnames(M) <- rownames(L)

shoe_lab_tests <- tibble::tibble(
  modell_id   = sprintf("M%03d", seq_len(n)),
  linie       = factor(linie, levels = linien),
  preisklasse = cut(rowSums(F[, 2:3]) + rnorm(n, 0, .8), 3,
                    labels = c("Einstieg", "Mittel", "Premium")),
  tibble::as_tibble(M))

# --- Zusicherungen --------------------------------------------------------
stopifnot(
  nrow(shoe_lab_tests) == 260,
  ncol(shoe_lab_tests) == 20,
  !any(c("F", "L", "wahrheit") %in% names(shoe_lab_tests)),
  nlevels(shoe_lab_tests$linie) == 4,
  sum(sapply(shoe_lab_tests, is.numeric)) == 17,
  !any(is.na(shoe_lab_tests))
)
usethis::use_data(shoe_lab_tests, overwrite = TRUE)
