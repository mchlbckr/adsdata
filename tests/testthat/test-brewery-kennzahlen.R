# Die Hilfeseite zu brewery_demand nennt sieben Zahlen. Jede steht hier.
# Sie stammen aus ana2_brauerei.R im Curriculum und waren der Grund, die
# Brauerei ueberhaupt in die Vorlesung zu holen - wenn eine davon wandert,
# stimmt der Foliensatz nicht mehr.
skip_if_not_installed("rpart")

r2 <- function(y, p) 1 - sum((y - p)^2) / sum((y - mean(y))^2)

MERKMALE <- c("hl_monat", "sorten", "craft_einh", "fass_ant", "alkfrei_ant",
              "rabatt_ant", "bestelltage", "bestellfrequenz", "liter_bestellung",
              "letzter_abstand", "sais_amp", "trend", "betriebsart", "region",
              "plaetze", "eroeffnet")
FORMEL <- stats::as.formula(paste("hl_ziel ~", paste(MERKMALE, collapse = " + ")))

kreuz <- function(fit) {
  X <- brewery_demand
  set.seed(7); fo <- sample(rep(1:10, length.out = nrow(X)))
  p <- numeric(nrow(X))
  for (k in 1:10) p[fo == k] <- fit(X[fo != k, ], X[fo == k, ])
  r2(X$hl_ziel, p)
}

test_that("brewery_demand: Umfang und was nicht ausgeliefert wird", {
  expect_equal(nrow(brewery_demand), 900L)
  expect_equal(nrow(brewery_orders), 48259L)
  expect_false("segment_wahr" %in% names(brewery_demand))
  expect_false(any(is.na(brewery_demand)))
  expect_setequal(unique(brewery_orders$kunde_id), brewery_demand$kunde_id)
})

test_that("brewery_demand: lineares Modell und Baum wie dokumentiert", {
  expect_equal(kreuz(function(a, e) predict(lm(FORMEL, a), e)), 0.597, tolerance = 0.005)
  expect_equal(kreuz(function(a, e) predict(
    rpart::rpart(FORMEL, a, control = rpart::rpart.control(cp = .01, minsplit = 20)), e)),
    0.535, tolerance = 0.005)
})

test_that("brewery_demand: die naiven Fortschreibungen scheitern", {
  # Der didaktische Kern. Ohne diese beiden Zahlen ist der Modellvergleich
  # eine Behauptung.
  expect_equal(r2(brewery_demand$hl_ziel, brewery_demand$hl_monat * 3),
               -2.306, tolerance = 0.01)
  expect_equal(r2(brewery_demand$hl_ziel, brewery_demand$letzte3 * 3),
               -16.799, tolerance = 0.05)
})

test_that("brewery_demand: letzter_abstand traegt allein fast nichts", {
  # Leckagekandidat: schwach für sich, sichtbar in der Wichtigkeit.
  expect_equal(kreuz(function(a, e) predict(lm(hl_ziel ~ letzter_abstand, a), e)),
               0.028, tolerance = 0.01)
})

test_that("brewery_demand: die Skalierung um 1,3 senkt die Kosten um 22 Prozent", {
  X <- brewery_demand
  set.seed(7); fo <- sample(rep(1:10, length.out = nrow(X)))
  p <- numeric(nrow(X))
  for (k in 1:10) p[fo == k] <- predict(lm(FORMEL, X[fo != k, ]), X[fo == k, ])
  kosten <- function(s) {
    d <- p * s - X$hl_ziel
    sum(ifelse(d > 0, d * 12, -d * 45))
  }
  expect_equal(kosten(1.0), 16286, tolerance = 0.01)
  expect_equal(kosten(1.3), 12780, tolerance = 0.01)
  expect_lt(kosten(1.3) / kosten(1.0), 0.80)
})
