# Run with Rscript from any directory. No writes, package installs or framework.
args <- commandArgs(trailingOnly = TRUE)
stopifnot(all(args %in% "--usage-only"))
usage_only <- "--usage-only" %in% args
script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
test_dir <- dirname(normalizePath(script))
repo_root <- normalizePath(file.path(test_dir, "..", ".."))
topic_file <- function(topic, file) file.path(repo_root, "templates", topic, file)
topics <- list(
  collaboration = "collaboration-by-time-of-day",
  consumption = "copilot-consumption",
  usage = "copilot-usage-segments",
  networks = "custom-networks",
  causal = "causal-analysis",
  github = "github-developer-experience",
  information_value = "information-value",
  meeting = "meeting-engagement-drivers",
  chisq = "pairwise-chi-square",
  rf = "top-performers-random-forest"
)
file_for <- function(topic, file) topic_file(topics[[topic]], file)
setwd(repo_root)
suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(ggplot2)
  library(scales)
})

chunks <- function(file) {
  lines <- readLines(file, warn = FALSE)
  starts <- grep("^```\\{r([ ,}]|$)", lines)
  lapply(starts, function(start) {
    end <- start + which(lines[-seq_len(start)] == "```")[1L]
    list(header = lines[start], code = paste(lines[seq.int(start + 1L, end - 1L)],
                                            collapse = "\n"))
  })
}
chunk_code <- function(file, pattern) {
  blocks <- chunks(file)
  found <- vapply(blocks, function(b) grepl(pattern, b$header) ||
                    grepl(pattern, b$code, fixed = TRUE), logical(1))
  stopifnot(sum(found) == 1L)
  blocks[[which(found)]]$code
}
run_chunk <- function(file, pattern, env) {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(dirname(normalizePath(file)))
  old <- knitr::knit_global()
  on.exit(knitr::knit_global(old), add = TRUE)
  knitr::knit_global(env)
  invisible(eval(parse(text = chunk_code(file, pattern)), env))
}
eval_chunks <- function(file, env) {
  old_wd <- getwd()
  on.exit(setwd(old_wd), add = TRUE)
  setwd(dirname(normalizePath(file)))
  for (block in chunks(file)) {
    if (!grepl("eval=FALSE", block$header, fixed = TRUE))
      invisible(eval(parse(text = block$code), env))
  }
}
must_fail <- function(expr) {
  stopifnot(inherits(tryCatch({force(expr); NULL}, error = identity), "error"))
}
results <- list()
check <- function(id, expr) {
  if (usage_only && id != "F-13") return(invisible(NULL))
  attached <- search()
  on.exit({
    for (package in setdiff(search(), attached)) {
      if (startsWith(package, "package:")) detach(package, character.only = TRUE)
    }
  })
  error <- tryCatch({force(expr); NULL}, error = identity)
  results[[id]] <<- if (is.null(error)) "PASS" else paste("FAIL:", conditionMessage(error))
  cat(id, results[[id]], "\n")
}
new_env <- function() new.env(parent = globalenv())

check("PARSE", {
  n_chunks <- 0L
  rmd_files <- c(
    file_for("collaboration", "collaboration-by-time-of-day.Rmd"),
    file_for("usage", "copilot-usage-segments-trend.Rmd"),
    file_for("consumption", "copilot-consumption-ways-of-working-simulation.Rmd"),
    file_for("networks", "custom-network-p2p.Rmd"),
    file_for("networks", "custom-network-g2g.Rmd"),
    file_for("causal", "evaluate-intervention.Rmd"),
    file_for("causal", "did-metric-scan.Rmd"),
    file_for("causal", "event-study-did.Rmd"),
    file_for("github", "github-copilot-developer-productivity-simulation.Rmd"),
    file_for("information_value", "information-value.Rmd"),
    file_for("meeting", "meeting-engagement-drivers.Rmd"),
    file_for("chisq", "pairwise_chisq.Rmd"),
    file_for("rf", "top-performers-rf.Rmd")
  )
  for (file in rmd_files) {
    for (block in chunks(file)) {
      parse(text = block$code)
      n_chunks <- n_chunks + 1L
    }
  }
  for (file in c(
    file_for("consumption", "consumption-contracts.R"),
    file_for("consumption", "generate-demo-data.R"),
    file_for("github", "github-developer-experience-helpers.R"),
    file_for("github", "render-github-developer-experience.R"),
    file_for("rf", "generate-demo-data.R")
  )) parse(file)
  cat("Parsed all", n_chunks, "R chunks, including eval=FALSE, and all R helpers/tests.\n")
})

check("F-01", {
  env <- new_env()
  helper <- parse(file_for("github", "github-developer-experience-helpers.R"))
  fun <- Filter(function(x) is.call(x) && identical(x[[1]], as.name("<-")) &&
                  identical(x[[2]], as.name("interval_data")), as.list(helper))
  stopifnot(length(fun) == 1L)
  eval(fun[[1]], env)
  env$baseline_start <- as.Date("2026-01-04")
  env$MIN_GROUP_N <- 10L
  env$metric_labels <- c(Meeting_hours = "Meetings")
  data <- tibble(PersonId = sprintf("TEST%03d", 1:40),
                 Team = rep(c("Team A", "Team B"), each = 20),
                 Joint = rep(c("Both", "Neither"), each = 20),
                 Meeting_hours = seq_len(40))
  stopifnot(setequal(env$interval_data(data, "Meeting_hours", "Team")$Group,
                     c("Team A", "Team B")),
            setequal(env$interval_data(data, "Meeting_hours", "Joint")$Group,
                     c("Both", "Neither")))
})

check("F-02", {
  file <- file_for("chisq", "pairwise_chisq.Rmd")
  env <- new_env()
  eval_chunks(file, env)
  stopifnot(all(env$results_df$n <= n_distinct(env$sample_data_merged$PersonId)))
  original <- env$results_df
  env$sample_data_merged <- bind_rows(env$sample_data_merged, env$sample_data_merged)
  run_chunk(file, "person-snapshot", env)
  run_chunk(file, "pairwise-tests", env)
  stopifnot(identical(original, env$results_df))
  changed <- env$sample_data_merged[1L, ]
  changed$Teams <- "Changed team"
  env$sample_data_merged <- bind_rows(env$sample_data_merged, changed)
  must_fail(run_chunk(file, "person-snapshot", env))
  env$person_categories <- tibble(A = c(rep("a", 9), "b"),
                                  B = rep(c("x", "y"), 5), C = "only")
  env$cat_vars <- c("A", "B", "C")
  run_chunk(file, "pairwise-tests", env)
  stopifnot(grepl("simulated", env$results_df$method[1]),
            all(is.na(env$results_df$p[2:3])))
})

did_env <- new_env()
check("F-03", {
  file <- file_for("causal", "did-metric-scan.Rmd")
  for (part in c("setup", "analysis-config", "simulate", "event-time", "scan"))
    run_chunk(file, paste0("^```\\{r ", part, "[,}]"), did_env)
  did_env$panel_es$Emails_sent <- 10 + 2 * did_env$panel_es$post
  stopifnot(abs(did_env$run_did("Emails_sent")$estimate) < 1e-8)
  did_env$panel_es$Emails_sent <- 10 + 2 * did_env$panel_es$post +
    1.25 * did_env$panel_es$treat_post
  stopifnot(abs(did_env$run_did("Emails_sent")$estimate - 1.25) < 1e-8)
})

check("F-04", {
  env <- new_env()
  env$model_df <- tibble(duration_min = c(90, 120),
                         chats_per_att = c(45, 60), emails_per_att = c(45, 60))
  run_chunk(file_for("meeting", "meeting-engagement-drivers.Rmd"), "dose <-", env)
  stopifnot(nrow(env$dose) == 1L, env$dose$msgs_per_att == 105,
            abs(env$dose$msgs_per_att_permin - 1) < 1e-12)
})

rf_env <- new_env()
check("F-05", {
  file <- file_for("rf", "top-performers-rf.Rmd")
  for (part in c("setup", "load-data", "preparation", "person-split"))
    run_chunk(file, paste0("^```\\{r ", part, "[,}]"), rf_env)
  stopifnot(!anyDuplicated(unlist(rf_env$partition)),
            nrow(rf_env$person_data) == n_distinct(rf_env$raw_data$PersonId),
            nrow(rf_env$development_df) + length(rf_env$test_ids) == nrow(rf_env$person_data))
  makeActiveBinding("test_df", function(value) stop("Test data accessed during tuning!"), rf_env)
  rf_env$test_open <- FALSE
  rf_env$test_prediction_calls <- 0L
  rf_env$predict <- function(object, newdata, ...) {
    if (rf_env$test_open && identical(newdata, rf_env$test_df))
      rf_env$test_prediction_calls <- rf_env$test_prediction_calls + 1L
    stats::predict(object, newdata = newdata, ...)
  }
  for (part in c("tuning", "selected-model"))
    run_chunk(file, paste0("^```\\{r ", part, "[,}]"), rf_env)
  rm("test_df", envir = rf_env)
  rf_env$test_open <- TRUE
  run_chunk(file, "final-evaluation", rf_env)
  stopifnot(rf_env$test_prediction_calls == 1L,
            is.finite(rf_env$test_auc), all(is.finite(rf_env$tuning_results$validation_auc)))
  small <- tibble(PersonId = paste0("RARE", 1:6), perform_cat = factor(rep(0:1, each = 3)))
  parts <- rf_env$split_people(small)
  stopifnot(all(lengths(parts) == 2L), !anyDuplicated(unlist(parts)))
  must_fail(rf_env$split_people(small[-1, ]))
  # Reversed discrimination is not silently reoriented into a good AUC.
  stopifnot(rf_env$auc_score(factor(c(0, 0, 1, 1)), c(1, 1, 0, 0)) == 0)
})

check("F-06", {
  rm(list = intersect(c("EFFECTS", "grid", "persons"), ls(did_env)), envir = did_env)
  run_chunk(file_for("causal", "did-metric-scan.Rmd"), "^```\\{r scan[,}]", did_env)
  stopifnot(setequal(did_env$results$metric, did_env$METRICS))
  env <- new_env()
  for (part in c("setup", "analysis-config", "simulate"))
    run_chunk(file_for("causal", "event-study-did.Rmd"), paste0("^```\\{r ", part, "[,}]"), env)
  rm(list = intersect(c("TREATMENT_EFFECT", "persons", "week_shock"), ls(env)), envir = env)
  for (part in c("event-time", "twfe", "event-study", "composite"))
    run_chunk(file_for("causal", "event-study-did.Rmd"), paste0("^```\\{r ", part, "[,}]"), env)
  stopifnot(is.finite(env$did_beta),
            setequal(env$panel_es$MetricDate[env$panel_es$treated_grp == 1],
                     env$panel_es$MetricDate[env$panel_es$treated_grp == 0]))
  cat("Calendar support:", n_distinct(env$control_weeks$MetricDate), "weeks in both groups.\n")
})

cons_env <- new_env()
check("F-07", {
  consumption_rmd <- file_for("consumption", "copilot-consumption-ways-of-working-simulation.Rmd")
  run_chunk(consumption_rmd, "setup", cons_env)
  p <- cons_env$person_base
  insufficient <- p$ReasoningProfile == "Insufficient token volume"
  stopifnot(sum(insufficient) > 0,
            all(p$ConsumptionProfile[insufficient] == "Insufficient token volume"))
  run_chunk(consumption_rmd,
            "^```\\{r reasoning-profile[,}]", cons_env)
  stopifnot(sum(cons_env$profile_summary$People) == sum(p$positive_consumer & !insufficient),
            nrow(p) == nrow(cons_env$people))
})

check("F-08", {
  source(file_for("consumption", "generate-demo-data.R"), local = TRUE)
  source(file_for("consumption", "consumption-contracts.R"), local = TRUE)
  weekly <- read.csv(file_for("consumption", "_data/consumption/consumption-query/consumption-weekly.csv"))
  tasks <- read.csv(file_for("consumption", "_data/consumption/consumption-query/consumption-task-types.csv"))
  totals <- validate_task_credits(weekly, tasks)
  stopifnot(isTRUE(all.equal(tasks, generate_credit_tasks(weekly))),
            identical(generate_credit_tasks(weekly), generate_credit_tasks(weekly)))
  bad <- tasks
  bad$credits[1] <- bad$credits[1] + 1
  must_fail(validate_task_credits(weekly, bad))
  bad <- tasks
  bad$PeriodEnd[1] <- "2026-01-01"
  must_fail(validate_task_credits(weekly, bad))
  must_fail(validate_task_credits(weekly, tasks[-1, ]))
  must_fail(validate_task_credits(weekly, rbind(tasks, tasks[1, ])))
  cat("Weekly/task credits:", sum(totals$WeeklyCredits), sum(totals$TaskCredits), "\n")
  run_chunk(consumption_rmd, "task-mix", cons_env)
  check_totals <- cons_env$task_mix |> group_by(CreditBand) |>
    summarise(share = sum(Share), credits = sum(Credits), total = first(TotalCredits))
  stopifnot(nrow(check_totals) == 2L, all(abs(check_totals$share - 1) < 1e-12),
            all(abs(check_totals$credits - check_totals$total) < 1e-8))
})

check("F-09", {
  source(file_for("consumption", "consumption-contracts.R"), local = TRUE)
  boundary <- tibble(Segment = c("A", "A", "B", "B"), People = c(80, 2, 20, 30))
  stopifnot(nrow(disclose_breakdown(boundary, 10)) == 0L)
  boundary$People[2] <- 0
  stopifnot(nrow(disclose_breakdown(boundary, 10)) == 4L)
  boundary$People[2] <- 10
  stopifnot(nrow(disclose_breakdown(boundary, 10)) == 4L)
  run_chunk(consumption_rmd, "segment-credit", cons_env)
  stopifnot(nrow(cons_env$segment_credit) == 0L)
  # A zero-credit contributor cannot make a two-person positive task cell safe.
  cons_env$credit_tasks <- tibble(
    PersonId = paste0("SMALL", c(1:30, 1:8)),
    TaskType = rep(c("Common", "Rare"), c(28, 10)),
    credits = c(rep(1, 30), rep(0, 8))
  )
  cons_env$person_base <- tibble(PersonId = paste0("SMALL", 1:30),
                                CreditBand = "High credit", total_credits = 1)
  run_chunk(consumption_rmd, "task-mix", cons_env)
  stopifnot(nrow(cons_env$task_mix) == 0L)
})

check("F-10", {
  text <- paste(readLines(file_for("rf", "top-performers-rf.Rmd")), collapse = "\n")
  stopifnot(!is.null(rf_env$rf), !is.null(rf_env$selected),
            !grepl("668 correct|0\\.57%|29 correct|2 out of 670", text),
            grepl("`r rf\\$ntree`", text), grepl("rf\\$err.rate", text),
            rf_env$rf$ntree == rf_env$selected$ntree,
            sum(rf_env$rf$confusion[, c("0", "1")]) == nrow(rf_env$development_df))
})

check("H-01", {
  source(file_for("rf", "generate-demo-data.R"), local = TRUE)
  fixture <- read.csv(file_for("rf", "_data/Top_Performers_Dataset_v2.csv"))
  stopifnot(all(grepl("^SYNTH_RF_[0-9]{4}$", fixture$PersonId)),
            identical(generate_top_performers(), generate_top_performers()),
            isTRUE(all.equal(fixture, generate_top_performers())))
})

check("H-02", {
  for (file in c(
    file_for("causal", "did-metric-scan.Rmd"),
    file_for("causal", "event-study-did.Rmd"),
    file_for("causal", "evaluate-intervention.Rmd")
  )) {
    text <- paste(readLines(file), collapse = " ")
    stopifnot(grepl("educational", text, ignore.case = TRUE),
              grepl("not a supported|not supported|not a.*supported|not a real-data",
                    text, ignore.case = TRUE),
              !grepl("runs unchanged|continue unchanged|then work unchanged|stays the same", text))
  }
})

check("F-13", {
  file <- file_for("usage", "copilot-usage-segments-trend.Rmd")
  expected_cols <- c(
    "Copilot_actions_taken_in_Teams",
    "Copilot_actions_taken_in_Copilot_chat__work_",
    "Copilot_actions_taken_in_Excel",
    "Copilot_actions_taken_in_Outlook",
    "Copilot_actions_taken_in_Powerpoint",
    "Copilot_actions_taken_in_Word"
  )
  sample <- vivainsights::pq_data
  stopifnot(all(expected_cols %in% names(sample)))
  load_input <- function(input) {
    env <- new_env()
    env$pq_data <- input
    env$data <- function(...) invisible(NULL)
    run_chunk(file, "^```\\{r load[,}]", env)
    env
  }
  reject <- function(input, columns, message) {
    error <- tryCatch({load_input(input); NULL}, error = identity)
    stopifnot(inherits(error, "error"),
              grepl(message, conditionMessage(error), fixed = TRUE),
              grepl("coverage", conditionMessage(error), fixed = TRUE),
              all(vapply(columns, function(column) {
                grepl(column, conditionMessage(error), fixed = TRUE)
              }, logical(1))))
  }

  for (column in expected_cols) {
    reject(sample[setdiff(names(sample), column)], column, "Missing required")
    for (value in list(NA_real_, NaN, Inf, -Inf, -1, "unknown")) {
      bad <- sample
      bad[[column]][1L] <- value
      reject(bad, column, "must be numeric, finite, non-missing and non-negative")
    }
  }
  reject(sample[setdiff(names(sample), expected_cols)], expected_cols, "Missing required")
  bad <- sample
  bad[expected_cols] <- NA_real_
  reject(bad, expected_cols, "must be numeric, finite, non-missing and non-negative")

  valid <- load_input(sample)
  stopifnot(identical(valid$app_cols, expected_cols),
            identical(valid$pq$Total_Copilot_actions_taken, rowSums(sample[expected_cols])))
  run_chunk(file, "^```\\{r segments[,}]", valid)
  run_chunk(file, "^```\\{r avg-trend[,}]", valid)
  stopifnot(nrow(valid$seg) == nrow(sample),
            !anyNA(valid$seg$UsageSegments_12w),
            all(is.finite(valid$actions_trend$mean_actions)))

  zeros <- sample
  zeros[expected_cols] <- 0
  valid <- load_input(zeros)
  stopifnot(all(valid$pq$Total_Copilot_actions_taken == 0))
  run_chunk(file, "^```\\{r segments[,}]", valid)
  run_chunk(file, "^```\\{r avg-trend[,}]", valid)
  stopifnot(nrow(valid$seg) == nrow(zeros),
            all(valid$seg$UsageSegments_12w == "Non-user"),
            all(valid$actions_trend$mean_actions == 0))

  fractional <- sample
  fractional[expected_cols] <- 0.5
  stopifnot(all(load_input(fractional)$pq$Total_Copilot_actions_taken == 3))
  overflow <- sample
  overflow[expected_cols] <- .Machine$double.xmax
  must_fail(load_input(overflow))
  cat("Rejected each/all missing metrics, NA/NaN/Inf/-Inf/negative/non-numeric counts;",
      "preserved sample totals and legitimate zero activity for", nrow(zeros), "person-weeks.\n")
})

cat("\nRegression summary\n")
print(unlist(results))
if (any(!vapply(results, identical, logical(1), "PASS"))) quit(status = 1L)
