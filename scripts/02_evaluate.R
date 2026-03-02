# ------------------------------------------------------------------------------
# 02_evaluate.R — Load fitted model, predict on test set, print only test MSE (capped scale).
# Grader runs: make evaluate. Run from project root: Rscript scripts/02_evaluate.R
# ------------------------------------------------------------------------------

source(file.path("src", "setup.R"))
source(file.path("src", "data.R"))

obj <- readRDS(file.path(DIR_FITS, "final_model.rds"))
if (!is.list(obj) || is.null(obj$fit) || is.null(obj$cap)) stop("final_model.rds must contain list(fit = ..., cap = ...)")
final_fit <- obj$fit
cap <- obj$cap

test_raw <- read_csv(PATH_TEST, show_col_types = FALSE)
test_data <- prep_with_cap(test_raw, cap)
actual_capped <- pmin(test_raw$shares, cap)

# Predict (model was trained on log(capped shares)); back-transform
pred_log <- predict(final_fit, new_data = test_data)$.pred
pred_shares <- exp(pred_log)

# Test MSE on same capped scale as training (assignment: print only this)
mse <- mean((actual_capped - pred_shares)^2)
cat(sprintf("MSE: %.2f\n", mse))
