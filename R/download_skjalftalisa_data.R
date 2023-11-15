#' Download newest Icelandic earthquake data from http://skjalftalisa.vedur.is
#'
#' @param start_time A datetime object or a string
#' @param end_time A datetime object or a string
#' @param depth_min The minimum earthquake depth to fetch (default = 0)
#' @param depth_max The maximum earthquake depth to fetch (default = 25)
#' @param size_min The minimum earthquake size to fetch (default = 0)
#' @param size_max The maximum earthquake size to fetch (default = 7)
#' @param magnitude_preference Preferred magnitude measure -"Mlw" or "Autmag"- (Default is "Mlw")
#' @param event_type The type of event to fetch (default is "qu")
#' @param originating_system The originating system to fetch from (default is "SIL picks")
#' @param area Geographical area to fetch from (default is a bounding box around Iceland)
#' @param fields The fields to fetch data on from the service.
#'
#' @return An {sf} table containing magnitude, location and timestamp of recorded earthquakes
#' @export
#'
#' @examples
#' start_time <- max(jardskjalftar$time)
#' end_time <- Sys.time()
#'
#' d <- download_skjalftalisa_data(start_time, end_time)
download_skjalftalisa_data <- function(
    start_time,
    end_time,
    depth_min = 0,
    depth_max = 25,
    size_min = 0,
    size_max = 7,
    magnitude_preference = c("Mlw", "Autmag"),
    event_type = "qu",
    originating_system = "SIL picks",
    area = c(68, 61, -32, -4),
    fields = c("event_id", "lat", "long", "time", "magnitude", "event_type", "originating_system")
) {
  url <- "https://api.vedur.is/skjalftalisa/v1/quake/array"

  query <- build_skjalftalisa_query(
    start_time = start_time,
    end_time = end_time
  )

  req <- httr2::request(url) |>
    httr2::req_body_json(query)

  resp <- try(
    req |>
      httr2::req_perform()
  )

  if ("try-error" %in% class(resp)) {
    stop("There was an error. Check your datetime object (must contain numbers for hours, minutes and seconds) or try to split your request into smaller requests. You can also compare the query built with build_skalftalisa_query(start_time, end_time, to_json = TRUE) to the example query in example_skjalftalisa_query()")
  }

  resp_body <- resp |> httr2::resp_body_json()

  d <- tibble::tibble(
    data = list(resp_body)
  ) |>
    tidyr::unnest(data) |>
    tidyr::unnest_wider(data) |>
    tidyr::unnest_longer(dplyr::everything())

  d |>
    dplyr::mutate(
      time = lubridate::as_datetime(time),
      magnitude_type = magnitude_preference[1]
    ) |>
    dplyr::select(
      time,
      magnitude,
      magnitude_type,
      lat, long
    ) |>
    sf::st_as_sf(
      coords = c("long", "lat"),
      crs = "WGS84"
    )
}


#' Helper function for making a JSON POST query from input variables
#'
#' @param start_time A datetime object or a string
#' @param end_time A datetime object or a string
#' @param to_json Should the R list be converted to a JSON string?
#' @param depth_min The minimum earthquake depth to fetch (default = 0)
#' @param depth_max The maximum earthquake depth to fetch (default = 25)
#' @param size_min The minimum earthquake size to fetch (default = 0)
#' @param size_max The maximum earthquake size to fetch (default = 7)
#' @param magnitude_preference Preferred magnitude measure -"Mlw" or "Autmag"- (Default is "Mlw")
#' @param event_type The type of event to fetch (default is "qu")
#' @param originating_system The originating system to fetch from (default is "SIL picks")
#' @param area Geographical area to fetch from (default is a bounding box around Iceland)
#' @param fields The fields to fetch data on from the service.
#'
#' @return A list/json string containing the query to be sent
build_skjalftalisa_query <- function(
    start_time,
    end_time,
    to_json = FALSE,
    depth_min = 0,
    depth_max = 25,
    size_min = 0,
    size_max = 7,
    magnitude_preference = c("Mlw", "Autmag"),
    event_type = list("qu"),
    originating_system = list("SIL picks"),
    area = c(68, 61, -32, -4),
    fields = c("event_id", "lat", "long", "time", "magnitude", "event_type", "originating_system")
) {

  out <- list(
    start_time = jsonlite::unbox(start_time),
    end_time = jsonlite::unbox(end_time),
    depth_min = jsonlite::unbox(depth_min),
    depth_max = jsonlite::unbox(depth_max),
    size_min = jsonlite::unbox(size_min),
    size_max = jsonlite::unbox(size_max),
    magnitude_preference = magnitude_preference,
    event_type = event_type,
    originating_system = originating_system,
    area = list(
      c(area[1], area[3]),
      c(area[2], area[3]),
      c(area[2], area[4]),
      c(area[1], area[4])
    ),
    fields = fields
  )

  if (isTRUE(to_json)) {
    return(jsonlite::toJSON(out, auto_unbox = TRUE))
  }

  out
}


#' An example of a JSON body form a POST request to http://skjalftalisa.vedur.is. Useful for debugging.
#'
#' @return A character vector showing the example JSON body
#' @export
example_skjalftalisa_query <- function() {
  writeLines('{"start_time":"2023-11-08 09:43:00","end_time":"2023-11-15 09:43:00","depth_min":0,"depth_max":25,"size_min":0,"size_max":7,"magnitude_preference":["Mlw","Autmag"],"event_type":["qu"],"originating_system":["SIL picks"],"area":[[68,-32],[61,-32],[61,-4],[68,-4]],"fields":["event_id","lat","long","time","magnitude","event_type","originating_system"]}')
}
