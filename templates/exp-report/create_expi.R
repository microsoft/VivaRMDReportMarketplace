#' @title Create Employee Experience Index from Person Query grouped by Day
#'
#' @param data Data frame containing a Standard Person Query grouped by Day.
#' @param hrvar String containing the grouping HR variable.
#' @param mingroup Numeric variable specifying the minimum group size.
#'
#' @details
#' Function still under development.
#' Some `data.table` syntax is used to speed up performance when running daily
#' data.
#'
create_expi <- function(data, hrvar, mingroup, return = "standard"){

  # HR lookup ---------------------------------------------------------------

  # For joining later

  hr_df <- data %>% select(PersonId, !!sym(hrvar))

  # Pass string ------------------------------------------------------------
  # Find groups which exceed the minimum group size

  pass_str <-
    data %>%
    group_by(!!sym(hrvar)) %>%
    summarise(n = n_distinct(PersonId)) %>%
    filter(n >= mingroup) %>%
    pull(!!sym(hrvar))

  # Daily metrics -----------------------------------------------------------

  # Get `QuietDays` and `DeepWorkDay` based on Daily Data
  # Convert back to the Weekly level

  daily_metrics <-
    data %>%
    mutate(DayOfWeek = lubridate::wday(Date, label = TRUE)) %>%
    mutate(DateWeek = lubridate::floor_date(Date, unit = "weeks",
                                            week_start = 7) %>%
             as.Date()) %>%

    # QuietDay = at most 2 email or IM sent on the day
    # criterion should change depending whether `IsActive` is on
    mutate(QuietDay = ifelse(Emails_sent <= 2 & Instant_messages_sent <= 2, 1, 0)) %>%

    # DeepWorkDay = Fewer than two meeting hours on the day
    mutate(DeepWorkDay = ifelse(Meeting_hours < 2, 1, 0)) %>%
    group_by(DateWeek, PersonId) %>%
    summarise(
      QuietDays = sum(QuietDay, na.rm = TRUE),
      DeepWorkDay = sum(DeepWorkDay, na.rm = TRUE),
      .groups = "drop"
    )

  # Metrics to sum up by week -----------------------------------------------
  # Sum up each day of a week to the weekly level
  metrics_to_sum <-
    c(
      "Collaboration_hours",
      "Workweek_span",
      "Meeting_hours_with_manager_1_on_1",
      "Meeting_hours_with_manager",
      "Meeting_hours",
      "Meeting_hours_for_3_to_8_attendees",
      "Meeting_hours_for_2_attendees",
      "Meeting_hours_1_on_1_with_same_level",
      "Manager_coaching_hours_1_on_1", # Optional
      "Meeting_hours_with_skip_level",
      "Collaboration_hours_external",
      "Open_2_hour_blocks",
      "Time_in_self_organized_meetings",
      "Meeting_hours_with_manager_with_3_to_8", # New
      "Meeting_hours_with_skip_level_max_8"
    )

  # Metrics summed up by week -----------------------------------------------
  # Grouped by `PersonId` and `DateWeek`

  weekly_metrics <-
    data %>%
    mutate(DateWeek = lubridate::floor_date(Date, unit = "weeks",
                                            week_start = 7) %>%
             as.Date()) %>%
    as.data.table() %>%
    .[, lapply(.SD, sum, na.rm = TRUE),
      by = c("PersonId", "DateWeek"),
      .SDcols = metrics_to_sum]

  # Metrics averaged up by week ---------------------------------------------
  # Only contains `Internal_network_size` - only one that is not sum-mable

  weekly_metrics_mean <-
    data %>%
    mutate(DateWeek = lubridate::floor_date(Date, unit = "weeks",
                                            week_start = 7) %>%
             as.Date()) %>%
    as.data.table() %>%
    .[, lapply(.SD, mean, na.rm = TRUE),
      by = c("PersonId", "DateWeek"),
      .SDcols = c("Internal_network_size")]

  # Metrics to convert to Person level --------------------------------------
  # A character vector of metrics with everything calculated so far

  metrics_to_person <-
    c(metrics_to_sum,
      "Internal_network_size",
      "QuietDays",
      "DeepWorkDay")

  # Convert Person-week level to Person level -------------------------------
  # Join the following data frames:
  #   - daily_metrics
  #   - weekly_metrics
  #   - weekly_metrics_mean


  expi_plevel <-
    daily_metrics %>%
    # Join calculations
    left_join(weekly_metrics, by = c("PersonId", "DateWeek")) %>%
    left_join(weekly_metrics_mean, by = c("PersonId", "DateWeek")) %>%
    as.data.table() %>%

    # Average by `PersonId`
    .[, lapply(.SD, mean, na.rm = TRUE),
      by = "PersonId",
      .SDcols = metrics_to_person]

    #TODO: need to replace this once custom metric is available
    # .[, Meeting_hours_cross_level :=
    #     Meeting_hours_for_2_attendees -
    #     Meeting_hours_with_manager_1_on_1 -
    #     Manager_coaching_hours_1_on_1] %>%
    # .[]


  # Calculate EXPI ----------------------------------------------------------

  expi_interim <-
    expi_plevel %>%
    as_tibble() %>%

    mutate(

      # Wellbeing: Actively Manage Workloads --------------------------------

      EXPI_ActiveManageWorkloads = ifelse(
        Collaboration_hours < 20 & Workweek_span < 45, TRUE, FALSE),


      # Wellbeing: Promote Switching Off ------------------------------------

      EXPI_PromoteSwitchingOff = ifelse(QuietDays > 2, TRUE, FALSE),

      # Empowerment: Support and Coach --------------------------------------

      EXPI_SupportAndCoach = ifelse(
        Meeting_hours_with_manager_1_on_1 * 60 >= 15, TRUE, FALSE),

      # Empowerment: Empower Employees --------------------------------------
      EXPI_EmpowerEmployees = ifelse(
        (Meeting_hours_with_manager / Meeting_hours) < 0.5, TRUE, FALSE
      ),

      # Connection: Enable broad connections --------------------------------
      EXPI_EnableBroadConnections = ifelse(
        Internal_network_size > 20, TRUE, FALSE
      ),

      # Connection: Encourage small group meetings --------------------------
      EXPI_EncourageSmallGroupMeetings = ifelse(
        Meeting_hours_for_3_to_8_attendees > 2, TRUE, FALSE),

      # Connection: Encourage small group meetings w/o manager --------------
      # At least two hours of 3-8 meetings without manager presence
      Temp_EncourageMeetingsWithoutManager = Meeting_hours_for_3_to_8_attendees - Meeting_hours_with_manager_with_3_to_8,

      EXPI_EncourageMeetingsWithoutManager = ifelse(
        Temp_EncourageMeetingsWithoutManager > 2, TRUE, FALSE
      ),

      # Growth: Promote skip-level exposure ---------------------------------
      EXPI_SkipLevelExposure = ifelse(
        Meeting_hours_with_skip_level_max_8 * 60 >= 30,
        TRUE, FALSE
      ),

      # Growth: Facilitate External Connections -----------------------------
      EXPI_ExternalCollaboration = ifelse(
        Collaboration_hours_external *60 >=15,
        TRUE, FALSE
      ),

      # Focus: Make Time Available to Focus ---------------------------------
      EXPI_FocusTime = ifelse(
        Open_2_hour_blocks >= 4, TRUE, FALSE
      ),

      # Focus: Enable Deep Work Days ----------------------------------------
      # At least one day excluding weekends with <2 of meetings
      EXPI_DeepWork = ifelse(
        DeepWorkDay >= 3, TRUE, FALSE
      ),

      # Purpose: Help employees own their time ------------------------------
      EXPI_OwnTime = ifelse(
        (Time_in_self_organized_meetings / Meeting_hours) > .25,
        TRUE, FALSE
      ),

      # Purpose: foster meaningful interactions -----------------------------
      EXPI_MeaningfulInteractions = ifelse(
        Meeting_hours_1_on_1_with_same_level * 60 >= 30,
        TRUE, FALSE
      )
    )

  # Key components ----------------------------------------------------------

  exp_kc <-
    expi_interim %>%
    mutate(EX_KPI_Wellbeing =
             select(.,
                    EXPI_ActiveManageWorkloads,
                    EXPI_PromoteSwitchingOff) %>%
             apply(1, mean, na.rm = TRUE)) %>%
    mutate(EX_KPI_Empowerment =
             select(.,
                    EXPI_SupportAndCoach,
                    EXPI_EmpowerEmployees) %>%
             apply(1, mean, na.rm = TRUE)) %>%
    mutate(EX_KPI_Connection =
             select(.,
                    EXPI_EnableBroadConnections,
                    EXPI_EncourageSmallGroupMeetings,
                    EXPI_EncourageMeetingsWithoutManager) %>%
             apply(1, mean, na.rm = TRUE)) %>%
    mutate(EX_KPI_Growth =
             select(.,
                    EXPI_SkipLevelExposure,
                    EXPI_ExternalCollaboration) %>%
             apply(1, mean, na.rm = TRUE)) %>%
    mutate(EX_KPI_Focus =
             select(.,
                    EXPI_FocusTime,
                    EXPI_DeepWork) %>%
             apply(1, mean, na.rm = TRUE)) %>%
    mutate(EX_KPI_Purpose =
             select(.,
                    EXPI_OwnTime,
                    EXPI_MeaningfulInteractions) %>%
             apply(1, mean, na.rm = TRUE)) %>%

    ## Calculate EXPI
    mutate(EXPI = select(., starts_with("EX_KPI_")) %>%
             apply(1, mean, na.rm = TRUE))

  # Component summary -------------------------------------------------------

  exp_cs <-
    exp_kc %>%
    left_join(
      hr_df,
      by = "PersonId"
    ) %>%
    filter(!!sym(hrvar) %in% pass_str) %>%
    group_by(!!sym(hrvar)) %>%
    summarise(
      across(
        .cols = c(starts_with("EXPI_"), EXPI),
        .fns = ~mean(., na.rm = TRUE)
      )
    )

  # Key component summary ---------------------------------------------------

  exp_kcs <-
    exp_kc %>%
    left_join(
      hr_df,
      by = "PersonId"
    ) %>%
    filter(!!sym(hrvar) %in% pass_str) %>%
    group_by(!!sym(hrvar)) %>%
    summarise(
      across(
        .cols = c(starts_with("EX_KPI_"), EXPI),
        .fns = ~mean(., na.rm = TRUE)
      )
    )

  # Date extract ------------------------------------------------------------

  dat_chr <- extract_date_range(data, return = "text")

  # Return output -----------------------------------------------------------

  if(return == "standard"){

    expi_interim

  } else if(return == "list"){

    list(
      "standard" = expi_interim,
      "kc" = exp_kc, # key component
      "cs" = exp_cs, # component summary
      "kcs" = exp_kcs, # key component summary
      "date" = dat_chr # date string
    )
  }


}
