## Erzeugt `brewery_orders` und `brewery_demand`: die Brauerei-Welt
## "Fhoenix Braeu" als VORLESUNGSBEISPIEL für die Regression.
##
##   brewery_orders  48.259 Bestellzeilen über 24 Monate
##   brewery_demand     900 Kunden, ein Fall je Betrieb -> Regression
##
## Arbeitsteilung seit dem 19.11.2026: Die Schuhe tragen die Klassifikation
## (`shoe_season_sales$nachbestellt`), die Brauerei die Regression. Vorher lagen
## beide Zielgrößen auf derselben Schuhzeile; die Vorlesung zeigte damit elf
## Kapitel lang eine einzige Welt und nie, wie aus Bewegungsdaten ueberhaupt
## eine Analysetabelle entsteht.
##
## Die Aggregation ist Zeile für Zeile aus `ana2_brauerei.R` uebernommen, damit
## die dort geprueften Kennzahlen gelten: R2 0,597 (lineares Modell) gegen
## -2,306 der naiven Fortschreibung, Leckagekandidat `letzter_abstand`.
##
## `segment_wahr` wird NICHT ausgeliefert. Die Spalte ist die eingebaute
## Wahrheit der Segmentierung; sie gehört dem Generator, nicht den Studierenden.
suppressPackageStartupMessages(library(dplyr))
source(file.path("data-raw", "brauerei_erzeugen.R"))
d <- erzeuge_brauerei()

b <- d$bestellungen %>%
  left_join(d$produkte, by = "produkt_id") %>%
  mutate(liter  = menge * liter_einheit,
         umsatz = menge * preis_einheit * (1 - rabatt),
         monat  = as.integer(format(datum, "%Y%m")))

## Die ersten 21 Monate sind Historie, die letzten drei das Zielquartal.
mon    <- sort(unique(b$monat))
hist_m <- mon[1:21]
ziel_m <- mon[22:24]
ende_h <- max(b$datum[b$monat %in% hist_m])
H      <- b %>% filter(monat %in% hist_m)

agg <- H %>% group_by(kunde_id) %>% summarise(
  hl_monat         = sum(liter) / 100 / 21,
  sorten           = n_distinct(sorte),
  craft_ant        = sum(liter[grepl("Craft", sorte)]) / sum(liter),
  craft_einh       = sum(menge[grepl("Craft", sorte)]) / sum(menge),
  fass_ant         = sum(liter[grepl("Fass", gebinde)]) / sum(liter),
  alkfrei_ant      = sum(liter[sorte == "Alkoholfrei"]) / sum(liter),
  rabatt_ant       = weighted.mean(rabatt, liter),
  bestelltage      = n_distinct(datum),
  bestellmonate    = n_distinct(monat),
  liter_bestellung = sum(liter) / n_distinct(datum),
  letzter_abstand  = as.integer(ende_h - max(datum)),
  .groups = "drop") %>%
  mutate(bestellfrequenz = bestellmonate / 21)

sais <- H %>%
  mutate(m = as.integer(substr(monat, 5, 6)), so = m %in% 5:8, wi = m %in% c(11, 12, 1, 2)) %>%
  group_by(kunde_id) %>% summarise(
    sais_amp = (sum(liter[so]) / max(sum(so), 1)) / pmax(sum(liter[wi]) / max(sum(wi), 1), 1),
    .groups = "drop")

tr <- H %>% group_by(kunde_id, monat) %>% summarise(l = sum(liter), .groups = "drop") %>%
  group_by(kunde_id) %>% summarise(
    trend   = ifelse(n() > 3, coef(lm(l ~ seq_along(l)))[2], 0),
    letzte3 = mean(tail(l, 3)) / 100,
    .groups = "drop")

ziel <- b %>% filter(monat %in% ziel_m) %>% group_by(kunde_id) %>%
  summarise(hl_ziel = sum(liter) / 100, .groups = "drop")

brewery_demand <- d$kunden %>%
  select(-segment_wahr) %>%
  left_join(agg, by = "kunde_id") %>%
  left_join(sais, by = "kunde_id") %>%
  left_join(tr, by = "kunde_id") %>%
  left_join(ziel, by = "kunde_id") %>%
  mutate(hl_ziel = coalesce(hl_ziel, 0)) %>%
  ## `bestellmonate` fällt raus: `bestellfrequenz` ist exakt bestellmonate/21.
  ## In `lm(hl_ziel ~ .)` bekommt dann eine der beiden einen stummen
  ## NA-Koeffizienten - ein Rätsel, das nichts lehrt, was die fehlende
  ## Referenzkategorie der Dummys nicht besser lehrt.
  select(-bestellmonate) %>%
  filter(!is.na(hl_monat)) %>%
  mutate(betriebsart = factor(betriebsart), region = factor(region)) %>%
  tibble::as_tibble()

brewery_orders <- b %>%
  transmute(kunde_id, datum, sorte = factor(sorte), gebinde = factor(gebinde),
            menge, liter, rabatt, umsatz) %>%
  arrange(kunde_id, datum) %>%
  tibble::as_tibble()

stopifnot(
  nrow(brewery_demand) == 900,
  nrow(brewery_orders) == 48259,
  !("segment_wahr" %in% names(brewery_demand)),
  !any(is.na(brewery_demand)),
  !any(is.na(brewery_orders))
)

## `usethis` ist nicht ueberall installiert; die Wirkung von use_data() ist
## genau dieses save(). Ohne den Zweig bricht ein Neuaufbau auf einem Rechner
## ohne usethis ab, und das fällt erst auf, wenn man die Daten braucht.
ablegen <- function(name) {
  if (requireNamespace("usethis", quietly = TRUE)) {
    do.call(usethis::use_data, list(as.name(name), overwrite = TRUE))
  } else {
    save(list = name, file = file.path("data", paste0(name, ".rda")),
         compress = "bzip2", version = 2, envir = environment())
  }
}
ablegen("brewery_orders")
ablegen("brewery_demand")
