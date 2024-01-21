###########################################
### Data Manipulation in R: Data Management
### Instructor: Leonie Gehrmann
###########################################

###########################################
### Tidyverse and tibbles
## tidyverse
# = opinionated collection of R packages designed for data science
# all packages share an underlying design philosophy, grammar, and data structures
# install.packages("tidyverse")
library(tidyverse)
# core packages: ggplot2, tibble, tidyr, readr, purrr, dplyr, stringr, forcats
# https://www.tidyverse.org/

# learn more about the power of the tidyverse with the book R for Data Science 
# (https://r4ds.had.co.nz/)

## tibbles
# tidyverse version of a data frame
age <- c(24, 47, 31, 18)
gender <- c("male", "male", "female", "female")
color <- c("blue", "red", "blue", "green")
car <- c(TRUE, FALSE, TRUE, FALSE)
mydata <- tibble(age, color, gender, car)
mydata

# convert an existing data frame to tibble using as_tibble( )
# convert an existing tibble to a data frame using as.data.frame( )
# variable types: integers (int), doubles/real numbers (dbl), character vectors/strings (chr), 
# date-times (dttm), logical (lgl), factors (fctr), or dates (date)

# options for viewing the data
View(mydata)
str(mydata)
glimpse(mydata)

# subsetting
mydata["age"] # returns a tibble of the variable age (4 rows, 1 column)
mydata$age # returns a vector of the variable age
mydata[["age"]] # returns a vector of the variable age
mydata[1] # subset using the position

###########################################
### Loading files and tidy data (readr, tidyr)
## reading files into R using readr to create a tibble
# generic/text files using read_delim(file, delim = "")
# tab-separated files using read_tsv()
# comma-separated files using read_csv(), semi-colon-separated files using read_csv2()
# further arguments:
# col_names = FALSE or col_names = c("first column name", "second column name", ...)
# skip = n will skip the first n lines while reading the data
# n_max = n to only read n records from the data

# readr uses heuristic that automatically determines the type of each variable column
# by looking at the first 1000 rows 
# can override this using argument col_types = cols(x = col_double(), y = col_logical(),...)
# to manually specify the type of each column

# problems() to get a tibble containing information on all of the failures of a code 

## save files using write_csv() or write_tsv()

## reading data frames from other statistical software into R using the haven package 
# install.packages("haven")
library(haven)
# SPSS files (.sav, .por) using read_spss(), read_por() and read_sav()
# Stata files (.dta) using read_dta() and read_stata()
# SAS files (.sas7bdat, .sas7bcat) using read_sas()

## reading data frames from Excel into R using the readxl package
# install.packages("readxl")
library(readxl)
# read_xls(), read_xlsx(), or read_excel() for both .xls and .xlsx

## example: load the sales data set into R using the readr function read_csv()
sales <- read_csv("sales-data.csv")
sales
# only first 10 rows printed
problems(sales) # no problems occur when reading the data

## tidy data
# 3 interrelated rules:
# each variable has its own column
# each observation has its own row
# each value has its own cell

# symptoms of messy data:
# values (not variables) in column headers
# variables stored in both rows and columns
# multiple variables stored in a single column
# single observational unit stored in multiple tables
# multiple types of observational unit stored in the same table

## using tidyr to tidy and reshape data
# going from wide to long data using gather() / pivot_longer()
# mydata_wide extends existing information on 4 fictional people
# with data on average net monthly income for 3 last years (2018-2020)
mydata_wide <- read_csv("mydata_wide.csv")
mydata_wide
# mydata_wide is in wide format (columns are not variables but values)
gather(mydata_wide, key = "year", value = "income", `2018`, `2019`, `2020`)
pivot_longer(mydata_wide, cols = c(`2018`, `2019`, `2020`), 
             names_to = "year", values_to = "income")

# going from long to wide data using spread() / pivot_wider()
# mydata_new further extends this information with monthly expenditures
mydata_long <- read_csv("mydata_long.csv")
mydata_long
# mydata_long is in long format (an observation is scattered across rows)
spread(mydata_long, key = "type", value = "amount")
pivot_wider(mydata_long, names_from = "type", values_from = "amount")

# separate a single column into multiple ones
name <- c("Max Mustermann", "John Doe", "Jane Doe", "Erika Mustermann")
mydata_sep <- tibble(mydata, name)
mydata_sep
separate(mydata_sep, col = name, sep = " ", into = c("firstname", "lastname"))
# further argument: convert = TRUE to allow R to change type of new column
# exemplary data frame with the license plate and brand of three cars
brand <- c("VW", "BMW", "Mercedes-Benz")
plates <- c("KANY2465", "HDRJ3859", "MAKQ7364")
car_data <- tibble(brand, plates)
car_data
# use a vector of integers indicating the positions at which to split values of a column
car_data_sep <- separate(car_data, col = plates, sep = c(2, 4), 
                         into = c("city", "letters", "numbers"))
car_data_sep
# positive numbers start counting from the left
# negative numbers start counting from the right
separate(car_data, col = plates, sep = c(-6,-4), into = c("city", "letters", "numbers"))

# unite multiple columns into a single one
unite(car_data_sep, city, letters, numbers, col = "license", sep = "-", )

# drop_na(data, columns) to remove observations with missing values in the specified column(s)

###########################################
### Joining datasets (dplyr)
## relational data
# = relationships between many different tables more important than individual data sets
# key = variable that uniquely identifies observations
# relation formed through primary key (in own table) and foreign key (in other table)
# surrogate key = primary key added to table, e.g. using row_number()

## exemplary data sets on fictional students
table1 <- tibble(ID = c(83927, 83930, 83901, 83931, 83925), # student ID
                 grade = c(1.7, 3.3, 2.0, 1.0, 1.3), # current grade in course 1
                 nationality = c("German", "German", "French", "Austrian", "German"))
table2 <- tibble(ID = c(83901, 83917, 83930, 83925, 83903, 83914), # student ID
                 GPA = c(1.4, 2.1, 1.6, 1.1, 1.9, 2.2), # current grade point average
                 grade = c(3.3, 2.3, 2.0, 1.0, 1.3, 1.7), # current grade in course 2
                 interest = c("Marketing", "Finance", "Taxation", 
                              "Management", "Taxation", "Operations Management"))
table1
table2

## mutating joins
# add new variables to data frame by matching observations to another data frame
# inner join
inner_join(table1, table2, by = "ID")
# new tibble only contains students existing in both data tables
# argument by = NULL by default (uses all variables that appear in both tables)
# otherwise can specify variables to be used directly, e.g. by = "ID"
# if the column names should differ across tables: by = c("ID" = "studentID")

# outer joins
# left join, keeps structure of left data frame (x) adding information from right (y)
left_join(x = table1, y = table2, by = "ID")
# right join, keeps structure of right data frame (y) adding information from left (x)
right_join(x = table1, y = table2, by = "ID")
# full join, keep all observations
full_join(table1, table2, by = "ID")

# base R alternative (merge())
merge(x = table1, y = table2, by = "ID") # inner join
merge(x = table1, y = table2, by = "ID", all.x = TRUE) # left join
merge(x = table1, y = table2, by = "ID", all.y = TRUE) # right join
merge(x = table1, y = table2, by = "ID", all.x = TRUE, all.y = TRUE) # full join

## filtering joins
# filter observations from data frame based on observations in another data frame
# semi join keeps observations of first data frame (x) that also occur in second (y)
semi_join(x = table1, y = table2, by = "ID") # students in table1 that are also in table2
semi_join(x = table2, y = table1, by = "ID") # students in table2 that are also in table1

# anti join keeps observations of first data frame (x) that do not occur in second (y)
anti_join(x = table1, y = table2, by = "ID") # students in table1 that are not in table2
anti_join(x = table2, y = table1, by = "ID") # students in table2 that are not in table1

## ensuring smooth joins
# primary key should uniquely identify observations and there should be no missing values
# used foreign key should be primary key in another table (can check e.g. using anti_join)

###########################################
### Strings and regular expressions (stringr)
## regular expressions
# = sequence of characters used to define a search pattern
?regex # for documentation of patterns supported in base R and stringr
# use backslash to escape special characters and metacharacters
# common special characters: \n new line, \t tab, \s whitespace (also tab and new line), 
# \d any digit, \b boundary between words
# metacharacters: \? \. \!
# . (without backslash) matches any character (except for a new line)
# character class: [xyz] matches x, y, or z; [^xyz] matches anything except x, y, or z
# anchor: ^ to match expression at the start of the string, $ to match the end
# ^term$ to match a complete string (here: term)
# string also requires backslash to escape the regular expression

example_string <- " This is to illustrate any issues that might exis4 and practice coding"

## base R 
toupper(example_string)
tolower(example_string)
sub(pattern = "4", replacement = "t", x = example_string)
# gsub() to replace all occurences of the specified string

## stringr
str_to_upper(example_string)
str_to_lower(example_string)
str_replace(string = example_string, pattern = "4", replacement = "t")
str_length(example_string) # number of characters (including white spaces)

example_string
# trim leading and trailing white spaces
str_trim(example_string)
# pad string with an additional character (.)
str_pad(string = example_string, width = 1, side = "right", pad = ".")

# split string into words (could also specify e.g. sentence or character)
words <- str_split(example_string, pattern = boundary("word")) # returns list
words
str_split(example_string, pattern = boundary("word"), simplify = TRUE) # returns matrix 
# count the number of words starting with the letter i
str_count(example_string, pattern = "\\si.")
# get the vowels used in the string
str_extract_all(example_string, pattern = "[aeiou]")
