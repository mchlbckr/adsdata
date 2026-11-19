#' Order lines of the brewery
#'
#' Every order line of the fictional brewery *Fhoenix Braeu* over 24 months:
#' 900 hospitality customers, eight beers, 48,259 lines. The data set exists so
#' the lecture can show the step that a ready-made analysis table hides —
#' turning movement data into one row per case.
#'
#' @format A tibble with 48,259 rows and 8 variables:
#' \describe{
#'   \item{kunde_id}{chr customer identifier, joins to [brewery_demand]}
#'   \item{datum}{Date date of the order}
#'   \item{sorte}{fct beer: Pils, Weizen, Hell, Craft IPA, Craft Stout, Alkoholfrei, Radler}
#'   \item{gebinde}{fct container: keg (30 l) or crate (20 x 0.5 l, 20 x 0.33 l)}
#'   \item{menge}{int units ordered}
#'   \item{liter}{dbl litres ordered, `menge` times the container size}
#'   \item{rabatt}{dbl discount granted on the line, as a share}
#'   \item{umsatz}{dbl net revenue of the line, in euro}
#' }
#'
#' @details
#' The first 21 months are the history from which [brewery_demand] is
#' aggregated; the last three are its target quarter. Rebuilding that table
#' from this one is the intended exercise, and the result can be compared
#' against the delivered version row by row.
#'
#' Note the unit trap: craft beer comes in 6.6-litre crates and the others in
#' 10- and 30-litre containers, so a craft share measured in litres
#' systematically understates a craft-focused customer. Measured in units it
#' does not. Both variants are in [brewery_demand] as `craft_ant` and
#' `craft_einh`.
#'
#' @source Simulated. See `data-raw/brewery_load.R`.
#' @seealso [brewery_demand]
"brewery_orders"
