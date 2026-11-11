# Project plan – NHANES food sensitization, redox and depressive symptoms

**Research question:** In US adults (NHANES 2005–2006), is food sensitization (specific IgE to peanut, egg, milk or shrimp) associated with depressive symptoms (PHQ-9), and do antioxidant/redox markers modify or mediate this association?

**Link to NeuroAll:** preliminary human data for the gut–barrier–redox–neuroimmune axis (NNF Emerging Investigator, deadline 12 Jan 2027).

---

## Steps

### 1. Setup (days 1–2)
- [X] GitHub repo created and cloned in RStudio
- [X] `00_setup.R` run (folders + renv)
- [X] First commit and push

### 2. Get the data (days 3–4) – `R/01_download.R`, `R/02_merge.R`
- [ ] Download 2005–2006 files with `nhanesA`:
  - `DEMO_D` demographics, weights, strata, PSU
  - `AL_IGE_D` allergen-specific IgE
  - `DPQ_D` PHQ-9
  - `VIC_D`, `VITAEC_D` vitamin C, vitamin E, carotenoids
  - `BIOPRO_D` uric acid, GGT, bilirubin
  - `DR1TOT_D` diet day 1
  - `BMX_D`, `SMQ_D`, `COT_D` BMI, smoking, cotinine
  - `RXQ_RX_D` medications (antidepressant sensitivity analysis)
- [ ] Merge on `SEQN`, save to `data/derived/`

### 3. Clean and define variables (week 2) – `R/03_clean.R`
- [ ] Exposure: any food sIgE ≥ 0.35 kU/L
- [ ] Outcome: PHQ-9 ≥ 10 (plus continuous score)
- [ ] Covariates: age, sex, race/ethnicity, PIR, BMI, smoking/cotinine, education
- [ ] Adults ≥ 20 y; participant flow chart
- [ ] Missing data: complete case; `mice` as sensitivity

### 4. Survey design and Table 1 (weeks 2–3) – `R/04_descriptives.R`
- [ ] `svydesign(id = ~SDMVPSU, strata = ~SDMVSTRA, weights = ~WTMEC2YR, nest = TRUE)`
- [ ] `WTDRD1` for diet models
- [ ] Subset the design object, never filter data before the design
- [ ] Table 1 by sensitization (`gtsummary::tbl_svysummary`)

### 5. Models (weeks 3–4) – `R/05_models.R`
- [ ] DAG (`dagitty`) to choose confounders
- [ ] `svyglm(..., family = quasibinomial())`: crude → demographics → fully adjusted
- [ ] Interaction: sensitization × antioxidant tertiles
- [ ] Exploratory mediation via redox markers
- [ ] Sensitivity: continuous PHQ-9, single allergens, excluding antidepressant users
- [ ] Forest plot + Tables 2–3

**→ Mid-December: key figure + short results paragraph for the grant.**

### 6. Reproducible release (week 5)
- [ ] `analysis.qmd` runs whole pipeline
- [ ] README updated (how to run, session info)
- [ ] Tag release `v1.0`, link Zenodo for a DOI

### 7. Manuscript (weeks 5–8) – `manuscript/manuscript.qmd`
- [ ] Methods (write during analysis)
- [ ] Results (Tables 1–3, figure)
- [ ] Introduction
- [ ] Discussion (strengths, limitations: cross-sectional, sIgE ≠ clinical allergy, 2005–2006 only)
- [ ] Abstract
- [ ] STROBE checklist
- [ ] Target journal + medRxiv preprint

---

## Skills checklist
- [ ] Git/GitHub in RStudio (commit, push, pull)
- [ ] `renv` for reproducibility
- [ ] `nhanesA` data download
- [ ] `survey` / `srvyr` – complex survey design
- [ ] `gtsummary` + `flextable` tables
- [ ] `ggplot2` forest plots
- [ ] DAGs and confounding (`dagitty`)
- [ ] Interaction and mediation basics
- [ ] Quarto reports and manuscripts
- [ ] Zotero + Better BibTeX references
- [ ] STROBE reporting
