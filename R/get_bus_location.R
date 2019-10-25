#' get_bus_location
#'
#' get_bus_location() fetches the last location and status for buses currently running.
#'
#' The Bus Tracker API allows you to query by the ID of the bus, e.g. 4008, or by the route, e.g. 49.
#'
#'
#' @param routes A vector of bus routes to query, such as c(8, 12, 49). API limits to 10 at a time.
#' @param vehicle_ids A vector of bus routes to query, such as c(4008, 4012, 8049). API limits to 10 at a time.
#' @param time_resolution Determines whether to round the last timestamp up to the minute or not. Default "s" uses second level data. Can supply "m" to round up to minute.
#' @param key The Chicago Transit Authority developer API key either entered as a string or saved to the environment object `ctar_api_key`
#'
#' @return Returns a dataframe of individual bus statuses and last postition as of the API server time in CDT TZ.
#' @export
#'
#' @examples
#'
#' \dontrun{
#' get_bus_location(routes=c(8, 12, 49), key = Sys.getenv("ctar_api_key"))
#' }
get_bus_location <- function(
    routes=NULL,
    vehicle_ids=NULL,
    time_resolution="s",
    key = Sys.getenv("ctar_api_key")
) {

  base_url <- "http://www.ctabustracker.com/bustime/api/v2/"
  endpoint <- "getvehicles"
  url <- paste0(base_url, endpoint)

  if (!is.null(vehicle_ids)) {
      vehicle_ids <- paste(vehicle_ids, collapse=",")
  }

  if (!is.null(routes)) {
      routes <- paste(routes, collapse=",")
  }

  raw <- httr::GET(url, query=list(
      key=key, format="json",
      vid=vehicle_ids, rt=routes, tmres=time_resolution
  ))

  if (http_type(raw) != "application/json") {
      stop("API did not return json", call. = FALSE)
  }

  parsed <- jsonlite::fromJSON(
    httr::content(raw, "text"),
    simplifyDataFrame = TRUE
  )

  df <- parsed$`bustime-response`$vehicle

  if (is.null(df)) {

    if (is.null(parsed$`bustime-response`$error)) {
      stop("No data found for search parameters")
    }
    else {
      stop(
        paste("Error", paste(parsed$`bustime-response`$error, collapse=", "))
      )
    }
  }

  if (time_resolution == "s") {
    time_format <- "%Y%m%d %H:%M:%S"
  } else {
    time_format <- "%Y%m%d %H:%M"
  }
  df$tmstmp <- as.POSIXct(df$tmstmp, format=time_format, tz="CDT")
  return(df)
}
