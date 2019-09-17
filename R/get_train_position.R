#' get_train_position
#'
#' This function is one of two that interacts with the Follow the Train API. It provides the location of a single train by its run number.
#'
#' This API tends to be finicky and fail. The `get_arrivals()` function tends to be more precise and can be filtered by run number.
#'
#'
#' @param run_number This is a run number associated with a single train. These change daily. `get_arrivals()` or `get_locations()` will provide info on run number.
#' @param key The Chicago Transit Authority developer API key either entered as a string or saved to the environment object `ctar_api_key`
#'
#'
#' @importFrom httr GET http_type content
#' @importFrom jsonlite fromJSON
#'
#' @return Returns a table of the longitude and latitude of a single train.
#' @export
#'
#' @examples get_train_position(308, key = ctar_api_key)
get_train_position <- function(run_number = NULL, key = ctar_api_key) {


  url <- paste0("https://lapi.transitchicago.com/api/1.0/ttfollow.aspx", "?key=", key, "&runnumber=", run_number, "&outputType=JSON")

  raw <- GET(url)


  if (http_type(raw) != "application/json") {
    stop("The end is nigh: API did not return json", call. = FALSE)
  }


  parsed <- jsonlite::fromJSON(content(raw, "text"), simplifyDataFrame = TRUE)

  df <- as.data.frame(parsed$ctatt$position)


  if (is.null(df)) {

    if (is.null(parsed$ctatt$errNm)) {

      stop(
        paste0("Invalid request."),
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

    return(df)

  }

}
