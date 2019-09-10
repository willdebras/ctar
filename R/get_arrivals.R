#' get_arrivals
#'
#' Function to query data from the CTA arrivals API. The function can give all estimated arrival times by simply calling `get_arrivals()` or limited estimations by station, route, or a combination of both.
#'
#' @param route The route or "line" for which you want data. Options are red, blue, brown, pink, green, orange, purple, or yellow. This parameter will match the argument to one of these lines.
#' @param station The station, or parent stop, ID. These uniquely identify a station. Call `stop_ids()` for reference
#' @param stop The stop ID. These uniquely identify a station and directiion. Call `stop_ids()` for reference
#' @param key The Chicago Transit Authority developer API key either entered as a string or saved to the environment object `ctar_api_key`
#'
#' @return returns a dataframe of locations, estimated arrivals, and reference data.
#' @export
#' @importFrom httr GET http_type
#' @importFrom jsonlite fromJSON
#'
#' @examples get_arrivals(route = "pink", stop = 30132, key = ctar_api_key)
get_arrivals <- function(route = NULL, station = NULL, stop = NULL, key = ctar_api_key) {


  if (!is.null(route)) {


    route <- match.arg(route, choices = c("red", "blue", "brown", "pink", "green", "orange", "purple", "yellow"))

    route <- switch(route,
                    red = "red",
                    blue = "blue",
                    brown = "brn",
                    pink = "pink",
                    green = "g",
                    orange = "org",
                    purple = "p",
                    yellow = "y"
    )

  }

  url <- paste0("http://lapi.transitchicago.com/api/1.0/ttarrivals.aspx", "?key=", key, "&rt=", route, "&stpid=", stop, "&mapid=", station, "&outputType=JSON")

  raw <- GET(url)

  if (http_type(raw) != "application/json") {
    stop("JSON machine broke: API did not return json", call. = FALSE)
  }


  parsed <- jsonlite::fromJSON(content(raw, "text"), simplifyDataFrame = TRUE)

  df <- parsed$ctatt$eta


  if (is.null(df)) {

    if (is.null(parsed$ctatt$errNm)) {

      stop(
        paste0("No trains found for specified line, stop, and station station combination"),
        call. = FALSE

      )

    }

    else(

      stop(
        paste0("API request failed: ", parsed$ctatt$errNm),
        call. = FALSE
      )
    )
  }



  else {

    df$arrT <- as.POSIXlt(df$arrT, format="%Y-%m-%dT%H:%M:%S")
    df$prdt <- as.POSIXlt(df$prdt, format="%Y-%m-%dT%H:%M:%S")

    return(df)

  }

}
