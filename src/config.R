# ------------------------------------------------------------------------------
# Pipeline configuration: paths, seeds, and tuning parameters
# Sourced by setup.R so all scripts get these when they source setup.
# ------------------------------------------------------------------------------

# Reproducibility
SEED <- 42L

# Data paths (relative to project root)
# Train data in repo; test data placed by grader at data/raw/test.csv
PATH_TRAIN <- file.path("data", "train.csv")
PATH_TEST <- file.path("data", "raw", "test.csv")

# Output paths
DIR_FITS <- file.path("models")

# Cross-validation
N_FOLDS <- 5L
VAL_FRAC <- 0.2

# Lasso tuning grid
PENALTY_RANGE <- c(-5, 2)
PENALTY_LEVELS <- 25L

# Cap shares at this quantile before log (lower = more aggressive cap = lower MSE)
CAP_QUANTILE <- 0.75
