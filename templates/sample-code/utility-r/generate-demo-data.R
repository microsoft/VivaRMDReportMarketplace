# Local synthetic fixtures. Source this file to use the generators without writes.
generate_top_performers <- function(seed = 20260916L) {
  RNGkind("Mersenne-Twister", "Inversion", "Rejection")
  set.seed(seed)
  n <- 200L
  latent <- rnorm(n)
  rating <- as.integer(cut(latent + rnorm(n, sd = 0.8),
                          breaks = c(-Inf, -1, -0.3, 0.4, 1.2, Inf)))
  person <- rep(seq_len(n), each = 8L)
  data.frame(
    PersonId = sprintf("SYNTH_RF_%04d", person),
    Internal_network_size = rpois(length(person), 35 * exp(0.15 * latent[person])),
    Collaboration_hours = round(pmax(0, 12 + latent[person] +
                                       rnorm(length(person), sd = 3)), 2),
    weekend_collaboration_hours = round(rexp(length(person), rate = 2), 2),
    After_hours_call_hours = round(rexp(length(person), rate = 3), 2),
    performance = rating[person]
  )
}

# Allocate integer tenths of credits from the SAME person/window weekly totals.
# Task preferences are newly invented, not fitted to the previous task CSV.
generate_credit_tasks <- function(consumption, seed = 20260917L) {
  stopifnot(all(c("PersonId", "MetricDate", "Copilot_credits_consumed") %in% names(consumption)),
            !anyNA(consumption[c("PersonId", "MetricDate", "Copilot_credits_consumed")]),
            !anyDuplicated(consumption[c("PersonId", "MetricDate")]),
            all(is.finite(consumption$Copilot_credits_consumed)),
            all(consumption$Copilot_credits_consumed >= 0))
  RNGkind("Mersenne-Twister", "Inversion", "Rejection")
  set.seed(seed)
  dates <- as.Date(consumption$MetricDate)
  stopifnot(!anyNA(dates))
  totals <- aggregate(Copilot_credits_consumed ~ PersonId, consumption, sum)
  totals <- totals[order(totals$PersonId), ]
  units <- totals$Copilot_credits_consumed * 10
  if (any(abs(units - round(units)) > 1e-7)) {
    stop("This synthetic fixture generator expects credits measured in tenths.")
  }
  tasks <- c("Write or debug code", "Meeting workflow", "Email workflow",
             "Communication workflow", "Document and comment", "Analysis and research",
             "General assistance", "Specialised workflow")
  do.call(rbind, lapply(seq_len(nrow(totals)), function(i) {
    data.frame(
      PersonId = totals$PersonId[i], TaskType = tasks,
      credits = as.vector(rmultinom(1, round(units[i]), rexp(length(tasks)) + 0.2)) / 10,
      PeriodStart = format(min(dates), "%Y-%m-%d"),
      PeriodEnd = format(max(dates) + 6L, "%Y-%m-%d")
    )
  }))
}

write_demo_data <- function(data_dir) {
  weekly <- read.csv(file.path(data_dir, "consumption", "consumption-query",
                              "consumption-weekly.csv"), stringsAsFactors = FALSE)
  write.csv(generate_top_performers(),
            file.path(data_dir, "Top_Performers_Dataset_v2.csv"),
            row.names = FALSE, fileEncoding = "UTF-8")
  write.csv(generate_credit_tasks(weekly),
            file.path(data_dir, "consumption", "consumption-query",
                      "consumption-task-types.csv"),
            row.names = FALSE, fileEncoding = "UTF-8")
}

if (sys.nframe() == 0L) {
  script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
  write_demo_data(file.path(dirname(normalizePath(script)), "_data"))
}
