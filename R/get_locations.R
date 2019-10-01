#' get_locations
#'
#' Function to query data from the CTA locations API. The function can provide a list of all trains and their locations and attributes by calling `get_locations()` or limited estimations by route/line.
#'
#' @param route The route or "line" for which you want data. Options are red, blue, brown, pink, green, orange, purple, or yellow. This parameter will match the argument to one of these lines.
#' @param key The Chicago Transit Authority developer API key either entered as a string or saved to the environment object `ctar_api_key`
#'
#' @return returns a dataframe of locations data associated with the route/line specified
#' @export
#' @importFrom httr GET http_type content
#' @importFrom jsonlite fromJSON
#'
#' @examples get_locations(route = "red", key = ctar_api_key)
get_locations <- function(route = NULL, key = ctar_api_key) {


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

  else(
    stop("No route specified", call. = FALSE)

  )



  url <- paste0("http://lapi.transitchicago.com/api/1.0/ttpositions.aspx", "?key=", key, "&rt=", route, "&outputType=JSON")

  raw <- httr::GET(url)

  if (httr::http_type(raw) != "application/json") {
    stop("Help I'm stuck in a JSON factory: API did not return json", call. = FALSE)
  }



  parsed <- jsonlite::fromJSON(content(raw, "text"), simplifyDataFrame = TRUE)

  df <- parsed$ctatt$route[[2]][[1]]

  if (is.null(df)) {

    if (is.null(parsed$ctatt$errNm)) {

      stop(
        paste0("No trains found for this route."),
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
