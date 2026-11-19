## Erzeugt die Brauerei-Welt "Fhoenix Braeu". Uebernommen aus
## Curriculum/konzept/entwuerfe/fallstudie/A_brauerei/gen2_brauerei.R
## (Fassung 2, 18.11.2026), unveraendert bis auf die Verpackung in eine
## Funktion: kein saveRDS, keine Meldungen, Rueckgabe als Liste.
##
## Die Welt ist dort vollstaendig geprueft - Segmentierung 85,3 %, Regression
## R2 0,597, Leckagetest bestanden. Seit dem 19.11.2026 traegt sie den
## REGRESSIONSTEIL der Vorlesung, waehrend die Schuhe die Klassifikation
## tragen. Die Spalte `segment_wahr` bleibt dem Generator vorbehalten und
## erreicht die ausgelieferten Datensaetze nicht.
erzeuge_brauerei <- function(RHY_STARK = FALSE) {
  suppressPackageStartupMessages(library(dplyr))
  set.seed(2027)
  nk <- 900
  # RHY_STARK = TRUE erzeugt die verworfene Variante mit stark kontrastiertem
  # Bestellrhythmus (siehe ana_varianten.R im Curriculum).

  seg  <- sample(c("Eckkneipe","Szenelokal","Hotel/Restaurant","Biergarten"),
                 nk, TRUE, c(.34,.22,.30,.14))
  kunden <- data.frame(
    kunde_id   = sprintf("K%04d", 1:nk),
    segment_wahr = seg,
    betriebsart = sapply(seg, function(s) switch(s,
        "Eckkneipe"="Kneipe","Szenelokal"="Bar",
        "Hotel/Restaurant"=sample(c("Hotel","Restaurant"),1), "Biergarten")),
    plaetze = round(case_when(seg=="Eckkneipe"~rnorm(nk,45,15), seg=="Szenelokal"~rnorm(nk,80,25),
                              seg=="Hotel/Restaurant"~rnorm(nk,120,40), TRUE~rnorm(nk,350,120))),
    region  = sample(c("Muensterland","Ruhrgebiet","Ostwestfalen"), nk, TRUE),
    eroeffnet = sample(1960:2024, nk, TRUE))
  kunden$plaetze <- pmax(20, kunden$plaetze)

  produkte <- data.frame(
    produkt_id = sprintf("P%02d", 1:8),
    sorte   = c("Pils","Pils","Weizen","Hell","Craft IPA","Craft Stout","Alkoholfrei","Radler"),
    gebinde = c("Fass 30l","Kasten 20x0,5","Kasten 20x0,5","Fass 30l","Kasten 20x0,33",
                "Kasten 20x0,33","Kasten 20x0,5","Kasten 20x0,5"),
    liter_einheit = c(30, 10, 10, 30, 6.6, 6.6, 10, 10),
    preis_einheit = c(62, 16.5, 18.2, 58, 29.9, 31.5, 17.8, 16.9))

  # (1) Sortimentsneigung - Szenelokal craftlastig UND ohne 30-l-Pilsfass,
  #     Hotel/Restaurant craftarm. Damit trennen mehrere Sorten die beiden.
  neig <- list(
    "Eckkneipe"        = c(.95,.55,.35,.30,.05,.03,.35,.20),
    "Szenelokal"       = c(.15,.60,.45,.08,.95,.90,.35,.25),
    "Hotel/Restaurant" = c(.70,.80,.75,.35,.12,.06,.80,.55),
    "Biergarten"       = c(.90,.75,.85,.65,.20,.10,.70,.80))
  # (2) Saisonfigur je Segment ueber 12 Monate (1 = Jahresmittel)
  saison <- list(
    "Eckkneipe"        = c(.95,.92,.98,1.0,1.05,1.08,1.05,1.05,1.02,1.0,.98,.92),
    "Szenelokal"       = c(.85,.85,.95,1.0,1.1,1.2,1.15,1.1,1.05,1.0,.95,.80),
    "Hotel/Restaurant" = c(.80,.82,.95,1.05,1.15,1.2,1.25,1.25,1.1,.95,.85,.63),
    "Biergarten"       = c(.25,.25,.55,1.0,1.6,2.1,2.2,2.0,1.3,.70,.30,.20))
  # (3) Bestellrhythmus: Bars ordern oft und klein (wenig Lager), Biergaerten
  #     selten und in grossen Mengen. Die Monatsmenge bleibt davon unberuehrt.
  #     Bewusst MASSVOLL gewaehlt: ein starker Kontrast (freq .68 bis .97,
  #     Losgroesse 0,55 bis 1,75) hebt die Segmentierung nur um 0,5 Punkte,
  #     kostet aber 16 Punkte R2 in der Regression, weil wenige grosse
  #     Bestellungen die Quartalssumme verrauschen.
  rhythmus <- if (RHY_STARK) list(
    "Eckkneipe"        = list(freq=.80, los=1.30),
    "Szenelokal"       = list(freq=.97, los=0.55),
    "Hotel/Restaurant" = list(freq=.86, los=1.00),
    "Biergarten"       = list(freq=.68, los=1.75)) else list(
    "Eckkneipe"        = list(freq=.94, los=1.00),
    "Szenelokal"       = list(freq=.97, los=0.80),
    "Hotel/Restaurant" = list(freq=.92, los=1.00),
    "Biergarten"       = list(freq=.88, los=1.25))

  monate <- seq(as.Date("2025-01-01"), as.Date("2026-12-01"), by = "month")
  rows <- vector("list", 0)
  for (i in seq_len(nk)) {
    s <- kunden$segment_wahr[i]; rh <- rhythmus[[s]]
    basis <- kunden$plaetze[i] * runif(1, .09, .16)      # Einheiten je Monat
    skal  <- 0.94/(rh$freq * rh$los)                     # haelt die Monatsmenge konstant
    trend <- switch(s, "Szenelokal" = runif(1, .010, .022),
                       "Eckkneipe"  = runif(1, -.012, .002), runif(1, -.004, .008))
    fuehrt <- which(runif(8) < neig[[s]]); if (!length(fuehrt)) fuehrt <- 1
    for (m in seq_along(monate)) {
      mon <- as.integer(format(monate[m], "%m"))
      lam <- basis * skal * saison[[s]][mon] * (1 + trend)^m
      if (runif(1) > rh$freq) next                       # Monat ohne Bestellung
      for (p in fuehrt) {
        q <- rpois(1, lam * rh$los * runif(1, .2, .6) / length(fuehrt))
        if (q > 0) rows[[length(rows)+1]] <- data.frame(
          kunde_id = kunden$kunde_id[i], datum = monate[m] + sample(0:27, 1),
          produkt_id = produkte$produkt_id[p], menge = q,
          rabatt = round(ifelse(runif(1) < .25, runif(1, .03, .15), 0), 3))
      }
    }
  }
  bestellungen <- bind_rows(rows)

  list(kunden = kunden, produkte = produkte, bestellungen = bestellungen)
}
