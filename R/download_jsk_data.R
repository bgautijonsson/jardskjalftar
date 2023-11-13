#' Download Icelandic earthquake data
#'
#' @param year The year for which to fetch data
#' @param week The week for which to fetch data
#'
#' @return An sf table object containing all earthquake measurements from http://hraun.vedur.is/ja/ for the selected interval
#' @export
#'
#' @examples
#' cur_date <- Sys.Date()
#' cur_year <- lubridate::year(cur_date)
#' cur_week <- lubridate::week(cur_date)
#' d <- download_jsk_data(year = cur_year, week = cur_year)
download_jsk_data <- function(year, week) {

  week <- stringr::str_pad(week, width = 2, side = "left", pad = "0")

  out <- try(
    readr::read_table(
      glue::glue("http://hraun.vedur.is/ja/viku/{year}/vika_{week}/listi"),
      col_types = readr::cols(
        readr::col_integer(),
        readr::col_number(),
        readr::col_character(),
        readr::col_number(),
        readr::col_number(),
        readr::col_number(),
        readr::col_number(),
        readr::col_number()
      )
    ) |>
      janitor::clean_names() |>
      dplyr::mutate(
        # dags = ymd(dags),
        time = clock::date_time_build(
          year = stringr::str_sub(dags, 1, 4) |> readr::parse_number(),
          month = stringr::str_sub(dags, 5, 6) |> readr::parse_number(),
          day = stringr::str_sub(dags, 7, 8) |> readr::parse_number(),
          hour = stringr::str_sub(timi, 1, 2) |> readr::parse_number(),
          minute = stringr::str_sub(timi, 3, 4) |> readr::parse_number(),
          second = stringr::str_sub(timi, 5, 6) |> readr::parse_number(),
          zone = "GMT"
        )
      ) |>
      dplyr::select(
        time,
        lat = lengd,
        long = breidd,
        depth = dypi,
        m,
        ml
      ) |>
      sf::st_as_sf(
        coords = c("lat", "long"),
        crs = "WGS84"
      ),
    silent = TRUE
  )

  if ("try-error" %in% class(out)) {
    return(
      tibble::tibble()
    )
  } else {
    return(out)
  }


}
