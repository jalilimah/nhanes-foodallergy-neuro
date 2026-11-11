# 02_merge.R – merge NHANES 2005–2006 tables into one analysis file
# One row per participant (SEQN). Start from DEMO_D so no one is lost
# before the survey design is built.

library(dplyr)
library(purrr)

read_raw <- function(tb) readRDS(file.path("data/raw", paste0(tb, ".rds")))

# One-row-per-person tables
wide_tables <- c("DEMO_D", "AL_IGE_D", "DPQ_D", "VIC_D", "VITAEC_D",
                 "BIOPRO_D", "DR1TOT_D", "BMX_D", "SMQ_D", "COT_D")

dat_list <- map(wide_tables, read_raw)
names(dat_list) <- wide_tables

# Check: SEQN must be unique in every table
dups <- map_int(dat_list, ~ sum(duplicated(.x$SEQN)))
stopifnot("Duplicate SEQN found" = all(dups == 0))

# Merge everything onto demographics
nh <- reduce(dat_list[-1], left_join, by = "SEQN", .init = dat_list$DEMO_D)

# Prescription medications are in long format (several rows per person).
# Keep them separate; the antidepressant flag is made in 03_clean.R
rx <- read_raw("RXQ_RX_D")

# Quick checks
message("Participants: ", nrow(nh))                        # expect ~10,348
message("Columns: ", ncol(nh))
# Food sIgE variables follow ImmunoCAP codes: LBXF13 peanut, LBXF1 egg,
# LBXF2 milk, LBXF24 shrimp. Check with: grep("^LBX", names(nh), value = TRUE)
message("With peanut sIgE: ", sum(!is.na(nh$LBXF13)))
message("With PHQ-9 item 1: ", sum(!is.na(nh$DPQ010)))

dir.create("data/derived", recursive = TRUE, showWarnings = FALSE)
saveRDS(nh, "data/derived/nhanes_0506_merged.rds")
saveRDS(rx, "data/derived/nhanes_0506_rx.rds")
message("Saved merged file to data/derived/")
