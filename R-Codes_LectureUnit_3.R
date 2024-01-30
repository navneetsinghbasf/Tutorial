################################################
# Data Science for Business - Lecture 3  
################################################

################
# Diamonds Case
################

# Import the dataset
# Go to File/Open File/diamonds.rds
# The file is now stored in RStudio with the name "diamonds"

# See the dataset
View(diamonds)

# Get the descriptive statistics of each variable
summary(diamonds)

# Get the names fo the variables
names(diamonds)

# Scatterplot of Price and Weight
plot(diamonds$Weight,diamonds$Price)

# Give a title and names to the axes
plot(diamonds$Weight,diamonds$Price, main = "Scatterplot",xlab="Weight",ylab="Price")

# Linear regression model
fit1<-lm(diamonds$Price ~ diamonds$Weight)

summary(fit1)

# Plot line in graph
abline(fit1, col = "blue")

# Plot residuals
plot( fit1$fitted.values, fit1$residuals, main = "Residual plot",ylab="Residuals",xlab="Predicted Values")



################
# Leasing Case
################


# Import the dataset
# Go to File/Open File/lease.rds
# The file is now stored in RStudio with the name "lease"

# See the dataset
View(lease)

# Get the descriptive statistics of each variable
summary(lease)

# Get the names fo the variables
names(lease)

# Give a title and names to the axes
plot(lease$Age,lease$Price, main = "Scatterplot",xlab="Age",ylab="Price")

# Linear regression model
fit2<-lm(lease$Price~lease$Age)

summary(fit2)

# Plot line in graph
abline(fit2, col = "blue")

# Plot residuals
plot(fit2$fitted.values, fit2$residuals, main = "Residual Plot",ylab="Residuals",xlab="Predicted Values")




################
# CAPM Case
################

# Import the dataset
# Go to File/Open File/capm.rds
# The file is now stored in RStudio with the name "capm"

# See the dataset
View(capm)

# Get the descriptive statistics of each variable
summary(capm)

# Get the names fo the variables
names(capm)

# Give a title and names to the axes
plot(capm$marketchange,capm$bhchange, main = "Scatterplot",xlab="% Market Change",ylab="% BH Change")

# Linear regression model
fit1<-lm(capm$bhchange ~ capm$marketchange)

summary(fit1)

# Plot line in graph
abline(fit1, col = "red")

# Plot residuals
plot(fit1$fitted.values, fit1$residuals, main = "Residual Plot",ylab="Residuals",xlab="Predicted Values")

# Confidence interval of the coefficients (Default is 95%)
confint(fit1)

# Confidence interval with 99% Significance Level
confint(fit1,level=0.99)

confint(fit1,level=0.8)

#####################################
# Gas Station / Traffic Case
#####################################

# Import the dataset
# Go to File/Open File/traffic.rds
# The file is now stored in RStudio with the name "traffic"

# See the dataset
View(traffic)

# Get the descriptive statistics of each variable
summary(traffic)

# Get the names fo the variables
names(traffic)

# Scatterplot of Price and Weight
plot(traffic$drivebys,traffic$sales)

# Give a title and names to the axes
plot(traffic$drivebys,traffic$sales, main = "Scatterplot",xlab="Traffic in 000",ylab="Sales in 000 Gallons")

# Linear regression model
# Attention: Here we only write the names of the variables and indicate trhe dataset separately. 
# This will later allow us to make estimations in an easier manner.
fit2<-lm(sales~drivebys, data=traffic)

summary(fit2)

qt(0.975,78)
qt(0.025,78)

# Plot line in graph
abline(fit2, col = "blue")

# Plot residuals
plot(fit2$fitted.values, fit2$residuals, main = "Residual Plot",ylab="Residuals",xlab="Predicted Values")

# Confidence interval of the coefficients (Default is 95%)
confint(fit2)

# Confidence interval with 99% Significance Level
confint(fit2,level=0.99)

# Attention: Now let's calculate a confidence interval for the ESTIMATED VALUE OF Y
# First, create a new "mini dataset" with the values of X you want to predict:
new.dat <- data.frame(drivebys=40)

# Second, make a prediction using your model and the new "mini dataset".
# Using thew command "confidence" we will get a confidence interval for the prediction:
predict(fit2, newdata = new.dat, interval = 'confidence',level = 0.95)

# Using thew command 'predict' we will get a prediction interval for the prediction:
predict(fit2, newdata = new.dat, interval = 'predict',level = 0.95)





