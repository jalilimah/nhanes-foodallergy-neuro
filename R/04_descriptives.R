# 04_descriptives.R – survey design, weighted prevalences and Table 1
# Design is built on the FULL sample, then subset to the analysis sample.

library(dplyr)
library(survey)
library(gtsummary)
library(flextable)

options(survey.lonely.psu = "adjust")

nh <- readRDS("data/derived/nhanes_0506_clean.rds")

# ---- 1. Survey design --------------------------------------------------
des <- svydesign(id = ~SDMVPSU, strata = ~SDMVSTRA, weights = ~WTMEC2YR,
                 nest = TRUE, data = nh)
des_a <- subset(des, in_analysis %in% TRUE)   # analysis sample

saveRDS(des_a, "data/derived/design_analysis.rds")

# ---- 2. Weighted prevalences ------------------------------------------
message("Weighted prevalence of food sensitization:")
print(svymean(~food_sens, des_a))
message("Weighted prevalence of PHQ-9 >= 10:")
print(svymean(~depressed, des_a))
message("PHQ-9 >= 10 by sensitization:")
print(svyby(~depressed, ~food_sens, des_a, svymean))

# Each food separately (weighted %)
for (v in c("peanut_pos", "egg_pos", "milk_pos", "shrimp_pos")) {
  est <- svymean(as.formula(paste0("~", v)), des_a, na.rm = TRUE)
  message(v, ": ", round(100 * coef(est)[2], 1), "%")
}

# ---- 3. Table 1 -------------------------------------------------------
tab1 <- tbl_svysummary(
  des_a,
  by = food_sens,
  include = c(age, sex, race, pir, educ, bmi, bmi_cat, smoking, cotinine,
              phq9, depressed, antidepressant,
              LBXVIC, LBXVIE, LBXBEC, LBXCRY, LBXSUA, LBXSGTSI, LBXSTB),
  label = list(age ~ "Age, years", sex ~ "Sex", race ~ "Race/ethnicity",
               pir ~ "Income-to-poverty ratio", educ ~ "Education",
               bmi ~ "BMI, kg/m2", bmi_cat ~ "BMI category",
               smoking ~ "Smoking", cotinine ~ "Serum cotinine, ng/mL",
               phq9 ~ "PHQ-9 score", depressed ~ "Depressive symptoms",
               antidepressant ~ "Antidepressant use",
               LBXVIC ~ "Vitamin C, mg/dL", LBXVIE ~ "Vitamin E, ug/dL",
               LBXBEC ~ "trans-Beta carotene, ug/dL",
               LBXCRY ~ "Beta-cryptoxanthin, ug/dL",
               LBXSUA ~ "Uric acid, mg/dL", LBXSGTSI ~ "GGT, U/L",
               LBXSTB ~ "Total bilirubin, mg/dL"),
  statistic = list(all_continuous() ~ "{median} ({p25}, {p75})",
                   all_categorical() ~ "{n_unweighted} ({p}%)"),
  missing = "no"
) %>%
  add_overall() %>%
  add_p() %>%
  modify_footnote(all_stat_cols() ~
    "Unweighted n (weighted %); weighted median (IQR)") %>%
  bold_labels()

tab1

dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
tab1 %>% as_flex_table() %>% save_as_docx(path = "output/tables/table1.docx")
message("Table 1 saved to output/tables/table1.docx")
