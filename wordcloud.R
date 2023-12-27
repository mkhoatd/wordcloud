library(shiny)
library(readr)
library(tidytext)
library(dplyr)
library(wordcloud)
library(wordcloud2)
library(tidyverse)
library(reticulate)

# Use source_python function from reticulate to import the Python script
source_python("tokenizer.py")

# articles <- read_csv("./article_contents.csv")

# # Tokenize the text into individual words
# words <- articles %>%
#   mutate(sentences = lapply(na.omit(as.character(sentences)), function(x) tokenize(x)))
# # Convert list to a tibble
# words_tibble <- tibble(sentence = unlist(words$sentences))

# # Use unnest_tokens on the tibble
# # Count the frequency of each word
# word_freq <- words_tibble %>%
#   count(sentence, sort = TRUE)

# Create the word cloud
# wordcloud(
#   words = word_freq$sentence,
#   freq = word_freq$n,
#   min.freq = 10,
#   # scale=c(3.5,0.25),
#   random.order=FALSE, 
#   # rot.per=0.35,
#   # rot.per=.15,
#   colors = brewer.pal(8, "Dark2")
# )

ui <- fluidPage(
  wordcloud2Output("wordcloud")
)

server <- function(input, output) {
  output$wordcloud <- renderWordcloud2({
    # Read the data from the CSV file
    articles <- read_csv("./article_contents.csv")

    # Tokenize the text into individual words
    words <- articles %>%
      mutate(sentences = lapply(na.omit(as.character(sentences)), function(x) tokenize(x)))
    # Convert list to a tibble
    words_tibble <- tibble(sentence = unlist(words$sentences))

    # Use unnest_tokens on the tibble
    # Count the frequency of each word
    word_freq <- words_tibble %>%
      count(sentence, sort = TRUE)
    # Create the word cloud
    wordcloud2(word_freq, shape = "pentagon", )

  })
}

shinyApp(ui = ui, server = server, options = list(port = 3000))
