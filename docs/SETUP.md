# Setup

The analysis has two parts: SQL run against a PostgreSQL database that holds
the trip data, and R documents that chart the exported results.

## Data

Download the trip files from each operator and load them into PostgreSQL, one
table per company per year:

- [Divvybikes](https://divvy-tripdata.s3.amazonaws.com/index.html):
  `divvybikes_2017`, `divvybikes_2018`, `divvybikes_2019`, plus `divvy_stations`
- [Bluebikes](https://s3.amazonaws.com/hubway-data/index.html):
  `bluebikes_2017`, `bluebikes_2018`, `bluebikes_2019`, plus `bluebikes_stations`
- `baywheels_2017` and `baywheels_2018`, used only by question 7

The distance queries (questions 4 and 6) call a user-defined function,
`calculate_distance(lat1, lon1, lat2, lon2, 'K')`, that returns kilometres. Its
definition is not stored in this repository, so it has to exist in the
database before those queries run.

Run the queries in [METHODOLOGY.md](METHODOLOGY.md) and export each result to
[csvdata/](../csvdata/).

## R documents

Requires R with the packages `ggplot2`, `tidyr` and `scales`
(`tidyverse` is used by the exploratory script).

```r
install.packages(c("ggplot2", "tidyr", "scales"))
rmarkdown::render("plots.rmd")
rmarkdown::render("bikeshare_story.rmd")
rmarkdown::render("docs/analysis.rmd")
```

The documents read the CSV files from the repository's `main` branch on
GitHub (`raw.githubusercontent.com`), so they need an internet connection and
use the committed files in `csvdata/`, not local edits.

[plots.html](../plots.html) is the rendered output of `plots.rmd` and is the
target of the "Visualisations" link, which uses htmlpreview.github.io.

## Repository layout

```
bikeshare_studies/
  README.md               the case study
  assets/                 chart used by the README
  csvdata/                exported query results, one file per question
  docs/
    SETUP.md              this file
    METHODOLOGY.md        the seven questions with their SQL and results
    analysis.rmd          the previous README source (R Markdown)
  scripts/
    q1plots.R             question 1 chart
    EDA.R                 exploratory R snippets
  plots.rmd, plots.html   charts for questions 1 to 5
  bikeshare_story.rmd     narrative report with SQL, charts and findings
  .github/workflows/      R CMD check workflow
```

`scripts/EDA.R` also contains an unrelated PISA scores example that was
carried over from a tutorial; it is not part of this analysis.
