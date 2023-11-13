
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
# Sækju fyrir síðustu viku
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