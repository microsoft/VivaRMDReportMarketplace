# These checks validate the local demonstration contract, not real-export coverage.
validate_task_credits <- function(consumption, tasks) {
  weekly_keys <- c("PersonId", "MetricDate")
  task_keys <- c("PersonId", "TaskType", "PeriodStart", "PeriodEnd")
  stopifnot(all(c(weekly_keys, "Copilot_credits_consumed") %in% names(consumption)),
            all(c(task_keys, "credits") %in% names(tasks)),
            !anyNA(consumption[c(weekly_keys, "Copilot_credits_consumed")]),
            !anyNA(tasks[c(task_keys, "credits")]),
            !anyDuplicated(consumption[weekly_keys]),
            !anyDuplicated(tasks[task_keys]),
            all(is.finite(consumption$Copilot_credits_consumed)),
            all(is.finite(tasks$credits)),
            all(consumption$Copilot_credits_consumed >= 0), all(tasks$credits >= 0))
  dates <- as.Date(consumption$MetricDate)
  stopifnot(length(dates) > 0, !anyNA(dates))
  expected <- consumption |>
    dplyr::group_by(PersonId) |>
    dplyr::summarise(WeeklyCredits = sum(Copilot_credits_consumed), .groups = "drop") |>
    dplyr::mutate(PeriodStart = format(min(dates), "%Y-%m-%d"),
                  PeriodEnd = format(max(dates) + 6L, "%Y-%m-%d"))
  actual <- tasks |>
    dplyr::group_by(PersonId, PeriodStart, PeriodEnd) |>
    dplyr::summarise(TaskCredits = sum(credits), .groups = "drop")
  check <- dplyr::full_join(expected, actual,
                           by = c("PersonId", "PeriodStart", "PeriodEnd"),
                           relationship = "one-to-one")
  if (anyNA(check) || any(abs(check$WeeklyCredits - check$TaskCredits) > 1e-8)) {
    stop("Task credits must reconcile by person and full observation window; do not rescale inputs.")
  }
  invisible(check)
}

# Withhold the WHOLE cross-tab, not just one row/parent: known margins could
# otherwise reconstruct a suppressed cell. Zero cells do not disclose people.
disclose_breakdown <- function(data, minimum) {
  stopifnot(length(minimum) == 1L, is.finite(minimum), minimum >= 1,
            "People" %in% names(data), !anyNA(data$People),
            all(data$People >= 0))
  if (any(data$People > 0 & data$People < minimum)) return(data[FALSE, ])
  data
}
