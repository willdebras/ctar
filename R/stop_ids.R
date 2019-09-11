#' ctar stop IDs dataset
#'
#' A dataset containing stop IDs and parent/station IDs associated with each CTA train station.
#' Call the dataset with `data(stop_ids)`
#'
#'
#' @format A data frame with 301 rows and 22 variables:
#' \describe{
#'   \item{STOP_ID}{Unique identifier of station and direction}
#'   \item{DIRECTION}{Direction of train with associated STOP ID}
#'   \item{STOP_NAME}{Name of the stop: parent station name with station-bound information}
#'   \item{STATION_NAME}{Name of the parent station}
#'   \item{STATION_DESCRIPTIVE_NAME}{Station name with appended description of the route/line}
#'   \item{STATION_ID}{Unique identifier for each station, also known as "parent ID" or "parent station ID"}
#'   \item{ADA}{Binary variable identifying if the station is accessible to riders with disabilities}
#'   \item{Location}{Latitude and longitude of the station}
#'   ...
#' }
#' @source \url{https://data.cityofchicago.org/Transportation/CTA-System-Information-List-of-L-Stops/8pix-ypme}
"stop_ids"
