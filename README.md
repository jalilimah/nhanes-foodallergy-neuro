# Food sensitization, redox markers and depressive symptoms in NHANES 2005–2006

Reproducible analysis of the association between food-specific IgE sensitization and depressive symptoms (PHQ-9) in US adults, and the role of antioxidant and redox markers.

**Author:** Mahsa Jalili
**Status:** in progress – see [PLAN.md](PLAN.md)

## Data
Public data from the National Health and Nutrition Examination Survey (NHANES), cycle 2005–2006, CDC/NCHS. Data are downloaded by the scripts and are not stored in this repository.

## How to run
1. Open `nhanes-foodallergy-neuro.Rproj` in RStudio
2. Run `renv::restore()` to install the package versions used
3. Run the scripts in `R/` in numbered order (or render `analysis.qmd`)

## Structure
```
R/              analysis scripts (01_download.R, 02_merge.R, ...)
data/raw/       downloaded NHANES files (not tracked)
data/derived/   cleaned analysis data (not tracked)
output/         tables and figures
manuscript/     manuscript (Quarto)
```

## Licence
Code: MIT. NHANES data are in the public domain.
