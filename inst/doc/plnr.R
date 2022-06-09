## ---- collapse=FALSE----------------------------------------------------------
library(ggplot2)
library(data.table)

# We begin by defining a new plan
p <- plnr::Plan$new()

# We add sources of data
# We can add data directly
p$add_data(
  name = "deaths",
  direct = data.table(deaths=1:4, year=2001:2004)
)

# We can add data functions that return data
p$add_data(
  name = "ok",
  fn = function() {
    3
  }
)

# We can then add a simple analysis that returns a figure.
# Because this is a single-analysis plan, we begin by adding the argsets.

# We add the first argset to the plan
p$add_argset(
  name = "fig_1_2002",
  year_max = 2002
)

# And another argset
p$add_argset(
  name = "fig_1_2003",
  year_max = 2003
)

# And another argset
# (don't need to provide a name if you refer to it via index)
p$add_argset(
  year_max = 2004
)

# Create an analysis function
# (takes two arguments -- data and argset)
fn_fig_1 <- function(data, argset){
  plot_data <- data$deaths[year<= argset$year_max]
  
  q <- ggplot(plot_data, aes(x=year, y=deaths))
  q <- q + geom_line()
  q <- q + geom_point(size=3)
  q <- q + labs(title = glue::glue("Deaths from 2001 until {argset$year_max}"))
  q
}

# Apply the analysis function to all argsets
p$apply_action_fn_to_all_argsets(fn_name = "fn_fig_1")

# How many analyses have we created?
p$x_length()

# Examine the argsets that are available
p$get_argsets_as_dt()

# When debugging and developing code, we have a number of
# convenience functions that let us directly access the
# data and argsets.

# We can directly access the data:
p$get_data()

# We can access the argset by index (i.e. first argset):
p$get_argset(1)

# We can also access the argset by name:
p$get_argset("fig_1_2002")

# We can acess the analysis (function + argset) by both index and name:
p$get_analysis(1)

# We recommend using plnr::is_run_directly() to hide
# the first two lines of the analysis function that directly 
# extracts the needed data and argset for one of your analyses.
# This allows for simple debugging and code development
# (the programmer would manually run the first two lines
# of code and then run line-by-line inside the function)
fn_analysis <- function(data, argset){
  if(plnr::is_run_directly()){
    data <- p$get_data()
    argset <- p$get_argset("fig_1_2002")
  }
  
  # function continues here
}

# We can run the analysis for each argset (by index and name):
p$run_one("fig_1_2002")
p$run_one("fig_1_2003")
p$run_one(3)

## ---- collapse=FALSE----------------------------------------------------------
library(ggplot2)
library(data.table)

# We begin by defining a new plan and adding data
p <- plnr::Plan$new()
p$add_data(direct = data.table(deaths=1:4, year=2001:2004), name = "deaths")

# We can then add the analysis with `fn_name`
p$add_analysis(
  name = "fig_1_2002",
  fn_name = "fn_fig_1",
  year_max = 2002
)

# Or we can add the analysis with `fn_name`
p$add_analysis(
  name = "fig_1_2003",
  fn = fn_fig_1,
  year_max = 2003
)

p$run_one("fig_1_2002")
p$run_one("fig_1_2003")

## ---- collapse=FALSE----------------------------------------------------------
library(data.table)

# We begin by defining a new plan and adding data
p1 <- plnr::Plan$new()
p1$add_data(direct = data.table(deaths=1:4, year=2001:2004), name = "deaths")
p1$add_data(direct = data.table(deaths=1:4, year=2001:2004), name = "deaths2")
p1$add_data(direct = data.table(deaths=1:5, year=2001:2005), name = "deaths3")

# The hash for 'deaths' and 'deaths2' is the same.
# The hash is different for 'deaths3' (different data).
p1$get_data()$hash$current_elements

# We begin by defining a new plan and adding data
p2 <- plnr::Plan$new()
p2$add_data(direct = data.table(deaths=1:4, year=2001:2004), name = "deaths")
p2$add_data(direct = data.table(deaths=1:4, year=2001:2004), name = "deaths2")

# The hashes for p1 'deaths', p1 'deaths2', p2 'deaths', and p2 'deaths2'
# are all identical, because the content within each of the datasets is the same.
p2$get_data()$hash$current_elements

# The hash for the entire named list is different for p1 vs p2
# because p1 has 3 datasets while p2 only has 2.
p1$get_data()$hash$current
p2$get_data()$hash$current

