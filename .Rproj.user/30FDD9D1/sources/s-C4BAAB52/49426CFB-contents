#' get_arrivals
#'
#' @param route
#' @param station
#' @param key
#'
#' @return
#' @export
#'
#' @examples
get_arrivals <- function(route = NULL, station = NULL, key = ctar_api_key) {
  require(httr)
  require(rlang)

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

  url <- paste0("http://lapi.transitchicago.com/api/1.0/ttarrivals.aspx", "?key=", key, "&rt=", route, "&stpid=", station, "&outputType=JSON")

  raw <- GET(url)

  if (http_type(raw) != "application/json") {
    stop("JSON machine broke: API did not return json", call. = FALSE)
  }


  parsed <- jsonlite::fromJSON(content(raw, "text"), simplifyDataFrame = TRUE)

  df <- parsed$ctatt$eta


  if (is.null(df)) {

    if (is.null(parsed$ctatt$errNm)) {

      stop(
        paste0("No trains found for specified line and station combination"),
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
