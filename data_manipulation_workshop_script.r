# 2020-03

# Data manipulation in R
# This workshop focus on the basics of data manipulation
	# using the dplyr and tidyr packages

# Other data manipulation in R options are:
# 	The apply() family of functions;
# 	ave() and aggregate() functions;
# 	The data.table package.
# You may find another of these options fits your
# 	coding style better, but I find dplyr
# 	approachable for folks with non-programming backgrounds

# The workshop is more-or-less broken into 3 parts:
# 1. Reviewing functions in dplyr for basic
	# data manipulation/cleaning/munging
# 2. An intro to *reshaping* datasets using functions
	# from the tidyr package
# 3. Merging datasets using dplyr functions


# We have small practice exercises after
    # parts 1 and 2


# The common data manipulation tasks we will cover:
	# Making summary datasets by group
	# Filtering datasets
	# Selecting only some variables in a dataset
	# Adding variables to datasets
	# Sorting datasets
	# Reshaping datasets
	# Merging/joining datasets


# Getting help ----
# Most of the help on data manipulation in R
	# (including dplyr and tidyr)
	# I use is from stack overflow
	# http://stackoverflow.com/questions/tagged/r
    # but also see the RStudio community
    # https://community.rstudio.com/
# Both packages are relatively young and so
	# there are still things that do/will change
# However, the basic functions
	# we will be covering have been stable
# The introductory vignettes for the packages are periodically updated 
	# and are good resources on the basics
	# https://cran.r-project.org/web/packages/dplyr/vignettes/dplyr.html
    # https://cran.r-project.org/web/packages/tidyr/vignettes/tidy-data.html
# Also see the RStudio cheat sheets:
    # https://www.rstudio.com/resources/cheatsheets/

# The packages ----
# The current versions of the packages we'll be working with are
	# dplyr 0.8.3 and tidyr 1.0.2

# check if your version is up to date using packageVersion()
packageVersion("dplyr")
packageVersion("tidyr")

# If one of these is not up-to-date, re-install
# You can install via code such as install.packages("tidyr") or
	# use the Install Button in the RStudio Packages pane

# Once your versions are current, load dplyr and tidyr
library(dplyr)
library(tidyr)

# We are going to be using the mtcars dataset that comes with R
	# in the first part of the workshop
# To learn more about this dataset, see the help page

?mtcars

# Let's take a look at the dataset
head(mtcars) # The first six lines
str(mtcars) # The structure of the dataset


# Part 1: Data summarizing and cleaning ----

# Calculating summaries by group ----

# I'm going to start by talking about summarising datasets
	# by grouping variables, as this is a very common
	# task that I see folks struggle with in R

# Summarising by groups (and other similar tasks) are generally referred to as 
	# "split-apply-combine" tasks in R and can be done in dplyr
	# as well as with the tools I listed at the beginning of the workshop

# Grouping a dataset ----
# In dplyr, the key to such split-apply-combine tasks is *grouping*
	# where we define which categorical variable/variables
	# we want to make separate summaries for
# We make a grouped dataset using the group_by() function

# For example, if we want calculate summary statistics separately
	# for each cylinder category,
	# we need to *group by* the number of cylinders
# The first argument in group_by() is the dataset, 
	# and the second is the grouping variable
bycyl = group_by(mtcars, cyl)

# The result is a "grouped" data.frame, which you can
	# determine because the grouping variable is listed
	# when you look at the dataset
head(bycyl)

# You can also see this in the dataset structure,
	# where the object is of class "grouped_df"
str(bycyl)

# Once you have a grouped dataset, any summaries are
	# done within the defined groups

# Summaries by group ----
# For example, maybe we want to calculate
	# mean engine displacement for each cylinder category
# We can use the summarise() function for this
	# (summarize() is an alternative spelling)

# Note that throughout the first part of the workshop I am printing results
	# to the console but not assigning names
# You certainly can (and likely will want to) assign names
	# to your new object
# We'll cover this once
	# we combine some of the data manipulation steps together later today

# Like in group_by(), the first argument of summarise() is a dataset 
# We use our grouped dataset "bycyl" for this
# Then we simply define the function and variable
	# we want to use for summarizing
summarise( bycyl, mean(disp) )

# We can summarise multiple variables at once or
	# get different types of summaries by simply 
	# adding summary functions/variables with
	# commas separating each new argument

# For example, let's calculate the average engine displacement
	# and the average horsepower by each cylinder category
summarise( bycyl, mean(disp), mean(hp) )

# That's easy, but the column names leave something to be desired
# We can set those directly in summarise() 
	# when we calculate new variables
# Maybe we want mean and sd of engine displacement, 
	# with the names "mdisp" and "sdisp", respectively
summarise( bycyl, mdisp = mean(disp), sdisp = sd(disp) )

# Multiple grouping variables ----
# We can also group a dataset by multiple variables
# This is very common when we have more than one factor of interest
	# or have a nested study designs
	# (e.g., plots nested in transects nested in sites)

# Along these lines, we will next calculate summary stats 
	# for each cylinder category 
	# separately for each transmission type (am)

# To add more grouping variables, 
	# we include more variables in group_by(), separated by commas
byam.cyl = group_by(mtcars, cyl, am)

# The data summary is for the combination of groups
summarise( byam.cyl, mdisp = mean(disp) )

# Ungrouping a dataset ----
# You can see that the dataset we just created
    # is still grouped by the "cyl" variable

# When we have finished the work with groups,
    # it is safest to "ungroup" everything
# Working with a dataet you've forgotten to
    # ungroup and don't realize it can cause problems
    # down the road

# Ungrouping is done via the ungroup() function
ungroup( summarise( byam.cyl, mdisp = mean(disp) ) )
# Now the output no longer has any "Groups" listed and
    # any further work will be done on the overall dataset,
    # not on groups

# Using summarise_all()/summarise_at()/summarise_if() ----

# The dplyr package also has additional *scoped variants*
    # of the summarise() function for 
	# calculating the same summary statistics 
	# for multiple variables at once

# These scoped functions will still be available 
     # but will be superseded by `across()` in dplyr 1.0.0, 
     # which will be released in 2020.

# These functions are listed in the same help page,
	# and each has slightly different arguments
?summarise_all

# summarise_all() ----
# The summarise_all() function summarises every variable
	# in the dataset the same way
# This will work well primarily when the variables are all
	# the same type, like numeric, as in the mtcars dataset

# The second argument is the function we want to use

# Here is the mean of every variable for each cylinder group 
	# (using the "bycyl" grouped dataset)
summarise_all(bycyl, .funs = mean)

# What would happen if we had a factor variable
	# and tried to do this?
# We'll make "vs" a factor so we can see the result
bycyl$vs = factor(bycyl$vs)

summarise_all(bycyl, .funs = mean)

# summarise_at() ----

# If we only want to summarize some of the variables
	# in the dataset we can use summarise_at()

# To summarize only some of the columns in our dataset,
	# we list the columns we want the summaries 
	# as the second argument within vars()
	# prior to giving the summary function we want to use
# Here we'll ge the mean of only disp and wt
summarise_at(bycyl, .vars = vars(disp, wt), .funs = mean)

# Some of the variables in the dataset are 
	# actually categorical
# If we don't want to treat them as if they were numbers,
	# we could remove them from the summary by excluding them

# To exclude variables we can just drop them using the minus sign
# We'll see more about choosing variables when 
	# we talk about the select()
	# function in a few minutes

# Let's remove am and vs from the means summary table
summarise_at(bycyl, .vars = vars(-am, -vs), .funs = mean)

# summarise_if() ----
# Another option for summarizing only some of the variables
	# in a dataset can be done using logic
# This is called using a *predicate* function

# For example, we could summarize only the numeric columns
	# by testing each function with the is.numeric() predicate function

# The predicate function in summarise_if() comes before 
	# listing the summary functions we want
summarise_if(bycyl, .predicate = is.numeric, .funs = mean)
# In the results, one the numeric variables are summarized,
	# so "vs", which we made a factor, isn't included

# With any of the summarise_* functions,
	# we can calculate more than a single summary functions at once 
	# by including all the functions inside a list()
summarise_if( bycyl, .predicate = is.numeric, 
              .funs = list(mean, max) )

# Notice that the names of the function are appended
	# with "fn1", "fn2"
# This is a regression, and in the next version of dplyr
    # the names of the functions will be appended
# We can change what is appended within the list()
summarise_if( bycyl, .predicate = is.numeric, 
              .funs = list(mn = mean, mx = max) )


# The glimpse() function alternative to printing to the console ----
# Notice we are printing the object to the console 
	# instead of creating a new object and dplyr doesn't
	# show all possible variables of wide datasets like this
# To see all variable names we could use glimpse()
glimpse( summarise_if( bycyl, .predicate = is.numeric, 
                       .funs = list(mn = mean, mx = max) ) )


# More basic data manipulation ----
	# with filter(), select(), mutate(), and arrange()

# Let's now switch our focus now to talk about 
	# some of the other functions we can use
	# for other data cleaning/manipulation tasks

# I've seen folks leap to using loops for some of these tasks, 
	# which are useful but can also be difficult to code
        # and difficult to read
	# compared to some of the methods available to us
	# through add-on packages

# Filtering the dataset ----
# *Filtering* a dataset involves getting rid of unwanted rows
	# to create a specific subset of interest

# For example, if we wanted to just focus 
	# on automatic transmissions,
	# we could *filter out* the rows in the mtcars dataset 
	# from manual transmission cars using filter()

# Like other dplyr functions, the dataset is the first argument to filter()

# In filter(), we define what we want to keep
	# in the resulting dataset using logic
# Here we want to keep all rows when am is 0 
	# (i.e., automatic transmission cars)
	# Note the *two* equals signs for testing equality
filter(mtcars, am == 0)

# In filtering you will always be using logical operators
# This means things like == (testing for equality),
	# != (testing for inequality), > (greater than), 
	# !is.na (all values except NA), etc.
# If we wanted to filter out all weights greater than 4000 lbs (4 1000 lbs),
	# we could use less than or equal to (<=)
	# to *keep* rows only for cars with weights less than or equal to 4
filter(mtcars, wt <= 4)

# We could do the same thing, using greater than with the
	# *not* operator, "!"
# This would say we want to keep cars with weights that are NOT
	# greater than 4
filter(mtcars, !wt > 4)

# We can also filter a grouped dataset if we want to
# Maybe we'd like a dataset containing just the rows where
	# the values of weight are greater than the mean
	# within each cylinder category
filter( bycyl, wt > mean(wt) )

# And, of course, we can filter by multiple things at once
# Here, we filter to only cars that have both automatic transmissions
	# AND weigh less than or equal to 4000 lbs
filter(mtcars, am == 0, wt <= 4)

# If you need an OR, you need the vertical line "|", which is
	# found on the backslash key

# There are filter_all(), filter_at(), and filter_if() functions;
    # See the help page for examples of these

# Selecting variables ----
# *Selecting* a dataset involves getting rid of unwanted columns
	# to create a specific subset of interest

# Sometimes we might want to focus on only some of the columns of a dataset,
	# especially if our dataset is very wide 
	# but not all variables are part of our current analysis
# The select() function involves keeping only some of the columns
	# of a dataset
# We can do this by name (but also index number if needed), 
	# which makes coding easy and easy to read

# Here is a basic example, taking just the "cyl" column from the dataset
select(mtcars, cyl)

# We can take all columns between (and including) two variables 
	# using the colon, ":"
select(mtcars, cyl:vs)

# We can take just a few columns, separating columns names by commas
select(mtcars, cyl, vs)

# We can also choose columns that match certain rules 
	# using some of the special helper functions
	# that can be used within select(), 
	# such as starts_with() and contains()
# See the help page for select_helpers() for all of these special
	# functions and how to use them
# Everything we can do with select_helpers() in select()
	# can also be done in the, e.g., summarise_at() vars argument
?select_helpers

# While I'm showing you some examples that aren't very meaningful,
	# these really come in handy if you have some variables that all share
	# a common name or number, etc., that you want to pull out and focus on

# For example, we could choose only columns 
	# with names that start with "d"
# Remember that R is case sensitive, so "d" isn't the same as "D"
select( mtcars, starts_with("d") )

# Or columns with names that contain "a"
select( mtcars, contains("a") )

# We can also drop columns using the minus sign 
	# (like we saw in summarise_at() ), 
	# both with and without the special functions
select(mtcars, -gear) # drop "gear" variable
select(mtcars, -gear, -carb) # drop "gear" and "carb" variables
select( mtcars, -(am:carb) ) # drop all variables between and including "am" and "carb"
select (mtcars, -ends_with("t") ) # dropping variables that end with "t" (drat and wt)

# Again, the select helpers can be used in other dplyr functions,
	# such as in summarise_at() and mutate_at()
# Like the other verbs, there are scoped variants of select()
    # ( select_all(), select_at(), select_if() )

# Adding new columns ----
# In dplyr we use mutate() to add new variables to a dataset
# With mutate(), the new variable we create
	# will be the same length as the original dataset

# Adding new variables can be as basic as adding two variables together 
    # to make a third variable
# We'll make some nonsense variables 
	# to give you the idea of how this works

# First let's sum engine displacement and horsepower
# Like we did in summarise(), we will name the new
    # variable whatever we like, 
	# so we'll name our new variable "disp.hp"

mutate(mtcars, disp.hp = disp + hp)

# We can create multiple new variables at once using commas to separate
	# the new variables
# A handy feature of mutate() is that we can 
	# build on variables we just created
	# earlier within the mutate() call

# We'll make three new variables: 
	# the sum of "disp" and "hp", 
	# half of the new "disp.hp" variable, 
	# and the ratio of "qsec" and "wt",
mutate(mtcars, 
       disp.hp = disp + hp,
       halfdh = disp.hp/2,
       qw = qsec/wt)

# With mutate(), we can add summary variables by group to 
	# the current dataset as a new column
# For example, we can add mean horsepower for each 
	# cylinder category to the dataset 
	# if we mutate() a grouped dataset
# Each car within a category will have the same value because,
	# unlike summarise(), mutate() always creates variables 
	# that are the same length as the original dataset
mutate( bycyl, mhp = mean(hp) )

# As you can see, mutate() code looks a lot like summarise() code
# There are mutate_all()/mutate_at()/mutate_if() functions 
	# that work the same as
	# the scoped variants of the summarise() functions 
    # that we learned above

# There is also a function called transmute(), 
	# which works like mutate() except
	# it only keeps the new columns that you create 
	# instead of adding columns to the current dataset


# Sorting ----
# The last common task we might want to do is to *sort* 
	# the dataset a certain way with arrange()
# One place you might use this is when working in a time
	# series, where you want to pull the first observation
	# within each group and so you sort time within group
	# prior to the next data manipulation step

# We can sort by variables
# By default we sort in ascending order
arrange(mtcars, cyl)

# Or sort by the reverse of the variables using the minus sign, "-"
	# or the descend function desc()
arrange(mtcars, -cyl)
arrange( mtcars, desc(cyl) )

# To sort variables within groups
    # we need to sort by the grouping variable first
    # and then any other sorting variables

# The arrange() function ignores group_by()

# Here, we'll sort by wt ascending within each cylinder category
arrange(mtcars, cyl, wt)


# Doing several data manipulation steps in a row ----

# In real life, we will likely want to perform 
	# several data manipulation tasks on a single dataset,
	# combining filtering, selecting, mutating, etc.

# Let's see what this looks like with the mtcars dataset
# Here are the steps we'll take:
	# We will filter mtcars to just cars with automatic transmissions
	# We will create a new variable, the ratio of hp and disp
	# And finally we will calculate the mean of the new variable 
		# within each cylinder category

# We can do this by making a series of temporary objects, 
	# one for each step
# I'm including the extra pair of parantheses to print 
	# the output to the console
	# so we can see what this looks like as we go

# Filter to automatic transmission cars
( filtcars = filter(mtcars, am == 0) )

# Create new variable in the filtered dataset
( ratio.cars = mutate( filtcars, hd.ratio = hp/disp) )

# Group by number of cylinders
grp.ratio = group_by(ratio.cars, cyl)

# Calculate mean of the new ratio variable by cylinder category
( sum.ratio = summarise( grp.ratio, mratio = mean(hd.ratio) ) )

# Nesting functions ----
# Instead of making new objects with a separate names for each step,
	# we can "nest" the functions
# This keeps us from having to make temporary objects, but can
	# get complicated if using many functions in a row

# Here's a simple example, where we group before summarizing
# We group the mtcars dataset by cyl and am 
	# and then calculate mean disp
summarise( group_by(mtcars, cyl, am), mdisp = mean(disp) )

# The downside to nesting functions is that it is
	# fairly difficult to make the code readable
# To understand the code, we have to read the nesting "inside-out",
	# as the most nested function
	# is the first one used

# Here is the series of data manipulation tasks
	# we were just doing using function nesting
	# instead of temporary object naming
( sum.ratio = summarise( group_by( mutate( filter(mtcars, am == 0),
							    hd.ratio = hp/disp),
						  cyl),
				   mratio = mean(hd.ratio) ) )


# The pipe operator ----
# Now that you've seen some dplyr basics, 
	# it's time to introduce you to the *pipe operator*,
# The pipe operator is an important part of the dplyr package
	# but a relatively new kind of coding in R
# The pipe operator is represented by "%>%",
	# and allows us to perform a series of data manipulation steps 
	# one after another (aka "chain together")
	# in a readable way 
# The pipe operator allows us to write code 
	# that is read from left to right instead of inside-out

# The pipe operator "pipes" a dataset into a function
# This is the reason the dataset 
	# is the first argument in dplyr functions
	# because the pipe by default feeds the dataset 
	# to the first argument of a function

# You can think of the pipe operator as being pronounced "then"

# Let's see an example
# Remember when we made our grouped dataset?
# It looked like this:
bycyl = group_by(mtcars, cyl)

# Even this simple examples reads from inside-out,
	# as we have to go inside group_by() to see
	# which dataset we are grouping

# Using pipes, we could write it like this:
bycyl = mtcars %>% group_by(cyl)

# This reads from left to right
	# It says:  Take the mtcars dataset and *then* group it by cyl

# Handily, we can simply keep piping through the 
	# data manipulation steps we want to perform on a dataset 
	# in a single chain
# Stylistically, the standard is to use line breaks to separate 
	# each task as it keeps your code easy to read

# (As an aside, much like writing in English, 
	# spaces make code easier to read.
	# Don't forget spaces when writing your code, it
	# seems clunky at first but quickly becomes natural.
	# White space rationing is not in effect! :-D )

# Let's group mtcars by cyl and then calculate mean engine displacement,
	# using pipes
mtcars %>%
	group_by(cyl) %>%
	summarise( mdisp = mean(disp) )
# Again, we are reading left to right instead of inside-out
	# so we take the mtcars dataset and then
	# group that dataset by cylinder category and then
	# calculate the mean engine displacement for each group

# We can tie in filtering, mutating, selecting, summarizing, etc.
	# in our chain without making temporary objects 
	# or nesting the functions

# To show this, let's go back and redo the filtering, mutating,
	# grouping, and summarizing task
	# we did a few minutes ago on the mtcars dataset
	# using the pipe operator
mtcars %>%
	filter(am == 0) %>% # filter out the manual transmission cars
	mutate(hd.ratio = hp/disp) %>% # make new ratio variable
	group_by(cyl) %>% # group by number of cylinders
	summarise( mratio = mean(hd.ratio) ) # calculate mean hd.ratio per cylinder category

# We can assign a name to the final object, as well
sum.ratio = mtcars %>%
	filter(am == 0) %>% # filter out the manual transmission cars
	mutate(hd.ratio = hp/disp) %>% # make new ratio variable
	group_by(cyl) %>% # group by number of cylinders
	summarise(mratio = mean(hd.ratio) ) # calculate mean hd.ratio per cylinder category


# Using the pipe in non-dplyr functions ----
# The pipe operator can be used with non-dplyr functions
# If the data argument is the first argument in the function
	# this looks just like what we've already been doing

# Here's an example using head(), 
	# printing the first 10 rows of the dataset
# The data argument is the first one in head()
	# (you can go to the help page to see the order of the arguments)
mtcars %>% head(n = 10)

# If the datasets is not the first argument, 
	# you can refer to it with a dot, "."
# Here's an example wth t.test to show you what that looks like
mtcars %>% t.test(hp ~ am, data = .)

# And a more realistic example where you might be 
	# filtering the dataset before running a t test
mtcars %>% 
	filter(wt <= 4) %>% 
	t.test(hp ~ am, data = .)

# The n() function for counting rows per group ----

# Before we move on I want to talk about
    # one more function

# The dplyr function n() counts
	# up the number of rows in a group
# This is so useful when making tables of summary statistics
mtcars %>%
    group_by(cyl) %>%
    summarise( n = n(),
               mdis = mean(disp) )

# We can also use it directly in, e.g., filter() or mutate(),
    
# I sometimes use it with filter to look for mistakes or unusual
	# values in a dataset I'm trying to understand
	# such as when a group has only a single observation
# Here we'll pull out the rows for
	# any cylinder group where the number of observations
	# is less than 10

# For best practice I'll ungroup at the end of these pipe chains
mtcars %>%
    group_by(cyl) %>%
    filter(n() < 10) %>%
    ungroup()

# We can use n() in mutate() if we need an index within each group
	# in the order of the dataset
# We use select() below only so the we can see the new variable
	# when printed to the console
mtcars %>%
	group_by(cyl) %>%
	select(1:3) %>%
	mutate( index = 1:n() ) %>%
     ungroup()

# If we want to add the index based on some order,
	# we could arrange the dataset first
# Here we'll arrange by disp within cyl
mtcars %>%
	arrange(cyl, disp) %>%
	group_by(cyl) %>%
	select(1:3) %>%
	mutate( index = 1:n() ) %>%
     ungroup()

# Practicing data manipulation ----

# To make sure we fit it in, we'll take a few minutes
    # to practice some of the data manipulation functions
    # we've covered so far

# Install package babynames ----
# We'll be practicing using a dataset from the "babynames" package
    # which is not currently installed in this room
# We'll install it now by going to the "Packages" pane,
    # hitting the "Install" button and installing "babynames"
# Alternatively we could write install.packages("babynames")

# The current version of this package
    # is version 1.0.0
packageVersion("babynames")

# Once babynames is installed, we'll load it and
    # look at the help page for the "babynames" dataset
library(babynames)

?babynames

# This dataset has information on the number and proportion of
# given baby names each year from 1880-2015 for each sex (male, female)
# provided by the US Social Security Administration
# Only names with at least 5 uses are included

# There are five variables, shown below
glimpse(babynames)
head(babynames)

# Pratice problem 1 ----
# Filtering and sorting

# What name was given to the largest number of babies 
    # in the year you were born?

# How many babies were given that name in 2017?

# Practice problem 2 ----
# Filtering, grouping, summarizing, n()

# Calculate the total number of baby names 
    # for each levels of the sex variable
    # in the year you were born and in 2017.

# Hint: To use filter() with multiple values 
    # you'll need %in% instead of ==.  
    # For example, if you wanted to filter 
    # to years 1980 and 2015 you'd use 
    # year %in% c(1980, 2015) 
    # as the condition in `filter()`.

# Part 2: Reshaping datasets ----

# Now we are going to switch gears and talk about
	# *reshaping* datasets in R

# This involves changing datasets from a wide format to long format,
	# and from long format to wide format.

# We are going to be working the tidyr package
	# Which uses a language involving "pivoting"

# When we pivot datasets "long", we change them from wide format to long format,
	# so we take information stored in multiple columns and     
     # gather it all together into a single long column

# When we pivot datasets "wide", we change them from long format to wide format
	# so we take information stored in multiple rows of a single column
	# and put it into multiple columns

# This may sound confusing, but it should 
	# become clearer once we start practicing this

# When I think of reasons to reshape datasets for work in R, 
	# I think of going wide to long more often
	# than going long to wide so we'll begin with that

# We loaded tidyr at the beginning of the workshop
	# so we should be ready to go

# I'm going to create a "toy" dataset to work with
# By "toy" I mean a small dataset that doesn't involve any "real" data
# Being able to create toy datasets to try out functions is important,
	# especially when your real dataset is very large and it will
	# be difficult to troubleshoot any problems you run into
# Alternatively you can practice using function on the example datasets
	# from the package or from base R like the way
	# we used mtcars in the first part of this workshop

# I'm going to make a "time series" dataset,
	# where "individuals" were measured for some 
     # continuous response at multiple points in time
# We need a column for individuals, 
	# a column for some treatment that was applied,
	# and columns holding values of some response 
		# collected at the different times
# This dataset will only have 6 rows
# Small datasets are good for practice!

# I'm skipping going through the steps, but here is the data
# There are 6 individuals but they were given the
     # same names within each of the 2 treatments
# Not I didn't set a seed (see the help file for set.seed() ),
     # so our datasets will all have slightly different numbers

( toy1 = data.frame(indiv = rep(1:3, times = 2),
                    trt = rep( c("a", "b"), each = 3),
                    time1 = rnorm(n = 6),
                    time2 = rnorm(n = 6),
                    time3 = rnorm(n = 6) ) )

# Take note that this dataset contains 18 values
     # of quantiative info (6 rows, 3 columns of numbers)

# Wide to long ----
# If we did an analysis in R for a dataset like this
	# we wouldn't want the three time periods in different columns
# Instead we want a single column that represents time of measurement
	# and then a column with the quantitative measurements
# In short, we want to take a "wide" dataset and make it "long"

# We will "lengthen" the dataset
     # using the function pivot_longer() on our data.frame
# In pivot_longer(), the first thing we do defining the data 
	# is to choose the columns we want to be combined
     # We can use the select_helpers we used earlier for this
# Then we set the name of the new grouping column based
	# on the column names with "names_to"
# Finally we set the name of new column of
	# all the values with "values_to"
# Both column names must be done using strings,
     # meaning the variable name in quotes

toy1 %>% 
     pivot_longer(cols = time1:time3,
                  names_to = "time",
                  values_to = "measurement")

# This dataset has 18 rows and a single column of values
     # and so still contains our original 18 pieces of info

# We'd better name this object so we can use it for 
	# additional reshaping practice
# I use starts_with() this time in "cols"

toy1long = toy1 %>% 
     pivot_longer(cols = starts_with("time"),
                  names_to = "time",
                  values_to = "measurement")

# Long to wide ----

# Let's take the measurement column of our long format dataset 
	# back into the original format
	# (i.e., "widen" it)
# You might do this if you had a data set in long format
	# that needed to be in a wide format 
	# for use in a different software package

# We will use the pivot_wider() function for this
# After defining the dataset, we will use
     # a pair of arguments to choose the
     # column(s) that contain the variable that
     # will be the new columns names ("names_from")
     # and the column(s) that contain the values
     # will will fill the new columns with ("values_from")
# These are existing columns, so can be written using
     # "bare" names (i.e., without quotes)

toy1long %>%
     pivot_wider(names_from = time,
                 values_from = measurement)

# Multiple columns in "names_from"

# To take info from multiple columns for making
     # a new, wider dataset, we can pass multiple
     # names to "names_from"
# The new column names are separated by an underscore
     # by default and the names are affected
     # by the order we list the variables

toy1long %>%
     pivot_wider(names_from = c(trt, time),
                 values_from = measurement)

# With 3 rows and 6 columns of values, 
     # we still have our 18 original pieces of information

# We can the separator with "names_sep"
# We can change the names of the columns by changing
     # the order we list them
toy1long %>%
     pivot_wider(names_from = c(time, trt),
                 values_from = measurement,
                 names_sep = ".")

# Non-unique row identifiers ----
# If the rows in your dataset aren't uniquely identified,
	# you will get warning messages in pivot_wider()

# For example, if we were trying to widen a dataset that
	# only had the "trt" column but not the "indiv" column,
	# our rows wouldn't be uniquely identified

# Let's remove the "indiv" column to try this out
toy1long %>%
	select(-indiv)

# Look what happens if we try to widen this dataset
toy1long %>%
     select(-indiv) %>% 
     pivot_wider(names_from = time, 
                 values_from = measurement)

# In particular take note of the warning messages
# These give useful information about what is going on

# The output dataset looks odds because all three values
     # for each trt and time were kept and put in a list

# It is likely we want to summarize over the multiple
     # values, which we can do with the "values_fn" argument
# One of the messages was indicating this

# I'll calculate the mean of the values 
     # while widening into multiple columns

toy1long %>%
     select(-indiv) %>% 
     pivot_wider(names_from = time, 
                 values_from = measurement,
                 values_fn = list(measurement = mean) )

# Since we've summarized over some of the data,
     # we now only have 6 pieces of info instead
     # of the original 18

# Practice problem 3 ----
# Reshaping

# Let's practice reshaping before going on
    # to the last topic of the workshop

# This will be based on the result of practice problem 2
# I didn't name the final object I made, 
    # so I'll remake it here with the name
    # numbaby_76_17"
# You should do the same with your final
    # dataset from practice problem 2

numbaby_76_17 = babynames %>%
    filter( year %in% c(1976, 2017) ) %>%
    group_by(year, sex) %>%
    summarise(n = n() ) %>%
    ungroup()

numbaby_76_17

# First, reshape the dataset from practice problem 2 
    # to a wide format. 
    # Make a dataset with a separate column 
    # for each sex containing the 
    # number of baby names in a given year.


# Then reshape the dataset from practice problem 2 
    # to a different wide format. 
    # Make a dataset with a separate column 
    # for each year containing the 
    # number of baby names in a given sex


# Finally, practice putting the datast 
    # back in the original format.
    # Take the dataset that has sex as separate columns 
    # and put this back in the original format.  


# Part 3: Joining datasets ----

# We haven't talked about merging yet, 
	# and I wanted to briefly show you an example
# There is a merge() function in base R, but we will be working with
	# the join() functions from dplyr

# It isn't uncommon to have data from the same study in two different datasets,
	# because of how/when the data were collected
# As long as there are unique identifiers 
	# of the unit that was measured in each dataset,
	# we can easily join these together

# Let's make two toy datasets that reflect such a situation

# The first dataset is the counts of some organism in 
	# each plot within a site
# The second dataset contains information about 
	# some environmental variable measured at each plot
# Plots are identified by the combination of "site", and "treat"
	# (although it would be useful in real life
	# to have a "plot" variable)

set.seed(16) # If we set the seed, we will all get the same random numbers generated

# This dataset is slightly unbalanced, as site 3
	# doesn't have the "c" treatment count
( tojoin1 = data.frame(site = rep(1:3, each = 3, length.out = 8),
                       treat = rep(c("a", "b", "c"), length.out = 8),
                       count = rpois(8, 6) ) )

# This dataset is also slightly unbalanced,
	# missing the elevation measurement from
	# site 3 treatment "a"
( tojoin2 = data.frame(site = rep(1:3, length.out = 8),
                       treat = rep(c("b", "c", "a"), each = 3, length.out = 8),
                       elev = rgamma(8, 1000, 1) ) )


# Using an inner join ----

# The different types of joins are described in the documentation
?join

# Each join works with two datasets, called x and y, to be joined
# This means we can only join two datasets at a time

# The "x" refers to the first dataset given in the function and
	# the "y" refers to the second dataset

# As you can see on the help page, inner_join will
	# "return all rows from x where there are 
	# matching values in y, and all columns from x and y"

# By default, datasets are joined on variables
	# they both share (i.e., variables that have the same name)

( joined = inner_join(tojoin1, tojoin2) )

# To have clearer/more readable code, 
    # we can write out the variable names
	# we want to join on using "by"
    # This is whta I usually do
inner_join( tojoin1, tojoin2, by = c("site", "treat") )


# Notice that in the result, we have only 7 rows
# That's because an inner join only returns rows
	# that have matches in *both* datasets


# Using a left join ----

# To return all the rows in the first dataset (x),
	# regardless if there is match in the second,
	# we can use left_join()
# The left_join() will
	# "return all rows from x, and all columns from x and y. 
	# Rows in x with no match in y will have 
	# NA values in the new columns."
left_join( tojoin1, tojoin2, by = c("site", "treat") )

# Now we have all rows from "tojoin1", 
	# with NA filling in the missing value for "elev"

# Note there is a right_join() function, 
    # which we will not practice today,
    # that works much like left_join()

# Using a full join ----
# To return all rows from both datasets regardless of
	# having a match we can use full_join()
# The full_join() will
	# "return all rows and all columns from both x and y. 
	# Where there are not matching values, 
	# returns NA for the one missing."

full_join( tojoin1, tojoin2, by = c("site", "treat") )


# Matching multiple rows ----

# In the documentation, there is an additional sentence
	# describing the joins that we haven't talked about
# "If there are multiple matches between x and y, 
	# all combination of the matches are returned."

# This is an important part of joins, and
	# this behavior can be desirable

# Think about adding a variable that is measured
	# at the site level to our abundance dataset
( tojoin3 = data.frame(site = 1:3,
                       rainfall = rgamma(3, 10, 1) ) )

# Each treatment plot within a site should have
	# the same amount of rainfall,
	# which is what we get after joining by "site"
left_join(tojoin1, tojoin3, by = "site")

# However, this behavior can also lead to problems
# Look at what happens if we joined our original two datasets by
	# "site" instead of both of the variables that
	# uniquely identify the rows
# This means we will have multiple matches for each row
left_join(tojoin1, tojoin2, by = "site")

# In this case we get a dataset with many more rows than expected
# This is the sort of result that makes us realize we
	# need to think more clearly
	# about what we are trying to do and whether or not
	# we have unique identifiers


# Using anti_join() ----
# The missing value example is also an instance 
	# when anti_join() could be useful
# I find this a handy function when I'm data checking
    # For example, when I'm trying to figure out
    # which site/treat combination is missing
    # from a large dataset 
    # so I can investigate why it's missing

# An anti join will
	# "return all rows from x where there are 
	# not matching values in y, keeping just columns from x."

# In anti_join(), we only get the rows in the first dataset
    # that are *not* in the second
# Here we check for rows that we have in tojoin1
	# that are missing in tojoin2
anti_join( tojoin1, tojoin2, by = c("site", "treat") )

# If we want to check for rows in tojoin2
	# that are missing from tojoin1,
	# we switch the order we list the datasets in the function
anti_join( tojoin2, tojoin1, by = c("site", "treat") )

# anti_join() and the related semi_join() are a bit more 
	# like filters than joins


# Using joins in pipes ----
# Note that we can use the join functions via piping if we want
	# to join an dataset along with some other data manipulation steps

# It's most natural to pipe the dataset to be the first dataset in the join
tojoin1 %>% 
	anti_join( tojoin2, by = c("site", "treat") )

# But we can also pipe the dataset to be the second joining dataset using 
	# the dot placeholder, .
tojoin1 %>% 
	anti_join( tojoin2, ., by = c("site", "treat") )


# Examples of a couple more dplyr functions ----

# There are a couple of other functions that I 
    # commonly use for exploring datasets that I
    # want to show here

# It is very likely we will not get to these 
    # during the workshop, so you might run
    # through these examples on your own

# The n_distinct() function ----

# n_distinct() is a function related to n(),
    # but counts up the number of *unique values* in a variable
# This can be useful in exploring a dataset or checking for mistakes

# For example, if we know we should only have 3 values
    # for number of cylinders we could check to make sure	
    # our dataset doesn't contain more than that
    # (which would mean a typo)
mtcars %>%
    summarise( ncyl = n_distinct(cyl) )

# Or we could see how many unique mpg values in each cyl group
    # compared to the total number of rows in each group
mtcars %>%
    group_by(cyl) %>%
    summarise( nmpg = n_distinct(mpg),
               n = n() )

# The distinct() function ----

# This is a function we can use when we have duplicated values
    # on some rows for some variables
    # but we only want to work with a dataset
    # based on the unique values of that variable

# For example, above we see we have less unique values
    # of mpg per group than we have rows in each group
    # Maybe we aren't be interested in doing an analysis
    # using duplicates so we can pull out just the "distinct" ones

# We group the dataset to do this within cylinder groups
mtcars %>%
    group_by(cyl) %>%
    distinct(mpg) %>%
    ungroup()

# Notice we get 27 rows instead of the 32 original,
    # which matches what we calculated via n_distinct()

# If we want to keep the rest of the variables in the dataset,
    # we can use the ".keep_all" argument

mtcars %>%
    group_by(cyl) %>%
    distinct(mpg, .keep_all = TRUE) %>%
    ungroup()

# end workshop
