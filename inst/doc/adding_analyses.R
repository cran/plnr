## ---- collapse=FALSE----------------------------------------------------------
library(ggplot2)
library(data.table)
library(magrittr)

# We begin by defining a new plan
p <- plnr::Plan$new()

# Data function
data_fn <- function(){
  return(plnr::norway_covid19_cases_by_time_location)
}

# We add sources of data
# We can add data directly
p$add_data(
  name = "covid19_cases",
  fn_name = "data_fn"
)

p$get_data()

location_codes <- p$get_data()$covid19_cases$location_code %>%
  unique() %>% 
  print()

p$add_argset_from_list(
  plnr::expand_list(
    location_code = location_codes,
    granularity_time = "isoweek"
  )
)
# Examine the argsets that are available
p$get_argsets_as_dt()

# We can then add a simple analysis that returns a figure:

# To do this, we first need to create an action function
# (takes two arguments -- data and argset)
action_fn <- function(data, argset){
  if(plnr::is_run_directly()){
    data <- p$get_data()
    argset <- p$get_argset(1)
  }
  pd <- data$covid19_cases[
    location_code == argset$location_code &
    granularity_time == argset$granularity_time
  ]
  
  q <- ggplot(pd, aes(x=date, y=covid19_cases_testdate_n))
  q <- q + geom_line()
  q <- q + labs(title = argset$location_code)
  q
}

p$apply_action_fn_to_all_argsets(fn_name = "action_fn")

p$run_one(1)
q <- p$run_all()
q[[1]]
q[[2]]

## ---- collapse=FALSE----------------------------------------------------------
library(ggplot2)
library(data.table)
library(magrittr)

# We begin by defining a new plan
p <- plnr::Plan$new()

# Data function
data_fn <- function(){
  return(plnr::norway_covid19_cases_by_time_location[location_code=="norge"])
}

# We add sources of data
# We can add data directly
p$add_data(
  name = "covid19_cases",
  fn_name = "data_fn"
)

p$get_data()

p$add_argset_from_list(
  plnr::expand_list(
    variable = c("covid19_cases_testdate_n", "covid19_cases_testdate_pr100000"),
    granularity_time = c("isoweek","day")
  )
)
# Examine the argsets that are available
p$get_argsets_as_dt()

# We can then add a simple analysis that returns a figure:

# To do this, we first need to create an action function
# (takes two arguments -- data and argset)
action_fn <- function(data, argset){
  if(plnr::is_run_directly()){
    data <- p$get_data()
    argset <- p$get_argset(1)
  }
  pd <- data$covid19_cases[
    granularity_time == argset$granularity_time
  ]
  
  q <- ggplot(pd, aes_string(x="date", y=argset$variable))
  q <- q + geom_line()
  q <- q + labs(title = argset$granularity_time)
  q
}

p$apply_action_fn_to_all_argsets(fn_name = "action_fn")

p$run_one(1)
p$run_one(2)
p$run_one(3)
p$run_one(4)

## ---- collapse=FALSE----------------------------------------------------------
library(ggplot2)
library(data.table)
library(magrittr)

# We begin by defining a new plan
p <- plnr::Plan$new()

# Data function
data_fn <- function(){
  return(plnr::norway_covid19_cases_by_time_location)
}

# We add sources of data
# We can add data directly
p$add_data(
  name = "covid19_cases",
  fn_name = "data_fn"
)

p$get_data()

# Completely unique function for figure 1
p$add_analysis(
  name = "figure_1",
  fn_name = "figure_1"
)

figure_1 <- function(data, argset){
  if(plnr::is_run_directly()){
    data <- p$get_data()
    argset <- p$get_argset("figure_1")
  }
  pd <- data$covid19_cases[
    granularity_time == "isoweek"
  ]
  
  q <- ggplot(pd, aes_string(x="date", y="covid19_cases_testdate_pr100000"))
  q <- q + geom_line()
  q <- q + facet_wrap(~location_code)
  q <- q + labs(title = "Weekly covid-19 cases per 100 000 population")
  q
}

# Reusing a function for figures 2 and 3
p$add_analysis(
  name = "figure_2",
  fn_name = "plot_epicurve_by_location",
  location_code = "norge"
)

# Reusing a function for figures 2 and 3
p$add_analysis(
  name = "figure_3",
  fn_name = "plot_epicurve_by_location",
  location_code = "county03"
)

plot_epicurve_by_location <- function(data, argset){
  if(plnr::is_run_directly()){
    data <- p$get_data()
    argset <- p$get_argset("figure_2")
    argset <- p$get_argset("figure_3")
  }
  pd <- data$covid19_cases[
    granularity_time == "isoweek" & 
    location_code == argset$location_code
  ]
  
  q <- ggplot(pd, aes_string(x="date", y="covid19_cases_testdate_n"))
  q <- q + geom_line()
  q <- q + labs(title = argset$location_code)
  q
}

p$run_one("figure_1")
p$run_one("figure_2")
p$run_one("figure_3")

