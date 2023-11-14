
<!-- README.md is generated from README.Rmd. Please edit that file -->

# jardskjalftar

<!-- badges: start -->
<!-- badges: end -->

Hægt er að sækja pakkann frá github t.d. með

``` r
#install.packages("devtools")
devtools::install_github("bgautijonsson/jardskjalftar")
```

Þessi pakki inniheldur allar jarðskjálftamælingar
<http://hraun.vedur.is/ja/> frá 1994 til dagsins þegar pakkinn var
síðast uppfærður. Gögnin má finna í töflunni `jardskjalftar`

``` r
library(jardskjalftar)
head(jardskjalftar)
#>                  time depth    m   ml            geometry
#> 1 1994-02-08 03:30:22 4.082 1.88 2.25 -19.41148, 66.40826
#> 2 1994-02-08 03:32:32 3.644 1.73 1.71 -19.58435, 66.62346
#> 3 1994-02-08 03:33:04 3.044 1.50 1.45 -19.71142, 66.66263
#> 4 1994-02-08 03:33:38 3.844 1.09 1.44 -19.03255, 66.44884
#> 5 1994-02-08 03:35:19 3.044 1.76 1.58 -19.28246, 66.40868
#> 6 1994-02-08 03:36:06 3.044 1.94 2.28 -19.31804, 66.41004
```

Ef þú vilt sækja nýrri gögn sem urðu til eftir uppfærslu pakkans er hægt
að nota fallið `download_jsk_data()`. Gögnin eru sótt fyrir viku í senn
og því getur verið að það sé ekki búið að uppfæra þau í byrjun vikunnar.

``` r
cur_date <- Sys.Date()
cur_year <- lubridate::year(cur_date)
cur_week <- lubridate::week(cur_date)
# Sækjum fyrir síðustu viku
cur_week <- cur_week - 1
newest_data <- download_jsk_data(year = cur_year, week = cur_week)

head(newest_data)
#> Simple feature collection with 6 features and 4 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -22.56732 ymin: 63.84821 xmax: -22.39716 ymax: 63.90454
#> Geodetic CRS:  WGS 84
#> # A tibble: 6 × 5
#>   time                depth     m    ml             geometry
#>   <dttm>              <dbl> <dbl> <dbl>          <POINT [°]>
#> 1 2023-11-06 00:00:42  4.31  1.81  1.12 (-22.39716 63.90454)
#> 2 2023-11-06 00:02:15  4.65  1.92  1.32 (-22.40628 63.87729)
#> 3 2023-11-06 00:03:51  5.14  2.13  1.46 (-22.41322 63.87817)
#> 4 2023-11-06 00:21:03  4.90  2.6   1.85 (-22.40709 63.88234)
#> 5 2023-11-06 00:50:15  5.52  0.52  0.16 (-22.56732 63.84821)
#> 6 2023-11-06 00:54:26  1.37  0.69 -0.25  (-22.4157 63.87876)
```

Ég skrifaði fall til að sækja gögn frá <http://skjalftalisa.vedur.is>,
`download_skjalftalisa_data()`. Gögnin þar gætu verið uppfærð fyrr
heldur en á <http://hraun.vedur.is/ja/>.

Hér er dæmi um hvernig sækja má gögn úr Skjálftalísu fyrir Nóvember fram
til nú.

``` r
start_time <- clock::date_time_build(
  year = 2023, 
  month = 11, 
  day = 1, 
  hour =  0,
  minute =  0, 
  second = 1, 
  zone = "GMT"
)
end_time <- Sys.time()

skjalftalisa_data <- download_skjalftalisa_data(start_time, end_time)

head(skjalftalisa_data)
#> Simple feature collection with 6 features and 3 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -22.51204 ymin: 63.84214 xmax: -22.34315 ymax: 63.89799
#> Geodetic CRS:  WGS 84
#> # A tibble: 6 × 4
#>   time                magnitude magnitude_type             geometry
#>   <dttm>                  <dbl> <chr>                   <POINT [°]>
#> 1 2023-11-01 00:07:32      0.3  Mlw            (-22.49863 63.84631)
#> 2 2023-11-01 00:08:51      0.2  Mlw             (-22.42492 63.8828)
#> 3 2023-11-01 00:11:41      0.87 Mlw            (-22.34315 63.89799)
#> 4 2023-11-01 00:12:37      0.93 Mlw            (-22.39736 63.87283)
#> 5 2023-11-01 00:13:18      0.5  Mlw            (-22.51204 63.84214)
#> 6 2023-11-01 00:15:16      0.83 Mlw             (-22.46237 63.8552)
```

Við sjáum að gögnin frá Skjálftalísu eru glæný.

``` r
max(skjalftalisa_data$time)
#> [1] "2023-11-14 12:39:07 UTC"
```

``` r
Sys.time()
#> [1] "2023-11-14 13:13:19 GMT"
```

Það eru einhver takmörk á hvað má sækja mikið af gögnum í einu, en það
er tiltölulega auðvelt að sækja gögn fyrir nokkur ár með því að skipta
því upp í eina beiðni fyrir hvert ár

``` r
download_skjalftalisa_year <- function(year) {
  start_time <- clock::date_time_build(
    year, 1, 1, 0, 0, 1, zone = "GMT"
  )
  
  end_time <- clock::date_time_build(
    year, 12, 31, 23, 59, 59, zone = "GMT"
  )
  
  download_skjalftalisa_data(
    start_time,
    end_time
  )
}


d <- purrr::map_dfr(2020:2022, download_skjalftalisa_year)

start_time_2023 <- clock::date_time_build(
  2023, 1, 1, 0, 0, 1, zone = "GMT"
)

end_time_2023 <- Sys.time()

d_2023 <- download_skjalftalisa_data(
  start_time_2023,
  end_time_2023
)


d |> 
  dplyr::bind_rows(d_2023) |> 
  dplyr::glimpse()
#> Rows: 146,554
#> Columns: 4
#> $ time           <dttm> 2020-01-05 12:27:11, 2020-01-05 13:21:59, 2020-01-05 1…
#> $ magnitude      <dbl> 1.69, 1.04, 1.26, 0.88, 2.79, 2.10, 2.75, 0.49, 0.58, 0…
#> $ magnitude_type <chr> "Mlw", "Mlw", "Mlw", "Mlw", "Mlw", "Mlw", "Mlw", "Mlw",…
#> $ geometry       <POINT [°]> POINT (-17.8749 66.64684), POINT (-17.00638 65.87…
```
