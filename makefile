# ------------------------------------------------------------------------------
# Makefile: train model and evaluate on test set (ECN372 HW2).
# Run from project root: make train or make evaluate.
# ------------------------------------------------------------------------------

.PHONY: train evaluate

ROOT := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

# Train Lasso on data/train.csv; save fit + cap to models/final_model.rds
train:
	@mkdir -p $(ROOT)models $(ROOT)data/raw
	cd $(ROOT) && Rscript scripts/01_model_fit.R

# Load model, read data/raw/test.csv, print only test MSE
evaluate:
	cd $(ROOT) && Rscript scripts/02_evaluate.R
