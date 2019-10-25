#' get_bus_routes
#'
#' get_bus_routes() fetches the route ID, name, and color of all buses routes currently available.
#'
#'
#' @param key The Chicago Transit Authority developer API key either entered as a string or saved to the environment object `ctar_api_key`
#'
#' @return Returns a dataframe with the route ID, name, and color for all CTA bus routes.
#' @export
#'
#' @examples
#'
#' \dontrun{
#' get_bus_routes(key = Sys.getenv("ctar_api_key"))
#' }
get_bus_routes <- function(
    key = Sys.getenv("ctar_api_key")
) {
    
  base_url <- "http://www.ctabustracker.com/bustime/api/v2/"
  endpoint <- "getroutes"
  url <- paste0(base_url, endpoint)
  
  raw <- httr::GET(url, query=list(key=key, format="json"))
  
  if (http_type(raw) != "application/json") {
      stop("API did not return json", call. = FALSE)
  }

  parsed <- jsonlite::fromJSON(
    httr::content(raw, "text"),
    simplifyDataFrame = TRUE
  )

  df <- parsed$`bustime-response`$routes

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