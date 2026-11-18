## Erzeugt `shoe_lab_tests`: Labormessungen an Schuhmodellen.
## Der Generator steht in data-raw/labor_erzeugen.R, weil
## shoe_season_sales_load.R ihn ebenfalls braucht.
source(file.path("data-raw", "labor_erzeugen.R"))
lab <- erzeuge_labor()
shoe_lab_tests <- lab$modelle

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
