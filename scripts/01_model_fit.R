# ------------------------------------------------------------------------------
# 01_model_fit.R — Train Lasso; penalty by 5-fold CV on 80% train, validation MSE on 20%.
# Refit on 100% and save fit + cap to models/final_model.rds (single file).
# Run from project root: Rscript scripts/01_model_fit.R
# ------------------------------------------------------------------------------

source(file.path("src", "setup.R"))
source(file.path("src", "data.R"))

set.seed(SEED)
dir.create(DIR_FITS, showWarnings = FALSE, recursive = TRUE)

# Load raw train and split 80% train / 20% validation (MSE on capped scale)
train_raw_full <- read_csv(PATH_TRAIN, show_col_types = FALSE) %>%
  select(-url, -timedelta) %>%
  filter(shares > 0)

cap <- quantile(train_raw_full$shares, CAP_QUANTILE, na.rm = TRUE)

n <- nrow(train_raw_full)
i_val <- sample.int(n, size = floor(VAL_FRAC * n))
i_train <- setdiff(seq_len(n), i_val)

train_part <- train_raw_full[i_train, ]
val_part <- train_raw_full[i_val, ]

train_data <- prep_with_cap(train_part, cap)
val_actual_capped <- pmin(val_part$shares, cap)
val_part_prep <- prep_with_cap(val_part, cap)

# Recipe: outcome = log_shares; standardize predictors
rec <- recipe(log_shares ~ ., data = train_data) %>%
  step_nzv(all_predictors()) %>%
  step_normalize(all_numeric_predictors())

# Lasso: 5-fold CV for penalty (control_grid(seed = ...) for reproducibility)
message("Tuning Lasso (5-fold CV on 80% train)...")
lasso_spec <- linear_reg(penalty = tune(), mixture = 1) %>%
  set_engine("glmnet") %>%
  set_mode("regression")
penalty_grid <- grid_regular(penalty(range = PENALTY_RANGE), levels = PENALTY_LEVELS)
train_cv <- vfold_cv(train_data, v = N_FOLDS)
wf_lasso <- workflow() %>% add_recipe(rec) %>% add_model(lasso_spec)
tune_lasso <- tune_grid(
  wf_lasso,
  resamples = train_cv,
  grid = penalty_grid,
  metrics = metric_set(rmse),
  control = control_grid(seed = SEED)
)
best_lasso <- select_best(tune_lasso, metric = "rmse")
fit_lasso_80 <- finalize_workflow(wf_lasso, best_lasso) %>% fit(train_data)

# Validation MSE on held-out 20% (capped scale)
val_pred <- exp(predict(fit_lasso_80, new_data = val_part_prep)$.pred)
val_mse <- mean((val_actual_capped - val_pred)^2)
message("Validation MSE: ", round(val_mse, 2))

# Refit on full training set; save fit and cap in one RDS
train_data_full <- prep_with_cap(train_raw_full, cap)
final_fit <- finalize_workflow(wf_lasso, best_lasso) %>% fit(train_data_full)

saveRDS(list(fit = final_fit, cap = cap), file.path(DIR_FITS, "final_model.rds"))
message("Fitted workflow and cap saved to ", file.path(DIR_FITS, "final_model.rds"))
message("Done.")
