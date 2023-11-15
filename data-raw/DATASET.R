## code to prepare `DATASET` dataset goes here

jardskjalftar <- tidyr::crossing(
  year = 1994:2023,
  week = 1:53
) |>
  dplyr::rowwise() |>
  dplyr::reframe(
    download_jsk_data(year, week)
  )

usethis::use_data(jardskjalftar, overwrite = TRUE)
