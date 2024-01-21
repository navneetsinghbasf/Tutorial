#####################################
### Introduction to R: Data Manipulation in R
### Instructor: Leonie Gehrmann
#####################################

#####################################
### Loading & saving files in R
## working directory:
getwd()
# can manually specify the working directory using setwd("filepath")
# or by using the drop down buttons Session > Set Working Directory > Choose Directory...
# use / to denote folders
# if your desired working directory is a subfolder of the current one you can specify 
# "~/subfolder1/subfolder2..."

# get a list of all files in your working directory using dir()
dir()

## style guide for naming objects in R and files
# objects need to start with a letter and can only consist of letters, numbers, _ and .
# try to ensure your object and file names are descriptive 
# and follow the same conventions for consistency
# snake case: separate lowercase words with _, e.g. my_data_name
# camel case: write each word (starting with the second) in uppercase, e.g. myDataName

## native R data formats
# .R files: saved code (Script)
# .RData: representations of data in your workspace in R-specific format 
# write an external representation of a R object (e.g. data frame) using save()
# create a data frame similar to the one from Session 1 
# 6 observations (people) of 4 variables:
# age, favorite color, gender, whether they own a car 
age <- c(24, 47, 31, 18, 120, -2)
color <- c("blue", "red", "blue", "green", "red", "red")
gender <- c("male", "male", "female", "female", "male", NA)
car <- c(TRUE, FALSE, TRUE, FALSE, FALSE, TRUE)
mydata <- data.frame(age, color, gender, car)
mydata
# store the data frame as a .RData file in your working directory 
# (otherwise need to specify complete filepath)
save(mydata, file = "mydata.RData") 
# remove the data frame from the workspace
rm(mydata)
# load .RData file using load()
load("mydata.RData")
# note: when loading an object, its objects (silently) overwrite any objects 
# in your workspace with the same name

## reading files into R using base R to create a data.frame
# generic/text files using read.table()
# comma-separated files using read.csv("file", header = TRUE, sep = ",", dec = ".", ...) 
# or read.csv2("file", header = TRUE, sep = ";", dec = ",", ...) 
# tab-separated files using read.delim("file", header = TRUE, sep = "\t", dec = ".") 
# or read.delim2("file", header = TRUE, sep = "\t", dec = ",") 

## reading data frames from other statistical software into R using the foreign package 
# install.packages("foreign")
library(foreign)
# SPSS files using read.spss()
# Stata files using read.dta()
# SAS files using read.ssd()

## saving csv files from R using base R 
write.csv(mydata, file = "mydata.csv", row.names = FALSE) 
# option row.names = FALSE avoids an extra unnamed column containing row labels 
# R automatically includes a header row with variable names 
# and puts quotation marks around character data
 
## .csv with exemplary sales data 
# load .csv file from your working directory into R using read.csv() 
# and assign the data frame a descriptive name
sales <- read.csv("sales-data.csv", stringsAsFactors = FALSE)
# if the desired file is not in your working directory, you must specify the file path
# by default R automatically converts character variables into factors 
# specifying stringsAsFactors = FALSE suppresses this and character variables stay as such 
class(sales)
# as expected, R stores our data set as a data.frame object

## sales data set description (fictional data on sales of an e-commerce website)
# taken from "R for Marketing Research & Analytics" by Chris Chapman & Elea McDonnell Feit 
# (http://r-marketing.r-forge.r-project.org/data/)
# look at variable names
names(sales)
# acctAge = tenure of the customer (months)
# visitsMonth = number of visits to the website in the last month
# spendToDate = customer's total lifetime spending (in $)
# spendMonth = customer's spending in the last month (in $)
# satSite = satisfaction with the website (scale 1-10)
# satQuality = satisfaction with the product quality (scale 1-10)
# satPrice = satisfaction with the prices (scale 1-10)
# satOverall = overall satisfaction (scale 1-10)
# region = US geographic region
# coupon = dummy variable indicating whether customer was sent a coupon for promoted product
# purchase = dummy variable indicating whether customer purchased the promoted product, 
# with or without coupon

## becoming familiar with the data after loading it into R
# View() invokes a spreadsheet-style data viewer in a new window
View(sales)
# 1) check if the number of rows (observations) and columns (variables) matches expectation
dim(sales)
# sales data has 835 observations of 11 variables
# 2) head() and tail() to examine the first and last rows for possible blanks/other errors
head(sales)
tail(sales)
# 3) str() gives an overview of the variable types
str(sales)
# region is a character variable,
# loaded the data set specifying that characters should not be converted to factors
# if we do wish to convert a variable to a factor, we can use as.factor() 
sales$region <- as.factor(sales$region)
str(sales)
# 4) summary() to check for unexpected values and some basic statistics (min/max,..)
summary(sales)
# 5) remove unwanted/unnecessary variables or change names
# e.g. remove the monthly spending per customer
sales$spendMonth <- NULL
# NOTE: reload the data set since we need monthly spend later
sales <- read.csv("sales-data.csv", stringsAsFactors = FALSE) 
# e.g. change the name of acctAge (the first one in the data set)
names(sales)[1] <- "tenure"

#####################################
### Descriptive Statistics 
## central tendency
mean(sales$satOverall)
median(sales$satOverall)
# calculating the mean "by hand"
sum(sales$satOverall) / nrow(sales) 

## range
# minimum
min(sales$visitsMonth) 
# maximum
max(sales$visitsMonth)
# alternative to get both minimum & maximum
range(sales$visitsMonth) 
# the distance between minimum & maximum 
diff(range(sales$visitsMonth)) 

## dispersion
# variance
var(sales$spendMonth)
# standard deviation
sd(sales$spendMonth)
sqrt(var(sales$spendMonth)) # equivalent
# calculate the variance "by hand", note that R uses the sample variance (divide by n - 1)
sum((sales$spendMonth - mean(sales$spendMonth))^2) / (nrow(sales) - 1)
# interquartile range (75% - 25% quartile)
IQR(sales$spendMonth)

## percentiles
# quantile() automatically returns 0, 25, 50, 75, 100
quantile(sales$tenure)
# can specify desired percentiles using argument probs 
quantile(sales$tenure, probs = c(0.1, 0.9))

## frequency tables for a single discrete variable 
table(sales$satOverall)
# the rating 6 was given most often (mode), remember this was also the median (mean = 5.7)
# complexity of the table increases with the number of possible values
table(sales$spendMonth)
# proportions
round(prop.table(table(sales$satOverall)), 4)
# use prop.table() to express the entries of the frequency table as proportions 
# round to 4 decimals using round()

## bivariate relationships
# frequency tables / cross tabulation
# quality satisfaction in the rows, price satisfaction in the columns
table(sales$satQuality, sales$satPrice)
# e.g. respondents rating their satisfaction with the product quality at either 9 or 10 
# also rated their satisfaction with the prices at least at 6 on the scale 
round(prop.table(table(sales$satQuality, sales$satPrice)), 2)
# the accumulation of observations along the diagonal of the table suggests 
# that the two ratings are positively related
# Pearson's correlation coefficient: metric for linear association between two variables
cor(sales$satQuality, sales$satPrice)
# the correlation between price and quantity satisfaction supports our initial belief 
# the two ratings are relatively strongly positively correlated 

#####################################
### Outliers and missing values
# for this next block we'll use the .RData file we created in the beginning of the session
load("mydata.RData")
summary(mydata)

## outliers: extreme values that lie far from other values 
# can occur naturally in our data or indicate a mistake (e.g. in measurement or data entry)
# can be so extreme they are not plausible 
# or have a value that does not make sense (e.g. negative spending)
mydata$age
# an age of 120 seems quite extreme 
# and not very plausible, maybe this was a data entry error
# an age of -2 is physically not possible
# need to think about removing the corresponding observations entirely 
# or replacing the values (e.g. with an NA)

## missing values: represented as NA in R
# could be random, but could also indicate a mistake
# math performed on a value of NA will return NA
x <- c(1, 2, 3, NA)
mean(x)
# need to specify the option na.rm = TRUE to calculate excluding the NAs
mean(x, na.rm = TRUE)
# find location of NA's using is.na(), only feasible for small data sets
is.na(mydata)
# there seems to be a NA in the sixth observation (variable: gender)
# for larger data sets should first check whether there are any NA's using any(is.na()),
any(is.na(mydata)) # TRUE means there are NA's in our data
# count the numer of NA's using sum(is.na())
sum(is.na(mydata)) # we have 1 NA in our data set 
# remove rows with NA's using na.omit() and store as new data set, 
# which has one less observation
mydatanew <- na.omit(mydata)


#####################################
### Mutating existing variables and creating new variables in base R
# for this next topic we'll return to our sales data set 
str(sales)

## mutating existing variables
# our two spending variables reflect customers' amount spent over the entire lifetime
# and in the last month in USD
# you want to share this data with an European colleague, who prefers values in EURO
# assume the exchange rate is 0.9 - 1USD translates to 0.9EURO
# mutate each spend variable by multiplying the original values with 0.9 
# and store the new values in the data set
sales$spendToDate <- sales$spendToDate*0.9 # mutate customer's lifetime spending
sales$spendMonth <- sales$spendMonth*0.9 # mutate customer's spending last month
# notice that we used the new spending data to overwrite the previous USD values
# we could have also stored the EURO values under a new variable 
# e.g. sales$spendToDateEU <- sales$spendToDate*0.9 
# and sales$spendMonthEU <- sales$spendMonth*0.9

## creating new variables
# 1) creating new variables out of mutations of existing ones
# e.g. we could add a variable to the data set 
# that calculates the mean satisfaction over site, quality & price 
sales$satMean <- (sales$satSite + sales$satQuality + sales$satPrice) / 3
# then we could compare the calculated mean satisfaction 
# with the respondent's overall satisfaction
sales$satDiff <- sales$satOverall - sales$satMean
# rows with a positive entry: respondent states a higher overall satisfaction 
# than the individual levels indicate
# rows with negative entry: respondent states a lower satisfaction 
# than the individual levels indicate
# rows with an entry of 0: overall reported satisfaction and average satisfaction coincide
# 2) creating an entirely new variable
# e.g. could add a random variable indicating what group the person will belong to
# here: 4 treatment and 1 control group 
# use gl() to create a factor with 5 levels each occurring the same number of times 
# randomize the labels using sample 
# otherwise first 167 observations would be in first group etc
sales$treatment <- sample(gl(n = 5, k = 835/5, 
                             labels = c("first", "second", "third", "fourth", "control")))

# to get a glimpse of our extended data set
head(sales)
summary(sales) # some descriptive statistics
