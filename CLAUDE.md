# jardskjalftar -- CLAUDE.md

R package for accessing Icelandic earthquake data from vedur.is (the Icelandic Met Office).

## Commands

```r
devtools::load_all()      # Load for interactive testing
devtools::document()      # Regenerate NAMESPACE + man/
devtools::check()         # R CMD check
```

## Exported functions (3)

| Function                          | Purpose                                                  |
| --------------------------------- | -------------------------------------------------------- |
| `download_jsk_data(...)`          | Download earthquake data from vedur.is                   |
| `download_skjalftalisa_data(...)` | Download data from the Skjalftalisa earthquake catalogue |
| `example_skjalftalisa_query()`    | Example query parameters for Skjalftalisa                |

## Architecture

- `R/` -- source files
- `data/` and `data-raw/` -- preprocessed earthquake datasets
- `man/` -- auto-generated roxygen2 docs

## Dependencies

**Depends:** R (>= 2.10)
**Imports:** clock, dplyr, glue, httr2, janitor, lubridate, purrr, readr, sf, stringr

## Development status

- Version: 0.0.2
- Tests: none
- CI: GitHub Actions R-CMD-check
- GitHub: bgautijonsson/jardskjalftar
- Dormant -- maintained for API breakage detection
