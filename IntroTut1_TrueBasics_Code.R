###########################################
### Introduction to R: The True Basics of R
### Instructor: Leonie Gehrmann
###########################################

###########################################
### Finding help
# https://www.rdocumentation.org/ for help on the syntax of any function in R
# blogs, e.g. https://www.r-bloggers.com/
# forums, e.g. https://stackoverflow.com/ for help on specific problems
# many online tutorials or guides, e.g. https://stat545.com/
# general books, e.g. Hadley Wickham: R for Data Science (https://r4ds.had.co.nz/) 
# or Hadley Wickham: Advanced R (https://adv-r.hadley.nz/)
# more specific books, e.g. R for Marketing Research & Analytics 
# by Chris Chapman & Elea McDonnell Feit

###########################################
### Packages
# Comprehensive R Archive Network https://cran.r-project.org/ for community-provided 
# R packages
# install packages either using install.packages() 
# or by searching for the package in R Studio directly
# load/attach required packages at the beginning of your script using library()
# list all loaded packages
search()

# download/install cowsay package from repository or local file to use its functions
# remember that you have to remove the '#' in order to be able to install the package
# install.packages("cowsay") 
library(cowsay) 
# get the description of the package (opens the documentation in the help tab on the right)
help(package = "cowsay")
say(what = "Hello R enthusiasts!", by = "monkey")

# finding help for specific functions
?say
# browsing R for specific keywords
??frequency
# lists functions related to the keyword in the format packagename::functionname

###########################################
### Some general information on R
# R is case-sensitive
# use # to add comments to your code 
# NA indicates a missing value (not applicable), NaN stands for "not a number"
# Inf stands for an "infinite value"
# error messages indicate code could not be run by R
say(what = "Hello R enthusiasts!" by = "monkey")
# here the mistake is the missing comma between the arguments of the function

###########################################
### Basic math in R 
6 + 3    # addition
6 - 3    # subtraction
6 * 3    # multiplication
6 / 3    # division
6 ^ 2    # power
10 %% 3  # modulo: returns the remainder of the division
10 %/% 3 # integer division: removes the remainder of the division

# store data as a variable, to reuse it later using the assignment operator <-
a <- 6
b <- 3
# return what is stored as variable a
a
# can use parentheses around the assignment 
# then it happens simultaneously with the print of the variable
(c <- 5)

# use stored variables directly to calculate
a + b 
a / b
a ^ b

# assigning a new value to a variable overwrites any pre-existing variables 
# stored under the same name (without notice)
a <- 4
a + b 
# a + b = 4 + 3 = 7

# stored variables are found in the workspace (the current R working environment)
ls() # to get a list of all stored objects
# alternatively, stored variables can be found in the Environment tab in R Studio
# can remove single objects using rm()
rm(a)
# remove all objects from the current workspace
rm(list=ls())

###########################################
### Different data types
# class = property assigned to the object determining how generic functions operate with it
a <- 4
class(a) 
# get the type from R's point of view
typeof(a) 

## numeric: default data type in R
# test whether type is numeric
is.numeric(3.5) 
# turn into type numeric
as.numeric("3.5") 
as.numeric("yes")
as.numeric(TRUE) 

# integer: special type of numeric that represents natural numbers (e.g. 3)
# can specify number as an integer using L
3L
3
# don't see a difference in the output, but in the class function
class(3)
class(3L)
# integer is always numeric, but numeric is not always integer

## character: string values in R, indicated by " "
# test whether type is character
is.character("yes")
# turn into character
as.character(3.5)

## logical: either TRUE or FALSE 
# TRUE can also be represented as T or 1
# FALSE can also be represented as F or 0
# test whether type is logical
is.logical(FALSE) 
# turn into a logical, automatically sets everything that does not equal 0 to TRUE
as.logical(3.5)
as.logical(0)
# NA is also type logical
class(NA)

###########################################
### Vectors
# one-dimensional collection of data points of the same type
# two key properties: type and length, determined using typeof() or class() and length()
# single elements in R are also considered vectors
w <- 3
is.vector(w)
length(w) # w is in fact a vector of length 1

## different ways to create a vector
# 1) directly enter the elements of a vector using c()
x1 <- c(1, 2, 3)
x1
x2 <- c("red", "yellow", "blue")
x2
# 2) generate a sequence using seq()
y <- seq(from = 1, to = 3, by = 0.5)
y
# 3) replicate certain values using rep()
# in R, ":" means ranging from (similar to "-")
# in this case replicate the values from 1 to 3
z <- rep(1:3, times = 2)
z
rep(1:3, each = 2)

# return the number of elements and type of a vector
length(z)
typeof(z)

# name the elements of a vector
x1
names(x1) <- c("first", "second", "third")
x1

## vector math
# any of the basic math operations can be applied to vectors (calculate element-wise)
3 * x1
x1 + 10
# if two vectors of different lengths are involved in a calculation, 
# R automatically repeats the shorter one
# until it has the same number of elements as the longer vector
x1
z
x1 + z
# R also allows you to select specific elements from a vector 
# use [] and name the index(es) of the chosen position(s)
# important: R starts counting at position "1" (vs other languages, e.g. Python)
z[3]
z[3:5]
z[c(3,4,5)] # equivalent
# adding a minus in front of the index selects everything but that range
z[-3]

###########################################
### Factor
# type of data object used to categorize and store variables 
# can only take on a limited number of values (levels)

## different ways to create a factor
# 1) create a factor object out of an existing vector x using factor()
gender <- c("male", "female", "female", "male", "female")
fac_gen <- factor(gender)
fac_gen
# if you know the set of possible values in advance,
# it's useful to directly specify the levels e.g. to detect typos
gender1 <- c("male", "female", "mal")
(fac_gen1 <- factor(gender1, levels = c("male", "female")))
# misspelled third element is replaced by NA since its value is not a known level
# R sorts the levels alphabetically by default, 
# but you can set the order using the levels argument
factor(c("short", "tall", "tall", "short"), ordered = TRUE, levels = c("short", "tall"))

# 2) create new factor labels by repeating n labels in groups of length k using gl()
# useful for randomization 
# e.g. assigning participants in an experiment to a treatment group
gl(n = 3, k = 2, labels = c("first", "second", "third"))
sample(gl(n = 3, k = 2, labels = c("first", "second", "third")))

###########################################
### Matrix
# two-dimensional data structure where each column must have the same type and length

## different ways to create a matrix
# 1) directly specify a vector of data, the number of rows and columns,
# and how the matrix is filled using matrix()
m1 <- matrix(c(1,2,3,4,5,6), nrow = 2, ncol = 3)
m1
matrix(1:6, nrow = 2) # equivalent (results in the same matrix)
m2 <- matrix(1:6, nrow = 2, ncol = 3, byrow = TRUE)
m2
# R automatically repeats the shorter vector to fill up entire matrix,
# but returns a warning message as well
matrix(1:5, nrow = 2) 
# 2) combine a sequence of elements by row using rbind()
a <- c(1,2,3)
b <- c(4,5,6)
rbind(a,b)
# 3) combine a sequence of elements by column using cbind()
cbind(a,b)

## helpful matrix commands
# define the names of the columns and rows of a matrix
colnames(m1) <- c("first", "second", "third")
m1
rownames(m2) <- c("one", "two")
m2
# return the dimensions (rows, columns) of a matrix using dim()
dim(m1)
nrow(m1) # just number of rows
ncol(m1) # just number of columns 
# calculate the column & row sums/means using colSums()/colMeans() & rowSums()/rowMeans()
colSums(m1)
colMeans(m1)
rowSums(m2)
rowMeans(m2)

## matrix math
# any of the basic math operations can be applied to matrices (calculate element-wise)
m1
m1 * 2
m1 + 3
# matrix-specific math operations include matrix multiplication %*%,
# transposing using t() and inverting using solve()
t(m1)
# R also allows you to select a subset of a matrix using [,] 
# and naming the row & column indices of the chosen subset
# selected rows are defined first, followed by a comma and the selected columns
# if no index is chosen, all rows/colums are selected for the subset
m1[1:2,3] # first and second row, third column
m1[1,] # first row, all columns
# adding a minus in front of the index selects everything but that range
m1[-1,] # all rows except the first, all columns

###########################################
### Lists
# collection of objects of any type

# combine multiple vectors and create a list using list()
age <- c(24, 47, 31, 18)
gender <- c("male", "male", "female", "female")
mylist <- list(age, gender)
mylist

## helpful list commands
# set the names of objects in a list using names()
names(mylist) <- c("age", "gender")
mylist
# get an compact overview of the structure of a list using str()
str(mylist)
# lists are indexed using [[]] or $
# to select the first object of a list use [[1]] or list$objectname
mylist[[1]]
mylist$age
# to select the second element of the first object of a list use [[1]][2] 
# or list$objectname[2]
mylist[[1]][2]
mylist$age[2]

###########################################
### Data frame
# rectangular object consisting of columns of various data types (variables) 
# and rows with entries (observations)

# create a data frame out of a set of same length vectors using data.frame()
color <- c("blue", "red", "blue", "green")
car <- c(TRUE, FALSE, TRUE, FALSE)
mydata <- data.frame(age, color, gender, car)
# we use the age & gender vectors from before and add two new ones 
# and create a new data frame
mydata

## helpful data frame commands
# get the internal structure using str()
str(mydata)
# get basic summary statistics of each variable using summary()
summary(mydata)
# view first/last n rows using head()/tail()
head(mydata, 2) # view first 2 rows
tail(mydata, 2) # view last 2 rows
# by default R converts characters into nominal factors, 
str(mydata)
# but you can suppress this using option stringsAsFactors
mydata1 <- data.frame(age, color, gender, car, stringsAsFactors = FALSE)
str(mydata1)
# R also allows you to select a subset of a data frame using [,] 
# and naming the row & column indices of the chosen subset
# selected rows are defined first, followed by a comma and the selected columns
# if no index is chosen, all rows/columns are selected for the subset
mydata
mydata[1,] # the first row (selecting specific observations)
# adding a minus in front of the index selects everything but that range
mydata[-1,] # everything except the first row
# alternatively, you can select certain columns (variables) using [[]] or $
mydata[,2]
mydata[[2]] # second column (variable)
mydata$color # this is the most useful notation for analysis,
# since you clearly name the variable you're interested in