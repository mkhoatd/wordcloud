library(tidyverse)
library(arrow)
library(rvest)
library(stringr)
library(readtext)
library(flextable)
library(webdriver)
# activate klippy for copy-to-clipboard button
klippy::klippy()

# Create new phantomjs session
pjs_instance <- run_phantomjs()
pjs_session <- Session$new(port = pjs_instance$port)

get_article_link <- function(url) {
  base_url <- "https://baomoi.com/"
  pjs_session$go(url)
  rendered_source <- pjs_session$getSource()
  html_content <- rvest::read_html(rendered_source) 
  article_links <- html_content |>
    rvest::html_elements(xpath = '//div[@class="bm_i"]/\
                        div[@class="bm_h"]/h3[@class="bm_I"]/a') |>
    rvest::html_attr("href")
  final_article_links <- NULL
  for (link in article_links) {
    link <- str_c(base_url, link)
    final_article_links <- c(final_article_links, link)
  }
  return(final_article_links)
}

get_page_content <- function(url) {
  pjs_session$go(url)
  rendered_source <- pjs_session$getSource()
  html_content <- rvest::read_html(rendered_source)

  title <- html_content |>
    rvest::html_elements(xpath = '//h1[@class="bm_I"]') |>
    rvest::html_text2()

  summary <- html_content |>
    rvest::html_elements(xpath = '//h3[@class="bm_j bm_I"]') |>
    rvest::html_text2()

  page_content <- html_content |>
    rvest::html_elements(xpath = '//p[@class="bm_Cg"]') |>
    rvest::html_text2()
  contents <- c(title, summary, page_content)
  contents_string <- paste(contents, collapse = "\n")
  return(contents_string)
}

crawl_baomoi <- function(num_of_pages = 10) {
  main_url <- "https://baomoi.com/khoa-hoc/trang{page_num}.epi"
  articles <- tibble(
    url = character(),
    sentences = character()
  )

  pb <- txtProgressBar(min = 0, max = num_of_pages, initial = 1)
  print(num_of_pages)
  for (page_num in 1:num_of_pages) {
    url <- str_glue(main_url, page_num = page_num)
    article_links <- get_article_link(url)
    for (link in article_links) {
      sentences <- get_page_content(link)
      temp <- tibble(
        url = link,
        sentences = sentences
      )
      articles <- rbind(articles, temp)
    }
    setTxtProgressBar(pb, page_num)
  }
  close(pb)
  return(articles)
}

articles <- crawl_baomoi(num_of_pages = 2)
articles |> write_csv(file = "./article_contents.csv")