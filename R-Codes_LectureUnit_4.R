################################################
# Data Science for Business - Lecture 4
################################################

################
# Mall Case
################

# Import the dataset
# Go to File/Open File/mall.rds
# The file is now stored in RStudio with the name "mall"

# See the dataset
View(mall)

# Get the descriptive statistics of each variable
summary(mall)

# Get the names fo the variables
names(mall)

# Scatterplot
plot(mall$Competitors,mall$Sales)

# Give a title and names to the axes
plot(mall$Competitors,mall$Sales, main = "Scatterplot",xlab="Competitors",ylab="Sales per Sqf")

# Linear regression model
fit1<-lm(Sales ~ Competitors, data= mall)

summary(fit1)

# Plot line in graph
abline(fit1, col = "blue")

# Multiple linear regression model
fit2<-lm(Sales ~ Competitors + Income+, data= mall)

summary(fit2)

# Plot residuals
plot(fit2$fitted.values, fit2$residuals, main = "Scatterplot",ylab="Residuals",xlab="Predicted Values")

# Confidence interval of the coefficients (Default is 95%)
confint(fit2)

# Confidence interval with 99% Significance Level
confint(fit2,level=0.99)


# Attention: Now let's calculate a confidence interval for the ESTIMATED VALUE OF Y
# First, create a new "mini dataset" with the values of X you want to predict:
new.dat <- data.frame(Income=50, Competitors=3)

# Second, make a prediction using your model and the new "mini dataset".
# Using thew command "confidence" we will get a confidence interval for the prediction:
predict(fit2, newdata = new.dat, interval = 'confidence',level = 0.95)

# Using thew command 'predict' we will get a prediction interval for the prediction:
predict(fit2, newdata = new.dat, interval = 'predict',level = 0.95)

new.dat <- data.frame(Income=500, Competitors=30)


################
# Subprime Case
################

# Import the dataset
# Go to File/Open File/subprime.rds
# The file is now stored in RStudio with the name "subprime"

# See the dataset
View(subprime)

# Get the descriptive statistics of each variable
summary(subprime)

# Get the names fo the variables
names(subprime)

# Linear regression model
# Attention: Here we only write the names of the variables and indicate trhe dataset separately. 
# This will later allow us to make estimations in an easier manner.
fit1<-lm(APR~LTV+FICO+Income+Homevalue, data=subprime)

summary(fit1)

# Plot residuals
plot(fit1$fitted.values, fit1$residuals, main = "Scatterplot",ylab="Residuals",xlab="Predicted Values")

# Confidence interval of the coefficients (Default is 95%)
confint(fit1)

# Confidence interval with 99% Significance Level
confint(fit1,level=0.99)

# New linear regression model
fit2<-lm(APR~LTV+FICO, data=subprime)

summary(fit2)



################
# Managers Case
################

# Import the dataset
# Go to File/Open File/managers.rds
# The file is now stored in RStudio with the name "managers"

# See the dataset
View(managers)

# Get the descriptive statistics of each variable
summary(managers)

# Get the names of the variables
names(managers)

# Linear regression model
# Attention: Here we only write the names of the variables and indicate trhe dataset separately. 
# This will later allow us to make estimations in an easier manner.
fit1<-lm(Salary~YoE+Group, data=managers)

summary(fit1)

# New linear regression model
fit2<-lm(Salary~YoE+Group+Groupxyears, data=managers)

summary(fit2)

# Plot residuals
plot(fit1$fitted.values, fit1$residuals, main = "Scatterplot",ylab="Residuals",xlab="Predicted Values")

# Attention: Now let's calculate a confidence interval for the ESTIMATED VALUE OF Y
# First, create a new "mini dataset" with the values of X you want to precit:
new.dat <- data.frame(YoE=10,Group=0, Groupxyears=0)

# Using thew command 'predict' we will get a prediction interval for the prediction:
predict(fit2, newdata = new.dat, interval = 'confidence',level = 0.95)

# Now, create a new "mini dataset" with the values of X you want to precit:
new.dat <- data.frame(YoE=10,Group=1, Groupxyears=10)

# Using thew command 'predict' we will get a prediction interval for the prediction:
predict(fit2, newdata = new.dat, interval = 'predict',level = 0.95)
