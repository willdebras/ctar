#' get_bus_route_directions
#'
#' get_bus_route_directions() takes a CTA route ID and returns the directions it travels.
#'
#'
#' @param route The bus route ID, such as 12.
#' @param key The Chicago Transit Authority developer API key either entered as a string or saved to the environment object `ctar_api_key`
#'
#' @return Returns a dataframe with the directions for a specific CTA bus route.
#' @export
#'
#' @examples
#'
#' \dontrun{
#' get_bus_route_directions(route=12, key = Sys.getenv("ctar_api_key"))
#' }
get_bus_route_directions <- function(
    route = NULL,
    key = Sys.getenv("ctar_api_key")
) {

  if (is.null(route)) {
    stop("You must supply a route to query")
  }

  base_url <- "http://www.ctabustracker.com/bustime/api/v2/"
  endpoint <- "getdirections"
  url <- paste0(base_url, endpoint)

  raw <- httr::GET(url, query=list(key=key, format="json", rt=route))

  if (httr::http_type(raw) != "application/json") {
      stop("API did not return json", call. = FALSE)
  }

  parsed <- jsonlite::fromJSON(
    httr::content(raw, "text"),
    simplifyDataFrame = TRUE
  )

  df <- parsed$`bustime-response`$directions

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
