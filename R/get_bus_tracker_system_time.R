#' get_bus_system_time
#'
#' get_bus_system_time() simply fetches the time on the Bus Tracker API server.
#'
#' This function doesn't do much, but is critical for comparing arrival times.
#' The Bus Tracker API runs on a server. To make sure bus tracking information
#' matches your computer's time, you should run this function to synchronize.
#'
#'
#' @param key The Chicago Transit Authority developer API key either entered as a string or saved to the environment object `ctar_api_key`
#'
#' @return Returns a POSIXct datetime of the API server time in CDT TZ.
#' @export
#'
#' @examples
#'
#' \dontrun{
#' get_bus_system_time(key = Sys.getenv("ctar_api_key"))
#' }
get_bus_system_time <- function(key = Sys.getenv("ctar_api_key")) {
    
  base_url <- "http://www.ctabustracker.com/bustime/api/v2/"
  endpoint <- "gettime"
  url <- paste0(base_url, endpoint)
  raw <- httr::GET(url, query=list(key=key, format="json"))
  
  if (http_type(raw) != "application/json") {
      stop("API did not return json", call. = FALSE)
  }

  parsed <- jsonlite::fromJSON(
    httr::content(raw, "text"),
    simplifyDataFrame = TRUE
  )

  tm <- parsed$`bustime-response`$tm

  if (is.null(tm)) {
    stop("The API has changed its reponse format")
  }
  tm <- as.POSIXct(tm, format="%Y%m%d %H:%M:%S", tz="CDT")
  return(tm)
}