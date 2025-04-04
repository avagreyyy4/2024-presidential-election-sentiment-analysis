
# Loading necessary packages ----------------------------------------------

library(readr)
library(dplyr)


# Loading data ------------------------------------------------------------

full_data <- read_csv("C:/Users/agrey25/Downloads/my_data.csv")


# Filter Data Rows -------------------------------------------------------------

clean_data <- full_data |> 
  filter(!grepl("France|Sydney|London|Germany|Dubai|Israel|Ontario|Canada|Toronto|Thaiwan|China|UK|Norway|Europe|sydney|🇨🇦|England|India", `author/location`, ignore.case = TRUE)) |> #remove non-US countries
  filter(grepl("Trump|Donald|Harris|Kamala", fullText, ignore.case = TRUE)) |>  # keep only tweets mentioning either candidate
  filter(!grepl("-\\s*Kamala Harris", fullText, ignore.case = TRUE)) |>     
  filter(!grepl("-\\s*Donald Trump", fullText, ignore.case = TRUE)) |>
  filter(!grepl("Kamala Harris'?s?:", fullText, ignore.case = TRUE)) |>    
  filter(!grepl("Donald Trump'?s?:", fullText, ignore.case = TRUE)) |>
  mutate(fullText = tolower(fullText)) |>  #convert all text to lower case
  mutate(fullText = gsub("@\\w+", " ", fullText)) |>  # remove mentions
  mutate(fullText = gsub("#\\w+", "", fullText)) |>  # remove hashtags
  mutate(fullText = gsub("\\.", " ", fullText)) |>  # replace periods with a space
  mutate(fullText = gsub("'", "", fullText)) |>  # remove apostrophes with NO extra space
  mutate(fullText = gsub("\\s+", " ", fullText)) |>  # normalize spaces
  mutate(fullText = gsub("harris/walz", "harris", fullText)) |>
  mutate(fullText = gsub("&amp;", "&", fullText)) |>
  mutate(fullText = gsub("trump/vance", "trump", fullText)) |>
  mutate(fullText = gsub("trump-vance", "trump", fullText)) |>
  mutate(fullText = gsub("harris-walz", "harris", fullText)) |>
  mutate(fullText = gsub("biden/harris", "harris", fullText)) 


# Modify Columns  ---------------------------------------------------------

trump_pattern <- regex("(trump|donald)", ignore_case = TRUE)
harris_pattern <- regex("(kamala|harris)", ignore_case = TRUE)

df <- clean_data |> 
  mutate(date = as.Date(createdAt, format="%a %b %d %H:%M:%S %z %Y"),
         day = format(date, "%d"),
         month = format(date, "%b")) |> 
  select (-date, -`...1`, -createdAt, -`author/id`, -`author/location`, -type) |>
  mutate(candidate_mentioned = case_when(
    str_detect(fullText, trump_pattern) & str_detect(fullText, harris_pattern) ~ "Trump, Harris",
    str_detect(fullText, trump_pattern) ~ "Trump",
    str_detect(fullText, harris_pattern) ~ "Harris")) |>
  filter(!is.na(candidate_mentioned)) |> 
  filter(candidate_mentioned != 'Trump, Harris')


# Scale & Add additional engagement feature ---------------------------------------

df_ready <- df |>
  mutate(
    likes = (likeCount - min(likeCount)) / (max(likeCount) - min(likeCount)),
    retweets = (retweetCount - min(retweetCount)) / (max(retweetCount) - min(retweetCount)),
    views = (viewCount - min(viewCount)) / (max(viewCount) - min(viewCount)),
    comments = (replyCount - min(replyCount)) / (max(replyCount) - min(replyCount)),
    total_engagement = retweetCount + likeCount + replyCount,
    engagements = if_else(viewCount > 0, total_engagement / viewCount, 0), # fix here
    engagement_rate = (engagements - min(engagements)) / (max(engagements) - min(engagements))
  ) |>
  select(-likeCount, -retweetCount, -replyCount, -viewCount, -engagements, -total_engagement)|>
  distinct(fullText, .keep_all = TRUE)

# Export data -------------------------------------------------------------

write_csv(df_ready, "C:/Users/agrey25/Downloads/my_data_clean.csv")
