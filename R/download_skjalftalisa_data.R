#' Download newest Icelandic earthquake data from http://skjalftalisa.vedur.is
#'
#' @param start_time
#' @param end_time
#' @param depth_min
#' @param depth_max
#' @param size_min
#' @param size_max
#' @param magnitude_preference
#' @param event_type
#' @param originating_system
#' @param area
#' @param fields
#'
#' @return
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

  POST_response <- httr::POST(
    url,
    httr::add_headers(
      "Accept" = "*/*",
      "Accept-Language" = "en-GB,en-US;q=0.9,en;q=0.8",
      "Content-Type" = "application/json",
      "Host" = "api.vedur.is",
      "Origin" = "http://skjalftalisa.vedur.is",
      "Referer" = "http://skjalftalisa.vedur.is"
    ),
    body = query
  )


  res <- tibble::tibble(
    data = list(httr::content(POST_response, "parsed")
    )
  )

  d <- res |>
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
#' @param start_time
#' @param end_time
#' @param depth_min
#' @param depth_max
#' @param size_min
#' @param size_max
#' @param magnitude_preference
#' @param event_type
#' @param originating_system
#' @param area
#' @param fields
#'
#' @return
build_skjalftalisa_query <- function(
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

  list(
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
  ) |>
    jsonlite::toJSON()
}
