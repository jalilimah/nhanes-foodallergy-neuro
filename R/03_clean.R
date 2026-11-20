# 03_clean.R – define exposure, outcome, covariates and analysis sample
# Keeps ALL participants (needed for the survey design) and adds an
# 'in_analysis' flag. Never drop rows before building the design.

library(dplyr)

nh <- readRDS("data/derived/nhanes_0506_merged.rds")
rx <- readRDS("data/derived/nhanes_0506_rx.rds")

# ---- helper: check variables exist -------------------------------------
need <- function(vars) {
  miss <- setdiff(vars, names(nh))
  if (length(miss)) warning("Not found (check codebook): ",
                            paste(miss, collapse = ", "))
  intersect(vars, names(nh))
}

# ---- 1. Food sensitization (exposure) ----------------------------------
# ImmunoCAP codes: f13 peanut, f1 egg white, f2 milk, f24 shrimp
food_ige <- need(c("LBXF13", "LBXIF1", "LBXIF2", "LBXF24"))

# Check how values below detection are coded before using the cut-off
message("Smallest sIgE values (check below-detection coding):")
print(sort(unique(round(nh$LBXF13, 3)))[1:5])

nh <- nh %>%
  mutate(
    peanut_pos = LBXF13 >= 0.35,
    egg_pos    = LBXIF1  >= 0.35,
    milk_pos   = LBXIF2  >= 0.35,
    shrimp_pos = LBXF24 >= 0.35,
    # number of positive foods; NA if any of the four tests is missing
    n_food_ige = peanut_pos + egg_pos + milk_pos + shrimp_pos,
    food_sens  = factor(n_food_ige > 0, levels = c(FALSE, TRUE),
                        labels = c("Not sensitized", "Sensitized"))
  )

# ---- 2. PHQ-9 depressive symptoms (outcome) ----------------------------
phq_items <- need(sprintf("DPQ0%d0", 1:9))   # DPQ010 ... DPQ090
nh <- nh %>%
  mutate(across(all_of(phq_items), ~ ifelse(.x %in% 0:3, .x, NA)),  # 7/9 -> NA
         phq9      = rowSums(across(all_of(phq_items))),            # NA if any item missing
         depressed = factor(phq9 >= 10, levels = c(FALSE, TRUE),
                            labels = c("PHQ-9 < 10", "PHQ-9 >= 10")))

# ---- 3. Covariates -----------------------------------------------------
nh <- nh %>%
  mutate(
    age  = RIDAGEYR,
    sex  = factor(RIAGENDR, 1:2, c("Male", "Female")),
    race = factor(RIDRETH1, 1:5, c("Mexican American", "Other Hispanic",
                                   "Non-Hispanic White", "Non-Hispanic Black",
                                   "Other/Multiracial")),
    pir  = INDFMPIR,
    educ = factor(case_when(DMDEDUC2 %in% 1:2 ~ "< High school",
                            DMDEDUC2 == 3     ~ "High school",
                            DMDEDUC2 %in% 4:5 ~ "> High school"),
                  levels = c("< High school", "High school", "> High school")),
    bmi  = BMXBMI,
    bmi_cat = cut(bmi, c(0, 25, 30, Inf), right = FALSE,
                  labels = c("<25", "25-29.9", ">=30")),
    cotinine = LBXCOT,
    smoking = factor(case_when(SMQ020 == 2               ~ "Never",
                               SMQ020 == 1 & SMQ040 == 3 ~ "Former",
                               SMQ020 == 1 & SMQ040 %in% 1:2 ~ "Current"),
                     levels = c("Never", "Former", "Current"))
  )

# ---- 4. Antioxidant / redox markers ------------------------------------
redox <- need(c("LBXVIC",    # vitamin C (mg/dL)
                "LBXVIE",    # alpha-tocopherol (ug/dL)
                "LBXBEC",    # beta-carotene
                "LBXCRY",    # beta-cryptoxanthin
                "LBXLYC",    # lycopene
                "LBXSUA",    # uric acid
                "LBXSGTSI",  # GGT
                "LBXSTB",    # total bilirubin
                "LBXSCH",    # cholesterol (to adjust tocopherol)
                "LBXSTR"))   # triglycerides
diet  <- need(c("DR1TKCAL", "DR1TVC", "DR1TATOC", "DR1TFIBE", "WTDRD1"))

nh <- nh %>%
  mutate(vitc_tert = ntile(LBXVIC, 3),
         toco_adj  = LBXVIE / (LBXSCH + LBXSTR))   # lipid-adjusted vitamin E

# ---- 5. Antidepressant use (sensitivity analysis) ----------------------
ad_names <- paste(c("FLUOXETINE", "SERTRALINE", "PAROXETINE", "CITALOPRAM",
                    "ESCITALOPRAM", "FLUVOXAMINE", "VENLAFAXINE",
                    "DULOXETINE", "DESVENLAFAXINE", "BUPROPION",
                    "MIRTAZAPINE", "TRAZODONE", "NEFAZODONE", "AMITRIPTYLINE",
                    "NORTRIPTYLINE", "IMIPRAMINE", "DOXEPIN",
                    "DESIPRAMINE", "CLOMIPRAMINE", "PHENELZINE"),
                  collapse = "|")
ad_ids <- rx %>%
  filter(grepl(ad_names, toupper(RXDDRUG))) %>%
  distinct(SEQN) %>% pull(SEQN)
nh <- nh %>% mutate(antidepressant = SEQN %in% ad_ids)

# ---- 6. Analysis sample flag + flow chart ------------------------------
nh <- nh %>%
  mutate(
    step1_adult  = RIDAGEYR >= 20 & RIDSTATR == 2,   # adults, examined
    step2_ige    = step1_adult & !is.na(food_sens),
    step3_phq    = step2_ige & !is.na(phq9),
    in_analysis  = step3_phq & !is.na(pir) & !is.na(educ) &
                   !is.na(bmi) & !is.na(cotinine)
  )

flow <- c(
  "NHANES 2005-2006"           = nrow(nh),
  "Adults >=20 y, examined"    = sum(nh$step1_adult, na.rm = TRUE),
  "+ food sIgE available"      = sum(nh$step2_ige,   na.rm = TRUE),
  "+ complete PHQ-9"           = sum(nh$step3_phq,   na.rm = TRUE),
  "+ complete covariates"      = sum(nh$in_analysis, na.rm = TRUE)
)
print(flow)

message("Food sensitized in analysis sample (unweighted): ",
        sum(nh$food_sens == "Sensitized" & nh$in_analysis, na.rm = TRUE))
message("PHQ-9 >= 10 in analysis sample (unweighted): ",
        sum(nh$depressed == "PHQ-9 >= 10" & nh$in_analysis, na.rm = TRUE))

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
write.csv(data.frame(step = names(flow), n = flow),
          "output/tables/flow_chart.csv", row.names = FALSE)
saveRDS(nh, "data/derived/nhanes_0506_clean.rds")
message("Saved clean file to data/derived/")
