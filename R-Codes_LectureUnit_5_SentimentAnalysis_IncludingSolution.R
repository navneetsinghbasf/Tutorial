#################################################################################
# Data Science for Business
# Analyzing Unstructured Data - Sentiment Analysis
#################################################################################

##### Set up ######
###################

# Install the following required packages:
install.packages("tidyverse") # contains readr, dplyr & tidytext (used throughout the exercise)
install.packages("ggpubr") # used to create ggplot2-based publication ready plots
install.packages("ggwordcloud") # used to create word clouds in ggplot
install.packages("textdata") # contains the NRC word-emotion association lexicon
install.packages("ggplot2")
library(tidyverse)
library(ggpubr)
library(ggwordcloud)
library(textdata)
library(ggplot2)



# set working directory to the desired folder
getwd() # current working directory
# setwd("INSERT FILE PATH HERE")

# load dataset containing tweets from the Mercedes Benz account
library(readr) # using the readr version is faster at reading the data set
mercedes <- read_csv("https://www.managementanalytics.education/data/TwitterData/Tweets_MercedesBenz.csv")

# Look at the dataframe
View(mercedes)
# get first few rows
head(mercedes)

##### Calculating the Engagement rate and Amplification rate of Mercedes Benz ######
###################################################################################

# Before analyzing the sentiment of tweets, we want to calculate two metrics to 
# better understand the social media reach of Mercedes Benz.

# Engagement rate = 100 * (total likes + total shares) / number followers
# We create a new variable engagement_rate that calculates this metric separately
# for each tweet in the mercedes data set. Likes are found in the variable
# favorite_count and shares in the variable retweet_count.
# Currently, the number of followers of the Mercedes Benz Twitter account is 4020136. 
# We store this as a new variable
mercedes_followers <- 4020136
# and use it to calculate the engagement rate per tweet.
mercedes$engagement_rate <- 100*(mercedes$favorite_count + mercedes$retweet_count)/mercedes_followers

# The average engagement rate of tweets from Mercedes is almost 0.001%
mean(mercedes$engagement_rate)

# Amplification rate = 100 * total shares / number followers
# We create a new variable amplification_rate that calculates this metric separately
# for each tweet in the mercedes data set.
mercedes$amplification_rate <- 100*mercedes$retweet_count/mercedes_followers

# The average amplification rate of tweets from Mercedes is almost 0.0004%
mean(mercedes$amplification_rate)


##### Data Cleaning & Pre-Processing ######
###########################################

# We see that 43 variables were imported. We want to select only variables (columns), 
# that we are interested in at the moment. The column we are most interested in is 
# 'full_text'. This column contains the actual tweets. Then we need to make the 
# data tidy, e.g. restructure it into a long format (one word per row).

library(dplyr)
library(tidytext)
# We want to restructure mercedes into a one-token-per-row format using functions
# from the dplyr and tidytext packages (both tidyverse).
tidy_tweets <- mercedes %>% # pipe in data frame 
  filter(is.na(in_reply_to_screen_name)) %>% # only include original tweets
  select(id, full_text) %>% # select variables of interest
  unnest_tokens(word,full_text) # split columns into desired format

#Check if it worked:
View(tidy_tweets)

# We want to do some more cleaning of the tweets by removing stop words 
# because these have very little value for sentiment analysis.
# The tidytext package contains English stop words from three different lexicons
# (onix, SMART, snowball) in the data frame 'stop_words'.
stop_words

# In addition, we create a dataframe that contains our own defined stopwords
# that are related to the Twitter nature of the data. In line with 'stop_words',
# this new data frame consists of 2 columns, one containing the word and one
# specifying the lexicon (twitter).
my_stop_words <- tibble( 
  word = c(
    "https",
    "t.co",
    "rt",
    "amp",
    "rstats",
    "gt"
  ),
  lexicon = "twitter"
)

# We combine the two data sets to have one containing all of the words.
all_stop_words <- stop_words %>%
  bind_rows(my_stop_words) 

# Let's see if it worked
View(all_stop_words)

# Next, we remove numbers from the tweets because they also don't 
# provide value for the sentiment analysis.
no_numbers <- tidy_tweets %>%
  filter(is.na(as.numeric(word))) # remember filter() returns those rows where the condition is true
# Note: Don’t worry about the warning message you are receiving here, the 
# as.numeric function gives a warning when it tries to turn non-number words into numbers,
# which is what we are looking to do here. 
# The warnings we receive from R should be read for meaning. They can be useful 
# clues as to why you are stuck. You can use the help function in 
# R (?as.numeric()) or google the error message if you are unsure what is going on.


# Finally, we get rid of all of the stopwords from the tweets by using anti_join(). 
# We already used this in one of the previous sessions, but if you are unsure
# about what anti_join() does you can read more about it , e.g. by calling
# the help function in the R console ?anti_join().

no_stop_words <- no_numbers %>%
  anti_join(all_stop_words, by = "word")

# Over half the tweeted words turned out to be stop words. Removing the stop words is 
# important for the later visualization and the sentiment analysis. We only want to plot 
# and analyze the ‘interesting’ tweets.

##### Sentiment Analysis ######
###############################

# One form of text analysis that is particularly interesting for 
# Twitter data is sentiment analysis. With the help of lexica we can 
# find sentiment (emotional content) for each tweeted word and then have a closer 
# look at the emotional content of the tweets.

# Let’s first have a look at the lexicon we will be using: nrc.
library(textdata)
nrc <- get_sentiments("nrc") # get specific sentiment lexicon in a tidy format

# Have a look at the dataframe by using either View(nrc) or by clicking on the 
# object in the environment on the right hand side.
View(nrc)

# Now we want to add find out the sentiment for each word in our dataframe 
# 'no_stop_words'. To do that, we can use the inner_join function, 
# which returns all the rows that have a match in the other table.

nrc_words <- no_stop_words %>% 
  inner_join(nrc, by = "word")

View(nrc_words)

##### Visualization ######
##########################

# Now that we have shaped our text data into tidy form and figured out 
# the emotional content of the tweeted words, we can plot this 
# information to find out if the general sentiment is more positive or 
# negative, which emotions prevail and how the development is over time.

pie_words <- nrc_words %>%
  group_by(sentiment) %>% # group by sentiment type
  tally %>% # counts number of rows
  arrange(desc(n)) # arrange sentiments in descending order based on frequency

# We use the ggpubr package to plot, which gives us easy-to-use functions for 
# creating and customizing ‘ggplot2’- based plots. 
# One option to visualize the emotional content of the tweets is by 
# using a pie chart.
library(ggpubr)
ggpie(pie_words, "n", label = "sentiment", fill = "sentiment", 
      color = "white", palette = "Spectral")

# Alternatively, with word clouds we can easily visualize which words were tweeted
# most frequently by the user. 
# Try to visualize the top 50 words using the ggwordcloud package.
library(ggwordcloud)

#First we count how many times each word was tweeted.
words_count<- no_stop_words %>% 
  count(word, sort = TRUE) # count number of occurrences

set.seed(42) # random seed ensures replicability of word cloud

wordcloudplot <- head(words_count, 50)%>% # select first 50 rows
  ggplot(aes(label = word, size = n, color = word, replace = TRUE)) + # start building your plot 
  geom_text_wordcloud_area() + # add wordcloud geom
  scale_size_area(max_size = 18) + # specify text size
  theme_minimal() # choose theme
wordcloudplot 










#################################################################################
# Assignment
#################################################################################

# Please load six datasets containing tweets from six luxury car brand accounts
mercedes <- read_csv("https://www.managementanalytics.education/data/TwitterData/Tweets_MercedesBenz.csv")
bmwusa <- read_csv("https://www.managementanalytics.education/data/TwitterData/Tweets_BMWUSA.csv")
landrover <- read_csv("https://www.managementanalytics.education/data/TwitterData/Tweets_LandRover.csv")
lexus <- read_csv("https://www.managementanalytics.education/data/TwitterData/Tweets_Lexus.csv")
porsche <- read_csv("https://www.managementanalytics.education/data/TwitterData/Tweets_Porsche.csv")
tesla <- read_csv("https://www.managementanalytics.education/data/TwitterData/Tweets_Tesla.csv")



#################################################################################
# Task 1:
# Please calculate for each brand the average
# a) Engagement rate
# b) Amplification rate
# using the formulas from above. 

# HINT: Please take the current number of Twitter followers for each brand for the calculations.

mercedes_followers <- 4020136
bmwusa_followers <- 246184
landrover_followers <- 915312
lexus_followers <- 1041007
porsche_followers <- 2159580
tesla_followers <- 20303884

#################################################################################
# SOLUTION

# a) Engagement rate
mercedes$engagement_rate <- 100*(mercedes$favorite_count + mercedes$retweet_count)/mercedes_followers
mean(mercedes$engagement_rate) # 0.0009826699

bmwusa$engagement_rate <- 100*(bmwusa$favorite_count + bmwusa$retweet_count)/bmwusa_followers
mean(bmwusa$engagement_rate) # 0.02134623

landrover$engagement_rate <- 100*(landrover$favorite_count + landrover$retweet_count)/landrover_followers
mean(landrover$engagement_rate) # 0.0331156

lexus$engagement_rate <- 100*(lexus$favorite_count + lexus$retweet_count)/lexus_followers
mean(lexus$engagement_rate) # 0.01267913

porsche$engagement_rate <- 100*(porsche$favorite_count + porsche$retweet_count)/porsche_followers
mean(porsche$engagement_rate) # 0.01554612

tesla$engagement_rate <- 100*(tesla$favorite_count + tesla$retweet_count)/tesla_followers
mean(tesla$engagement_rate) # 0.03098874

# b) Amplification rate
mercedes$amplification_rate <- 100*mercedes$retweet_count/mercedes_followers
mean(mercedes$amplification_rate) # 0.0003671683

bmwusa$amplification_rate <- 100*bmwusa$retweet_count/bmwusa_followers
mean(bmwusa$amplification_rate) # 0.003680039

landrover$amplification_rate <- 100*landrover$retweet_count/landrover_followers
mean(landrover$amplification_rate) # 0.007564132

lexus$amplification_rate <- 100*lexus$retweet_count/lexus_followers
mean(lexus$amplification_rate) # 0.001589423

porsche$amplification_rate <- 100*porsche$retweet_count/porsche_followers
mean(porsche$amplification_rate) # 0.003135069

tesla$amplification_rate <- 100*tesla$retweet_count/tesla_followers
mean(tesla$amplification_rate) # 0.005295516




#################################################################################
# Task 2:
# Please visually compare the number of followers of the six Twitter accounts. 
# Also, use an appropriate graph to compare the number of likes (in total), the average engagement 
# rate and the average amplification rate of the latest 3000 tweets of all six luxury car brands.

# HINT: You should end up with 4 different graphs (one for each metric to compare). The variable
# created_at provides the exact time and date of each tweet.

#################################################################################
# SOLUTION

brand <- c("BMW", "Landrover", "Lexus", "Mercedes", "Porsche", "Tesla")
follower <- c(bmwusa_followers, landrover_followers, lexus_followers, mercedes_followers, porsche_followers, tesla_followers)
likes <- c(sum(bmwusa$favorite_count), 
           sum(landrover$favorite_count), 
           sum(lexus$favorite_count), 
           sum(mercedes$favorite_count), 
           sum(porsche$favorite_count), 
           sum(tesla$favorite_count))
avg_engagement <- c(mean(bmwusa$engagement_rate),
                    mean(landrover$engagement_rate),
                    mean(lexus$engagement_rate),
                    mean(mercedes$engagement_rate),
                    mean(porsche$engagement_rate),
                    mean(tesla$engagement_rate))
avg_amplification <- c(mean(bmwusa$amplification_rate),
                       mean(landrover$amplification_rate),
                       mean(lexus$amplification_rate),
                       mean(mercedes$amplification_rate),
                       mean(porsche$amplification_rate),
                       mean(tesla$amplification_rate))
graph_data <- data.frame(brand, follower, likes, avg_engagement)

# number of followers
library(scales) # for notation on y-axis of plots
ggplot(graph_data) +
  geom_col(aes(x = brand, y = follower)) +
  scale_y_continuous(labels = label_number())

# number of likes (in total)
ggplot(graph_data) +
  geom_col(aes(x = brand, y = likes)) +
  scale_y_continuous(labels = label_number())

# average engagement rate
ggplot(graph_data) +
  geom_col(aes(x = brand, y = avg_engagement))

# average amplification rate
ggplot(graph_data) +
  geom_col(aes(x = brand, y = avg_amplification))

#################################################################################
# Task 3:
# Please conduct a sentiment analysis of the latest 3000 tweets of all six luxury car brands. 
# Compare the differences in sentiments between the six luxury car brands and relate your findings
# to the differences in their brand positioning.

# HINT: Remember to ensure the data is in a clean format (e.g. by removing stop words). 

#################################################################################
# SOLUTION

# create a list of stop words (to remove from tweets later)
my_stop_words <- tibble(word = c("https", "t.co", "rt", "amp", "rstats", "gt"),
  lexicon = "twitter")
all_stop_words <- stop_words %>%
  bind_rows(my_stop_words) 

library(textdata)
nrc <- get_sentiments("nrc") # get specific sentiment lexicon in a tidy format

# how many of the past 3000 tweets are "original" posts of the brand (vs. replies)?
sum(is.na(bmwusa$in_reply_to_screen_name))/nrow(bmwusa) # 20.4%
sum(is.na(landrover$in_reply_to_screen_name))/nrow(landrover) # 60.6%%
sum(is.na(lexus$in_reply_to_screen_name))/nrow(lexus) # 44.1%%
sum(is.na(mercedes$in_reply_to_screen_name))/nrow(mercedes) # 17.0%
sum(is.na(porsche$in_reply_to_screen_name))/nrow(porsche) # 56.7%
sum(is.na(tesla$in_reply_to_screen_name))/nrow(tesla) # 62.5%

# create function to clean and analyze the data
tweet_sentiment <- function(data){
  data %>%
    filter(is.na(in_reply_to_screen_name)) %>% # only include original tweets
    select(id, full_text) %>%
    unnest_tokens(word, full_text) %>% # split columns into desired format
    filter(is.na(as.numeric(word))) %>% # remove numbers
    anti_join(all_stop_words, by = "word") %>% # remove stop words
    inner_join(nrc, by = "word")
}

# apply to the different brands
tidy__bmwusa <- tweet_sentiment(bmwusa)
tidy__landrover <- tweet_sentiment(landrover)
tidy__lexus <- tweet_sentiment(lexus)
tidy__mercedes <- tweet_sentiment(mercedes)
tidy__porsche <- tweet_sentiment(porsche)
tidy__tesla <- tweet_sentiment(tesla)

# pie charts
library(ggpubr) # for pie chart and grid arrange 
pie_bmwusa <- tidy__bmwusa %>%
  group_by(sentiment) %>% # group by sentiment type
  tally %>% # counts number of rows
  arrange(desc(n)) %>% # arrange sentiments in descending order based on frequency
  ggpie("n", label = "sentiment", fill = "sentiment", palette = "Spectral") +
  theme(legend.position = "none")
pie_landrover <- tidy__landrover %>%
  group_by(sentiment) %>% # group by sentiment type
  tally %>% # counts number of rows
  arrange(desc(n)) %>% # arrange sentiments in descending order based on frequency
  ggpie("n", label = "sentiment", fill = "sentiment", palette = "Spectral") +
  theme(legend.position = "none")
pie_lexus <- tidy__lexus %>%
  group_by(sentiment) %>% # group by sentiment type
  tally %>% # counts number of rows
  arrange(desc(n)) %>% # arrange sentiments in descending order based on frequency
  ggpie("n", label = "sentiment", fill = "sentiment", palette = "Spectral") +
  theme(legend.position = "none")
pie_mercedes <- tidy__mercedes %>%
  group_by(sentiment) %>% # group by sentiment type
  tally %>% # counts number of rows
  arrange(desc(n)) %>% # arrange sentiments in descending order based on frequency
  ggpie("n", label = "sentiment", fill = "sentiment", palette = "Spectral") +
  theme(legend.position = "none")
pie_porsche <- tidy__porsche %>%
  group_by(sentiment) %>% # group by sentiment type
  tally %>% # counts number of rows
  arrange(desc(n)) %>% # arrange sentiments in descending order based on frequency
  ggpie("n", label = "sentiment", fill = "sentiment", palette = "Spectral") +
  theme(legend.position = "none")
pie_tesla <- tidy__tesla %>%
  group_by(sentiment) %>% # group by sentiment type
  tally %>% # counts number of rows
  arrange(desc(n)) %>% # arrange sentiments in descending order based on frequency
  ggpie("n", label = "sentiment", fill = "sentiment", palette = "Spectral") +
  theme(legend.position = "none")
# get all 6 in one graph
ggarrange(pie_bmwusa, pie_landrover, pie_lexus, pie_mercedes, pie_porsche, pie_tesla,
          labels = brand, ncol = 3, nrow = 2)

# word clouds
library(ggwordcloud)
set.seed(82346) # random seed ensures replicability of word cloud
cloud_bmwusa <- tidy__bmwusa %>% 
  count(word, sort = TRUE) %>% # count number of occurrences
  head(50) %>% # select first 50 rows
  ggplot(aes(label = word, size = n, color = word, replace = TRUE)) + # start building your plot 
  geom_text_wordcloud_area() + # add wordcloud geom
  scale_size_area(max_size = 18) + # specify text size
  theme_minimal() # choose theme
cloud_landrover <- tidy__landrover %>% 
  count(word, sort = TRUE) %>% # count number of occurrences
  head(50) %>% # select first 50 rows
  ggplot(aes(label = word, size = n, color = word, replace = TRUE)) + # start building your plot 
  geom_text_wordcloud_area() + # add wordcloud geom
  scale_size_area(max_size = 18) + # specify text size
  theme_minimal() # choose theme
cloud_lexus <- tidy__lexus %>% 
  count(word, sort = TRUE) %>% # count number of occurrences
  head(50) %>% # select first 50 rows
  ggplot(aes(label = word, size = n, color = word, replace = TRUE)) + # start building your plot 
  geom_text_wordcloud_area() + # add wordcloud geom
  scale_size_area(max_size = 18) + # specify text size
  theme_minimal() # choose theme
cloud_mercedes <- tidy__mercedes %>% 
  count(word, sort = TRUE) %>% # count number of occurrences
  head(50) %>% # select first 50 rows
  ggplot(aes(label = word, size = n, color = word, replace = TRUE)) + # start building your plot 
  geom_text_wordcloud_area() + # add wordcloud geom
  scale_size_area(max_size = 18) + # specify text size
  theme_minimal() # choose theme
cloud_porsche <- tidy__porsche %>% 
  count(word, sort = TRUE) %>% # count number of occurrences
  head(50) %>% # select first 50 rows
  ggplot(aes(label = word, size = n, color = word, replace = TRUE)) + # start building your plot 
  geom_text_wordcloud_area() + # add wordcloud geom
  scale_size_area(max_size = 18) + # specify text size
  theme_minimal() # choose theme
cloud_tesla <- tidy__tesla %>% 
  count(word, sort = TRUE) %>% # count number of occurrences
  head(50) %>% # select first 50 rows
  ggplot(aes(label = word, size = n, color = word, replace = TRUE)) + # start building your plot 
  geom_text_wordcloud_area() + # add wordcloud geom
  scale_size_area(max_size = 18) + # specify text size
  theme_minimal() # choose theme
# get all 6 in one graph
ggarrange(cloud_bmwusa, cloud_landrover, cloud_lexus, cloud_mercedes, cloud_porsche, cloud_tesla,
          labels = brand, ncol = 3, nrow = 2)
# Hint: use Zoom to see words properly (regardless of warning message)




