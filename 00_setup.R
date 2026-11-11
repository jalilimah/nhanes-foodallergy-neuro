# 00_setup.R – run once after creating the project
# Creates the folder structure, ignores data folders and starts renv

folders <- c("R", "data/raw", "data/derived", "output/tables",
             "output/figures", "manuscript")
for (f in folders) dir.create(f, recursive = TRUE, showWarnings = FALSE)

# Keep NHANES data out of GitHub
ignore <- c("data/raw/", "data/derived/", ".Rhistory", ".RData", ".Rproj.user/")
existing <- if (file.exists(".gitignore")) readLines(".gitignore") else character()
writeLines(unique(c(existing, ignore)), ".gitignore")

# Packages for the project
pkgs <- c("nhanesA", "dplyr", "purrr", "survey", "srvyr", "gtsummary",
          "flextable", "ggplot2", "dagitty", "mice", "mediation", "renv")
new <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(new)) install.packages(new)

# Lock package versions for reproducibility
renv::init(bare = TRUE)
renv::snapshot(prompt = FALSE)

message("Setup done. Now commit and push in the Git tab.")
