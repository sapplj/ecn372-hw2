# ECN372 Homework 2 — Predicting Article Popularity

This repo trains a **Lasso** model for predicting **log(shares)** (number of social shares of online news articles) from the [Online News Popularity](https://archive.ics.uci.edu/dataset/332/online+news+popularity) dataset. At grading time, `make evaluate` prints the **test MSE** (mean squared error) on a capped scale.

---

## Structure

| Path | Purpose |
|------|--------|
| **`scripts/`** | R scripts run in order. `01_model_fit.R` trains Lasso and saves the model; `02_evaluate.R` loads the model, predicts on test data, prints MSE. |
| **`src/`** | Setup (`setup.R`), config (`config.R`), data helpers (`data.R`). |
| **`data/`** | Training data (`train.csv`). |
| **`data/raw/`** | Test data: grader places `test.csv` here. |
| **`models/`** | Saved artifact: list with fitted workflow and cap (`final_model.rds`). |
| **Makefile** | `make train`, `make evaluate`. |

## Scripts

- **`01_model_fit.R`** — Loads `data/train.csv`, splits 80% train / 20% validation, tunes Lasso (5-fold CV), reports validation MSE on capped scale, refits on full train, saves `models/final_model.rds` (contains fit and cap).
- **`02_evaluate.R`** — Loads the saved model and cap, reads `data/raw/test.csv`, predicts, and prints only the test MSE to stdout (capped scale).

---

## Running the pipeline

From the project root:

- **`make train`** — Train Lasso and save the model. Packages are installed automatically if missing (see `src/setup.R`).
- **`make evaluate`** — Load the model, read `data/raw/test.csv`, and print only the test MSE, e.g. `MSE: 12345.67`.

To run a single script in R, set the working directory to the project root and `source("scripts/01_model_fit.R")` (or the desired script).

---

## Modeling choices

- **Target:** `log(shares)` to stabilize variance; predictions are back-transformed with `exp()` before computing MSE.
- **Features:** Drop `url` (no signal) and `timedelta` (not available at prediction time). NZV predictors removed in the recipe; numeric predictors standardized.
- **Model:** Lasso (penalty tuned by 5-fold CV). Single final model for submission.

---

## Reproducibility

To get the same results as the author:

1. **R version** — Use R 4.4.x or 4.5.x (script tested with 4.4+).
2. **Random seed** — All randomness is controlled by `SEED <- 42L` in `src/config.R`: train/validation split, and 5-fold CV folds. Tuning uses `control_grid(seed = SEED)`.
3. **Data** — Use the same `data/train.csv`. The grader uses the same `data/raw/test.csv` for evaluation.
4. **R packages (recommended: renv)**  
   - From the project root in R:  
     `install.packages("renv"); renv::init(); renv::snapshot()`  
     Then commit `renv.lock` and `renv/`. Anyone who clones the repo runs:  
     `renv::restore()`  
     then `make train` (and `make evaluate` when test data is present).  
   - Without renv: install **tidyverse**, **tidymodels**, and **glmnet**. Results may differ slightly if package versions differ.

---

## Environment

R 4.4.x (tidyverse, tidymodels, glmnet). Run from project root so `src/` and `data/` paths resolve.

---
## AI Usage
- AI through Cursor was used to create a blueprint according to the assignment README file and then used to help refine that code for model selection. I asked it to run the different models and it was helpful in determining which model provided the lowest MSE. I told it what I needed and let it do the heavy-lifting.
