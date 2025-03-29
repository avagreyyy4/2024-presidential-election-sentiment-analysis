
# Loading necessary packages ----------------------------------------------

library(readr)
library(dplyr)


# Loading data ------------------------------------------------------------

full_data <- read_csv("C:/Users/agrey25/Downloads/my_data.csv")


# Filter Data Rows -------------------------------------------------------------

clean_data <- full_data |> 
  filter(!grepl("France|Sydney|London|Germany|Dubai|Israel|Ontario|Canada|Toronto|Thaiwan|China|UK|Norway|Europe|sydney|🇨🇦|England|India", `author/location`, ignore.case = TRUE)) |> #remove non-US countries
  filter(grepl("Trump|Donald|Harris|Kamala", fullText, ignore.case = TRUE)) |>  # keep only tweets mentioning either candidate
  filter(!grepl("-\\s*Kamala Harris", fullText)) |> # remove quotes by either canidate
  filter(!grepl("-\\s*Donald Trump", fullText)) |>
  mutate(fullText = tolower(fullText)) |>  #convert all text to lower case
  mutate(fullText = gsub("@\\w+", "", fullText)) |>  # remove mentions
  mutate(fullText = gsub("#\\w+", "", fullText)) |>  # remove hashtags
  mutate(fullText = gsub("[^[:alnum:]' ]", "", fullText)) |>
  mutate(fullText = gsub("\\s+", " ", fullText)) |>   
  distinct(fullText, .keep_all = TRUE) |>
  mutate(fullText = gsub("harris/walz", "harris", fullText)) |>
  mutate(fullText = gsub("&amp;", "&", fullText)) |>
  mutate(fullText = gsub("trump/vance", "trump", fullText)) |>
  mutate(fullText = gsub("trump-vance", "trump", fullText)) |>
  mutate(fullText = gsub("harris-walz", "harris", fullText)) |>
  mutate(fullText = gsub("biden/harris", "harris", fullText)) |>
  distinct(fullText, .keep_all = TRUE) 


# Modify Columns  ---------------------------------------------------------

trump_pattern <- regex("(trump|donald)", ignore_case = TRUE)
harris_pattern <- regex("(kamala|harris)", ignore_case = TRUE)

df <- clean_data |> 
  mutate(date = as.Date(createdAt, format="%a %b %d %H:%M:%S %z %Y"),
         day = format(date, "%d"),
         month = format(date, "%b")) |> 
  select (-date, -`...1`, -createdAt, -`author/id`, -`author/location`) |>
  mutate(candidate_mentioned = case_when(
    str_detect(fullText, trump_pattern) & str_detect(fullText, harris_pattern) ~ "Trump, Harris",
    str_detect(fullText, trump_pattern) ~ "Trump",
    str_detect(fullText, harris_pattern) ~ "Harris")) |>
  filter(!is.na(candidate_mentioned)) |> 
  filter(candidate_mentioned != 'Trump, Harris')


# Export data -------------------------------------------------------------

write_csv(df, "C:/Users/agrey25/Downloads/my_data_clean.csv")
