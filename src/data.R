# ------------------------------------------------------------------------------
# Data helpers. Source after setup.R (config). Uses PATH_TRAIN, PATH_TEST, CAP_QUANTILE.
# ------------------------------------------------------------------------------

#' Prepare data for modeling: cap shares, log-transform, drop url/timedelta/shares.
#'
#' Single place for the shared prep so train and evaluate stay in sync.
#' Drops url and timedelta if present (any_of); caps shares at cap, takes log, drops shares.
#'
#' @param dat Data frame with columns including shares (and optionally url, timedelta).
#' @param cap Numeric; shares are capped at this value before log-transform.
#' @return Data frame with log_shares and all other columns except url, timedelta, shares.
prep_with_cap <- function(dat, cap) {
  dat %>%
    select(-any_of(c("url", "timedelta"))) %>%
    mutate(log_shares = log(pmin(shares, cap))) %>%
    select(-shares)
}
