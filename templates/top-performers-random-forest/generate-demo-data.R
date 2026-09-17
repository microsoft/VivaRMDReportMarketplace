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

write_demo_data <- function(data_dir) {
  write.csv(generate_top_performers(),
            file.path(data_dir, "Top_Performers_Dataset_v2.csv"),
            row.names = FALSE, fileEncoding = "UTF-8")
}

if (sys.nframe() == 0L) {
  script <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE))
  write_demo_data(file.path(dirname(normalizePath(script)), "_data"))
}
