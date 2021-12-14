
#' @param x List of outputs from `create_expi()`.
vis_exp <- function(x,
                    hrvar){

  # Long format data frame -----------------------------------------------

  long_data <-
    x[["cs"]] %>% # component summary
    select(-EXPI) %>% # Drop
    pivot_longer(cols = starts_with("EXPI_"),
                 names_to = "EXP",
                 values_to = "values")

  # Data frame with only EXPI and HR attributes ---------------------------

  expi_results <-
    x[["kcs"]] %>%
    select(!!sym(hrvar), EXPI)

  # Data frame with rect specifications -----------------------------------

  bar_data_1 <-
    long_data %>%
    group_by(!!sym(hrvar)) %>%
    summarise(
      x_max = max(values, na.rm = TRUE),
      x_min = min(values, na.rm = TRUE),
      med = median(values, na.rm = TRUE)
    ) %>%
    mutate(
      id = 1:nrow(.),
      y_min = id - 0.4,
      y_max = id + 0.4
    ) %>%
    left_join(expi_results, by = hrvar)

  ## grouped by EXP
  ## no EXPI joined up
  bar_data_2 <-
    long_data %>%
    group_by(EXP) %>%
    summarise(
      x_max = max(values, na.rm = TRUE),
      x_min = min(values, na.rm = TRUE),
      med = median(values, na.rm = TRUE)
    ) %>%
    order_exp() %>%
    mutate(
      id = 1:nrow(.),
      y_min = id - 0.4,
      y_max = id + 0.4
    )

  ## Clean names
  bar_data_2b <-
    bar_data_2 %>%
    add_component() %>%
    clean_exp() # %>%
    # mutate(EXP = paste(Component, "-", EXP))



  # Long table joined up with rect specifications ------------------------

  pre_plot_df_1 <-
    long_data %>%
    left_join(bar_data_1, by = hrvar) %>%
    add_component() %>%
    mutate(EXP = gsub(pattern = "EXPI_", replacement = "", x = EXP),
           EXP = camel_clean(EXP)
    ) %>%
    group_by(!!sym(hrvar)) %>%
    mutate(text = case_when(
      values == max(values) ~ "top",
      values == min(values) ~ "bottom",
      TRUE ~ ""))

  pre_plot_df_2 <-
    long_data %>%
    left_join(bar_data_2, by = "EXP") %>%
    add_component()

  # Segments ------------------------------------------------------------

  segment_df_1 <-
    pre_plot_df_1 %>%
    group_by(id) %>%
    summarise(
      x_med = first(EXPI),
      y_min = first(y_min),
      y_max = first(y_max)
    )

  segment_df_2 <-
    pre_plot_df_2 %>%
    group_by(id) %>%
    summarise(
      seg_x_med = first(med),
      seg_y_min = first(y_min),
      seg_y_max = first(y_max)
    )

  pre_plot_df_2 <-
    pre_plot_df_2 %>%
    left_join(
      segment_df_2,
      by = "id"
    )

  # Generate plot -------------------------------------------------------

  plot_1 <-
    pre_plot_df_1 %>%
    ggplot(aes(x = values, y = id)) +
    geom_rect(
      aes(
        xmin = x_min,
        xmax = x_max,
        ymin = y_min,
        ymax = y_max
      ),
      fill = "#D9E7F7"
    ) +
    geom_segment(
      data = segment_df_1,
      aes(x = x_med,
          xend = x_med,
          y = y_min,
          yend = y_max
      ),
      colour = "red",
      size = 0.5) +
    scale_y_continuous(
      breaks = unique(bar_data_1$id),
      labels = unique(bar_data_1[[hrvar]])
    ) +
    geom_jitter(
      aes(colour = Component),
      alpha = 0.5,
      width = 0,
      height = 0.2,
      size = 1) +
    ggrepel::geom_text_repel(
      aes(
        label = ifelse(text %in% c("bottom"), EXP, "")), # only label bottom
      size = 3) +
    scale_x_continuous(
      limits = c(0, 1),
      breaks = c(0, 0.25, 0.5, 0.75, 1),
      labels = scales::percent,
      position = "top"
    ) +
    theme_wpa_basic() +
    theme(
      axis.line = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_line(color = "gray"),
      strip.placement = "outside",
      strip.background = element_blank(),
      strip.text = element_blank()
    ) +
    # geom_vline(xintercept = mean(plot_data_new$values), colour = "red") +
    labs(
      title = "Employee Experience",
      subtitle = paste("Opportunities by", hrvar),
      caption = paste("Red line indicates EXP Index.",
                      x[["date"]]),
      y = "",
      x = ""
    )

  # Plot 2 ---------------------------------------------------------------

  plot_2 <-
    pre_plot_df_2 %>%
    mutate(Component = factor(Component,
                              levels = c("Wellbeing",
                                         "Empowerment",
                                         "Connection",
                                         "Growth",
                                         "Focus",
                                         "Purpose")
    )) %>%
    ggplot(aes(x = values, y = id)) +
    geom_rect(
      aes(
        xmin = x_min,
        xmax = x_max,
        ymin = y_min,
        ymax = y_max
      ),
      fill = "#D9E7F7"
    ) +
    geom_segment(
      aes(
        x = seg_x_med,
        xend = seg_x_med,
        y = seg_y_min,
        yend = seg_y_max
      ),
      colour = "red",
      size = 0.5) +
    geom_jitter(
      aes(colour = !!sym(hrvar)),
      alpha = 0.5,
      width = 0,
      height = 0.2,
      size = 2) +
    scale_y_continuous(
      breaks = unique(bar_data_2b$id),
      labels = unique(bar_data_2b[["EXP"]])
    ) +
    theme_wpa_basic() +
    theme(
      axis.line = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.grid.minor.x = element_line(color = "gray"),
      strip.background = element_rect(
        fill = "grey60",
        colour = "grey60"
        ),
      strip.placement = "outside",
      strip.text = element_text(
        size = 8,
        colour = "#FFFFFF",
        face = "plain")
    ) +
    scale_x_continuous(
      limits = c(0, 1),
      breaks = c(0, 0.25, 0.5, 0.75, 1),
      labels = scales::percent,
      position = "top"
    ) +
    facet_grid(
      Component ~ .,
      scales = "free",
      switch = "y"
    ) +
    labs(
      title = "Employee Experience",
      subtitle = paste("Distribution by", hrvar),
      caption = x[["date"]],
      y = "",
      x = ""
    )

  # Return results --------------------------------------------------------

  list(
    "long_data" = long_data,
    "plot_1" = plot_1,
    "plot_2" = plot_2,
    "pre_plot" = pre_plot_df_2,
    "bar_data" = bar_data_2b,
    "segment" = segment_df_2
  )
}


#' Order components
order_exp <- function(x){
  x %>%
    mutate(EXP = factor(
      EXP,
      levels = c(
        "EXPI_ActiveManageWorkloads",
        "EXPI_PromoteSwitchingOff",
        "EXPI_SupportAndCoach",
        "EXPI_EmpowerEmployees",
        "EXPI_EnableBroadConnections",
        "EXPI_EncourageSmallGroupMeetings",
        "EXPI_EncourageMeetingsWithoutManager",
        "EXPI_SkipLevelExposure",
        "EXPI_ExternalCollaboration",
        "EXPI_FocusTime",
        "EXPI_DeepWork",
        "EXPI_OwnTime",
        "EXPI_MeaningfulInteractions"
      )
    )) %>%
    arrange(desc(EXP)) %>%
    mutate(EXP = as.character(EXP))
}

#' Clean EXP

clean_exp <- function(x){
  x %>%
    mutate(EXP = gsub(pattern = "EXPI_", replacement = "", x = EXP),
           EXP = camel_clean(EXP)
    )
}

#' Add Key Component
add_component <- function(x){
  x %>%
    mutate(Component = case_when(
      EXP == "EXPI_ActiveManageWorkloads" ~ "Wellbeing",
      EXP == "EXPI_DeepWork" ~ "Focus",
      EXP == "EXPI_EmpowerEmployees" ~ "Empowerment",
      EXP == "EXPI_EnableBroadConnections" ~ "Connection",
      EXP == "EXPI_EncourageSmallGroupMeetings" ~ "Connection",
      EXP == "EXPI_ExternalCollaboration" ~ "Growth",
      EXP == "EXPI_FocusTime" ~ "Focus",
      EXP == "EXPI_MeaningfulInteractions" ~ "Purpose",
      EXP == "EXPI_OwnTime" ~ "Purpose",
      EXP == "EXPI_PromoteSwitchingOff" ~ "Wellbeing",
      EXP == "EXPI_SkipLevelExposure" ~ "Growth",
      EXP == "EXPI_EncourageMeetingsWithoutManager" ~ "Connection",
      EXP == "EXPI_SupportAndCoach" ~ "Empowerment",
    )) %>%
    mutate(Component = factor(Component,
                              levels = c("Wellbeing",
                                         "Empowerment",
                                         "Connection",
                                         "Growth",
                                         "Focus",
                                         "Purpose")
    ))
}
