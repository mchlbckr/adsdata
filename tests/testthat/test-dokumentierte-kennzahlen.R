# Jede Zahl, die in den Hilfeseiten unter @details behauptet wird, wird hier
# festgenagelt. Eine falsche Zahl in Lehrmaterial ist schlimmer als keine, und
# die Hilfeseiten nennen viele.
skip_if_not_installed("psych")
skip_if_not_installed("pROC")

test_that("shoe_lab_tests: PCA-Kennzahlen wie dokumentiert", {
  M <- as.matrix(shoe_lab_tests[, 4:20])
  p <- summary(prcomp(M, scale. = TRUE))$importance
  expect_equal(unname(p[2, 1]), 0.583, tolerance = 0.002)        # PC1
  expect_equal(sum(p[2, 1:4]), 0.832, tolerance = 0.002)         # kumuliert
  expect_equal(sum(eigen(cor(M))$values > 1), 3L)                # Kaiser
})

test_that("shoe_lab_tests: Einzelrestvarianz liegt bei 22 Prozent, nicht 45", {
  # 0,45 im Generator ist die STANDARDABWEICHUNG des Rauschens, nicht sein
  # Varianzanteil. Die Hilfeseite behauptete zunaechst 45 Prozent.
  u <- factanal(as.matrix(shoe_lab_tests[, 4:20]), factors = 4)$uniquenesses
  expect_equal(mean(u), 0.221, tolerance = 0.01)
  expect_lt(mean(u), 0.30)
})

test_that("shoe_lab_tests: Produktlinien unterscheiden sich auch im NIVEAU", {
  # Die Hilfeseite behauptete "in profile, not in level". Falsch: die Linie
  # erklaert 58 Prozent der Varianz der eingebauten Qualitaet.
  M <- as.matrix(shoe_lab_tests[, 4:20])
  pc1 <- prcomp(M, scale. = TRUE)$x[, 1]
  expect_gt(summary(lm(pc1 ~ shoe_lab_tests$linie))$r.squared, 0.25)
})

test_that("shoe_lab_tests: Clusterguete wie dokumentiert", {
  M <- scale(as.matrix(shoe_lab_tests[, 4:20]))
  set.seed(5); km <- kmeans(M, 4, nstart = 50)
  tb <- table(km$cluster, shoe_lab_tests$linie); best <- apply(tb, 2, which.max)
  expect_equal(sum(sapply(seq_along(best), function(j) tb[best[j], j])) / sum(tb),
               0.831, tolerance = 0.01)
  expect_equal(mean(cluster::silhouette(km$cluster, dist(M))[, 3]),
               0.175, tolerance = 0.01)
})

test_that("shoe_season_sales: abverkauf_pct VERRAET nachbestellt", {
  # Die binaere Zielgroesse ist eine verrauschte Schwelle auf der stetigen.
  # Wer beide ins Modell nimmt, erreicht AUC 0,95 und hat nichts gelernt.
  # Die Hilfeseite muss davor warnen - dieser Test haelt den Grund fest.
  y <- as.integer(shoe_season_sales$nachbestellt == "ja")
  a <- as.numeric(pROC::auc(pROC::roc(y, shoe_season_sales$abverkauf_pct, quiet = TRUE)))
  expect_gt(a, 0.94)
  expect_equal(a, 0.953, tolerance = 0.01)
})

test_that("shoe_season_sales: Aufbau und Basisrate wie dokumentiert", {
  expect_equal(nrow(shoe_season_sales), 839L)
  expect_equal(dplyr::n_distinct(shoe_season_sales$modell_id), 260L)
  expect_equal(mean(shoe_season_sales$nachbestellt == "ja"), 0.579, tolerance = 0.002)
  expect_false(any(c("preis_leistung", "qualitaet", "mu") %in% names(shoe_season_sales)))
})

test_that("shoe_season_sales: die Messgroessen sind je Modell konstant", {
  # Beide Datensaetze beschreiben dieselben Modelle; weichen sie ab, rechnen
  # Vorlesung und Uebung in verschiedenen Welten.
  m <- names(shoe_lab_tests)[4:20]
  z <- merge(shoe_lab_tests[, c("modell_id", m)],
             unique(shoe_season_sales[, c("modell_id", m)]), by = "modell_id")
  for (v in m) expect_equal(z[[paste0(v, ".x")]], z[[paste0(v, ".y")]], info = v)
})
