#' Quarterly beer demand per hospitality customer
#'
#' One row per customer of the fictional brewery *Fhoenix Braeu*, built from
#' the 21 months of order history in [brewery_orders]. The data set is the
#' teaching example for **regression**: the target is the volume the customer
#' will order in the following quarter.
#'
#' @format A tibble with 900 rows and 20 variables:
#' \describe{
#'   \item{kunde_id}{chr customer identifier, joins to [brewery_orders]}
#'   \item{betriebsart}{fct type of business: Kneipe, Restaurant, Bar, Biergarten, Hotel}
#'   \item{plaetze}{dbl number of seats}
#'   \item{region}{fct sales region}
#'   \item{eroeffnet}{int year the business opened}
#'   \item{hl_monat}{dbl hectolitres per month over the history}
#'   \item{sorten}{int number of distinct beers ordered}
#'   \item{craft_ant}{dbl share of craft beer, by volume}
#'   \item{craft_einh}{dbl share of craft beer, by units ordered}
#'   \item{fass_ant}{dbl share ordered in kegs rather than crates, by volume}
#'   \item{alkfrei_ant}{dbl share of alcohol-free beer, by volume}
#'   \item{rabatt_ant}{dbl volume-weighted mean discount granted}
#'   \item{bestelltage}{int number of distinct days on which the customer ordered}
#'   \item{liter_bestellung}{dbl mean litres per order}
#'   \item{letzter_abstand}{int days between the last order and the end of the history}
#'   \item{bestellfrequenz}{dbl share of the 21 history months with at least one order}
#'   \item{sais_amp}{dbl seasonal amplitude: summer volume over winter volume}
#'   \item{trend}{dbl slope of a linear fit through the monthly volumes}
#'   \item{letzte3}{dbl mean volume of the last three months, in hectolitres}
#'   \item{hl_ziel}{dbl hectolitres in the following quarter — the regression target}
#' }
#'
#' @details
#' **Why a second world next to the shoes.** Until 19 November 2026 both the
#' regression and the classification target sat on the same row of
#' [shoe_season_sales]. That made them comparable, but it also meant the
#' lecture never left a single flat table. The brewery carries the regression
#' from then on, the shoes the classification.
#'
#' **What the data set is good for, with measured values.** All figures are
#' ten-fold cross-validated on these 900 rows and are checked by the package
#' tests:
#'
#' * Four model classes separate clearly: linear model \eqn{R^2} 0.597, random
#'   forest 0.594, boosting 0.575, single tree 0.535.
#' * Two naive carry-forward rules fail badly — three times last month's volume
#'   gives \eqn{R^2} -2.306, three times the mean of the last three months
#'   -16.799. A model is not automatically better than doing nothing, and here
#'   it is possible to show that it is.
#' * `letzter_abstand` is a deliberate leakage candidate: it adds almost
#'   nothing on its own (\eqn{R^2} 0.028) yet appears in the permutation
#'   importance, because a customer who has not ordered recently is already on
#'   the way out.
#'
#' **The decision is not the prediction.** Over-production costs the brewery
#' 12 euro per hectolitre, under-production 45 euro. Scaling the prediction by
#' 1.3 lowers the expected cost from 16,286 to 12,780 euro, a saving of 22 per
#' cent, although the \eqn{R^2} of the scaled prediction is worse.
#'
#' The generating process is documented in
#' `data-raw/brauerei_erzeugen.R`. The column `segment_wahr`, which holds the
#' built-in customer segment, stays with the generator and is not delivered.
#'
#' @source Simulated. See `data-raw/brewery_load.R`.
#' @seealso [brewery_orders] for the order lines this table is built from,
#'   [shoe_season_sales] for the classification example.
"brewery_demand"
