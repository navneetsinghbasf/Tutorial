#################################################################################
# Data Science for Business
# Analyzing Unstructured Data - Topic Modeling
#################################################################################

##### Set up ######
###################

# install required packages
install.packages("wordcloud") # used to create word clouds
install.packages("tm") # used for text mining
install.packages("tidyverse") # contains readr, dplyr, ggplot2 & tidytext (used throughout the exercise)
install.packages("topicmodels") # used for LDA

# set working directory to the desired folder
getwd() # current working directory
# setwd("INSERT FILE PATH HERE")

# load dataset containing some tweets of CEOs of Fortune 1000 companies
install.packages("readr")
library(readr) # using the readr version is faster at reading the data set
tweets <- read_delim("https://www.managementanalytics.education/data/TwitterData/Tweets_Fortune1000CEOs.tsv", 
           delim = "\t", escape_double = FALSE, trim_ws = TRUE)
set.seed(23)

# use only a random subset to speed up calculation
tweets <- tweets[sample(nrow(tweets), 10000), ]
print(paste("Read ", length(tweets$text), " tweets.", sep=""));  # tell us how many tweets we have


##### Data Cleaning & Pre-Processing ######
###########################################

# On the following code section, I will apply a bunch of codes to remove special characters, 
# hyperlinks, usernames, tabs, punctuation and unnecessary white spaces, because all these don’t 
# have any relation to the topic modeling. 
tweets_clean <- iconv(tweets$text, to = "ASCII", sub = " ") # convert the character encoding to ASCII
tweets_clean <- gsub("(RT|via)((?:\\b\\W*@\\w+)+)", "", tweets_clean)  # remove the "RT" (retweet) and usernames 
tweets_clean = gsub("http.+ |http.+$", " ", tweets_clean)  # remove html links
tweets_clean = gsub("http[[:alnum:]]*", "", tweets_clean)
tweets_clean = gsub("[[:punct:]]", " ", tweets_clean)  # remove punctuation
tweets_clean = gsub("[ |\t]{2,}", " ", tweets_clean)  # remove tabs
tweets_clean = gsub("^ ", "", tweets_clean)  # remove leading blanks
tweets_clean = gsub(" $", "", tweets_clean)  # remove lagging blanks
tweets_clean = gsub(" +", " ", tweets_clean) # remove general spaces 

# I will convert all the tweets in lower case since words are case sensitive in R.
# For example: ‘Tweets’ and ‘tweets’ are currently considered as two different words. 
# Moreover, I will remove the duplicate tweets (using an API will sometimes return duplicates). 
tweets_clean = tolower(tweets_clean)
tweets_clean = unique(tweets_clean)
writeLines(as.character(tweets_clean[[1500]])) # see an exemplary clean tweet (number 1500)

# As the next step of data processing I will convert this tweets file, 
# which is a character vector, into a corpus. In general term, corpus in linguistic 
# means a structured set of texts that can be used for statistical analysis, 
# hypothesis testing, occurrence checking and validating linguistic rules. 
# To achieve this goal, I will use ‘Corpus’ and ‘VectorSource’ commands 
# from ‘tm’ library in R. While ‘VectorSource’ will interpret each element of 
# our character vector file ‘tweets_clean’ as a document and feed that input into the ‘Corpus’ command.
# This will eventually convert that into a corpus suitable for statistical analysis.
library(tm)
corpus <- Corpus(VectorSource(tweets_clean))

# I will do some more cleaning on the corpus by removing stop words 
# and numbers because both these have very little value, if there 
# is any, towards our goal of topic modeling. 
# For clarity I will explain a bit more on stop words here before 
# going into coding. Stop words are some extremely common words used 
# in a language which may carry very little value for a particular 
# analysis. In this case I will use the stop words list comes along 
# with ‘tm’ package. To get an idea of the list here are some 
# examples of stop words: a, about, above and so on. 
corpus <- tm_map(corpus, removeWords, stopwords("english")) # remove stop words
corpus <- tm_map(corpus, removeNumbers) # remove numbers

# I am finally done with our first step of data cleaning and 
# pre-processing. In the next step I will start data processing to 
# create our topic model. But before diving into model creation I 
# decided to crate a word cloud to get a feel of the data.
library(wordcloud)
set.seed(1234)
palet <- brewer.pal(8, 'Dark2')
wordcloud(corpus, min.freq = 150, scale = c(4, 0.2) , random.order = TRUE, col = palet)
# hit the stop button to end calculation early

# As a next processing step, I will convert our corpus to a 
# Document Term Matrix (DTM). This creates a matrix that contains 
# all words or terms as an individual column and each document, in our 
# case each tweet, as a row. The numeric value of 1 is assigned to the 
# words that appear in the document from the corresponding row and 
# a value of 0 is assigned to the rest of the words in that row. 
# Thus the resulting DTM file is a sparse matrix, which is a large 
# matrix containing a lot of 0.
dtm <- DocumentTermMatrix(corpus)
dtm
# From the file summary of ‘dtm’ we can see that it contains 
# 9,802 documents, which is the total number of tweets that we have,
# and a total of 23,849 unique words in our tweets. From the non-/sparse 
# entries ratio and the percentage of Sparsity we can see that the 
# sparsity of the file, which is not exactly 100 but very close to 
# 100, is very very high which means that a lot of words appear only in 
# few tweets. 

# remove empty documents (empty after cleaning)
doc.length <- apply(dtm, 1, sum)
dtm <- dtm[doc.length > 0,]


##### First Analyses ######
###########################

# Let's have a look at the most frequently used words in all tweets:
library(dplyr)
freq <- colSums(as.matrix(dtm))
ord <- order(freq, decreasing = TRUE)
freq[head(ord, n = 20)]
# "amp" is actually an artefact that comes from the HTML tag "&amp;" that many tweets contained.
# If we find artefacts like these, we go back to pre-processing and 
# refine the cleaning process. In this case we would add "amp" to 
# the list of stopwords, that get's removed from all tweets.

# lets find words that occur significantly often together with the word 
# "love" to get a better feeling of our dataset
findAssocs(dtm, "love",0.09)
findAssocs(dtm, "can",0.12)

# plot words that have been used more than x times
library(ggplot2)
plot <- data.frame(words = names(freq), count = freq)  # create new dataframe to be plotted
plot <- subset(plot, plot$count > 200)  # selecting only those words that occur more often than 200 times
ggplot(data = plot, aes(words, count)) + 
  geom_bar(stat = 'identity') + 
  ggtitle('Words used more than 200 times') +
  coord_flip()


##### Latent Dirichlet allocation (LDA) ######
###############################################

# Latent Dirichlet allocation (LDA) is the one of the most common 
# algorithms for topic modelling, and it is guided by two principles:
# 1. Each document has a mixture of topics.
# 2. Each topic is a mixture of words.
# LDA estimates both of these at the same time and finds the mixture 
# of words that are associated with each topic.

# first do LDA topic modeling model with 2 topics selected
library(topicmodels)
lda_2 <- LDA(dtm, k = 2, method = 'Gibbs')
as.matrix(terms(lda_2, 15)) # print the top 15 words associated with each topic
# columns represent the topics, while each row represents the most common 
# words in the topic

# now do LDA topic modeling model with 5 topics selected
lda_5 <- LDA(dtm, k = 5, method = 'Gibbs')
as.matrix(terms(lda_5, 15))
# looking at the matrix, the 5 topics don't look particularly distinct

# let's increase the number of topics to 10, to see if this matches 
# our dataset better
lda_10 <- LDA(dtm, k = 10, method = 'Gibbs')
as.matrix(terms(lda_10, 15))
# now topics seem more distinct (e.g. one containing spanish tweets)
# With further tuning we can continuously improve our topic model.

##### Visualization ######
##########################

#The tidytext package has a method for extracting the 
# per-topic-per-word probabilities, the beta, from the 2-topic model.
library(tidytext)
lda_topics <- tidy(lda_2, matrix = "beta")
# For each combination, the model computes the probability of a term 
# being generated from the corresponding topic.
lda_topics

# Find the 15 terms that are most common within 
# each topic using dplyr’s slice_max().
ap_top_terms <- lda_topics %>%
  group_by(topic) %>%
  slice_max(beta, n = 15) %>% 
  ungroup() %>%
  arrange(topic, -beta)

# Visualize these most common terms.
ap_top_terms %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered()+
  labs(title = "The terms that are most common within each topic")

# We repeat the same analysis for the 5-topic model estimated earlier.
lda_topics_5 <- tidy(lda_5, matrix = "beta")
lda_topics_5

#Find the 15 terms that are most common within each topic
ap_top_terms_5 <- lda_topics_5 %>%
  group_by(topic) %>%
  slice_max(beta, n = 15) %>% 
  ungroup() %>%
  arrange(topic, -beta)

# Visualize these most common terms.
ap_top_terms_5 %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered()+
  labs(title = "The terms that are most common within each topic")

# Finally, we repeat the same analysis for the 10-topic model.
lda_topics_10 <- tidy(lda_10,matrix = "beta")
lda_topics_10

#Find the 15 terms that are most common within each topic
ap_top_terms_10 <- lda_topics_10 %>%
  group_by(topic) %>%
  slice_max(beta, n = 15) %>% 
  ungroup() %>%
  arrange(topic, -beta)

# Visualize these most common terms.
ap_top_terms_10 %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered()+
  labs(title = "The terms that are most common within each topic")
