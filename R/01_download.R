# 01_download.R – download NHANES 2005–2006 files needed for the analysis
# Saves each file as .rds in data/raw/ (not tracked by Git)

library(nhanesA)

tables <- c(
  DEMO_D   = "Demographics, weights, strata, PSU",
  AL_IGE_D = "Allergen-specific IgE and total IgE",
  DPQ_D    = "PHQ-9 depression screener",
  VIC_D    = "Vitamin C",
  VITAEC_D = "Vitamin A, E and carotenoids",
  BIOPRO_D = "Standard biochemistry (uric acid, GGT, bilirubin)",
  DR1TOT_D = "Dietary recall day 1, total nutrients",
  BMX_D    = "Body measures (BMI)",
  SMQ_D    = "Smoking questionnaire",
  COT_D    = "Serum cotinine",
  RXQ_RX_D = "Prescription medications (long format)"
)

dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)

for (tb in names(tables)) {
  out <- file.path("data/raw", paste0(tb, ".rds"))
  if (file.exists(out)) {
    message("Already downloaded: ", tb)
    next
  }
  message("Downloading ", tb, " – ", tables[[tb]])
  dat <- tryCatch(
    nhanes(tb, translated = FALSE),   # keep numeric codes
    error = function(e) {
      warning("Failed: ", tb, " – ", conditionMessage(e))
      NULL
    }
  )
  if (!is.null(dat)) {
    saveRDS(dat, out)
    message("  saved ", nrow(dat), " rows, ", ncol(dat), " columns")
  }
}

# Check what we have
got <- sub("\\.rds$", "", list.files("data/raw", pattern = "\\.rds$"))
missing <- setdiff(names(tables), got)
if (length(missing)) {
  message("Missing tables: ", paste(missing, collapse = ", "),
          " – re-run the script")
} else {
  message("All ", length(tables), " tables downloaded.")
}
