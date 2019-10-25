#' get_bus_route_stops
#'
#' get_bus_route_stops() takes a CTA route ID and direction and returns the locations of stops along that route.
#'
#'
#' @param route The bus route ID, such as 12.
#' @param direction The direction of the bus route ID, such as "e", "east" or "Eastbound".
#' @param key The Chicago Transit Authority developer API key either entered as a string or saved to the environment object `ctar_api_key`
#'
#' @return Returns a dataframe with the location of stops for a specific CTA bus route with direction.
#' @export
#'
#' @examples
#'
#' \dontrun{
#' get_bus_route_stops(route=12, direction="east", key = Sys.getenv("ctar_api_key"))
#' }
get_bus_route_stops <- function(
    route = NULL,
    direction = NULL,
    key = Sys.getenv("ctar_api_key")
) {

  if (is.null(route)) {
    stop("You must supply both a route and direction to query")
  }

  if (is.null(direction)) {
    stop("You must supply both a route and direction to query")
  }

  if (!is.null(direction)) {

    direction <- match.arg(
      direction,
      choices = c("e", "east", "w", "west", "s", "south", "n", "north"))

    direction <- switch(direction,
      e = "Eastbound",
      east = "Eastbound",
      w = "Westbound",
      west = "Westbound",
      n = "Northbound",
      north = "Northbound",
      s = "Southbound",
      south = "Southbound"
    )

  }

  base_url <- "http://www.ctabustracker.com/bustime/api/v2/"
  endpoint <- "getstops"
  url <- paste0(base_url, endpoint)
  
  raw <- httr::GET(url, query=list(key=key, format="json", rt=route, dir=direction))
  
  if (http_type(raw) != "application/json") {
      stop("API did not return json", call. = FALSE)
  }

  parsed <- jsonlite::fromJSON(
    httr::content(raw, "text"),
    simplifyDataFrame = TRUE
  )

  df <- parsed$`bustime-response`$stops

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

  return(df)
}