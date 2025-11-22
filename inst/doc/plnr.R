## ----collapse=FALSE-----------------------------------------------------------
library(plnr)
library(ggplot2)
library(data.table)

# Create a new plan
p <- Plan$new()

# Add data
p$add_data(
  name = "deaths",
  direct = data.table(deaths=1:4, year=2001:2004)
)

# Add argsets for different years
p$add_argset(
  name = "fig_1_2002",
  year_max = 2002
)

p$add_argset(
  name = "fig_1_2003",
  year_max = 2003
)

# Define analysis function
fn_fig_1 <- function(data, argset) {
  plot_data <- data$deaths[year <= argset$year_max]
  
  ggplot(plot_data, aes(x=year, y=deaths)) +
    geom_line() +
    geom_point(size=3) +
    labs(title = glue::glue("Deaths from 2001 until {argset$year_max}"))
}

# Apply function to all argsets
p$apply_action_fn_to_all_argsets(fn_name = "fn_fig_1")

# Run analyses
p$run_one("fig_1_2002")

## ----collapse=FALSE-----------------------------------------------------------
# Access data directly
p$get_data()

# Access specific argset
p$get_argset("fig_1_2002")

# Access analysis by name or index
p$get_analysis(1)

# Use is_run_directly() for development
fn_analysis <- function(data, argset) {
  if(plnr::is_run_directly()) {
    data <- p$get_data()
    argset <- p$get_argset("fig_1_2002")
  }
  
  # function continues here
}

## ----collapse=FALSE-----------------------------------------------------------
# Using fn_name (recommended)
p$add_analysis(
  name = "fig_1_2002",
  fn_name = "fn_fig_1",
  year_max = 2002
)

# Using fn (for function factories)
p$add_analysis(
  name = "fig_1_2003",
  fn = fn_fig_1,
  year_max = 2003
)

## ----collapse=FALSE-----------------------------------------------------------
# Create two plans with same data
p1 <- Plan$new()
p1$add_data(direct = data.table(deaths=1:4, year=2001:2004), name = "deaths")
p1$add_data(direct = data.table(deaths=1:4, year=2001:2004), name = "deaths2")

p2 <- Plan$new()
p2$add_data(direct = data.table(deaths=1:4, year=2001:2004), name = "deaths")
p2$add_data(direct = data.table(deaths=1:4, year=2001:2004), name = "deaths2")

# Same data has same hash
identical(p1$get_data()$hash$current_elements, p2$get_data()$hash$current_elements)

# Different data has different hash
p1$add_data(direct = data.table(deaths=1:5, year=2001:2005), name = "deaths3")
p1$get_data()$hash$current_elements

