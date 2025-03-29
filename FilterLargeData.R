
# Loading necessary packages ----------------------------------------------

library(readr)
library(dplyr)
library(stringr)
library(purrr)
library(jsonlite)



# Loading data ------------------------------------------------------------

full_data <- read_csv("C:/Users/agrey25/Downloads/combined_filtered_data.csv", 
                      locale = locale(encoding = "UTF-8"))


# Filter Data Rows -------------------------------------------------------------

clean_data <- full_data |> 
  filter(grepl("Trump|Donald|Harris|Kamala", fullText, ignore.case = TRUE)) |>  # keep only tweets mentioning either candidate
  filter(!grepl("-\\s*Kamala Harris", fullText, ignore.case = TRUE)) |>     
  filter(!grepl("-\\s*Donald Trump", fullText, ignore.case = TRUE)) |>
  filter(!grepl("Kamala Harris'?s?:", fullText, ignore.case = TRUE)) |>    
  filter(!grepl("Donald Trump'?s?:", fullText, ignore.case = TRUE)) |>
  mutate(fullText = str_remove_all(fullText, "^\\-+"))|>
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
  mutate(fullText = gsub("biden/harris", "harris", fullText)) |>
  mutate(viewCount_cleaned = str_replace_all(viewCount, "'", "\"")) |>
  mutate(viewCount = map(viewCount_cleaned, function(x) {
    vc <- tryCatch(fromJSON(x), error = function(e) return(NULL))
    if (is.null(vc)) {
      return(NA)
    } else if (vc$state == "Enabled") {
      return(0)
    } else if (!is.null(vc$count)) {
      return(as.numeric(vc$count))
    } else {
      return(NA)
    }
  })) |>
  mutate(viewCount = unlist(viewCount)) |>
  select(-viewCount_cleaned)

# Modify Columns  ---------------------------------------------------------

trump_pattern <- regex("(trump|donald)", ignore_case = TRUE)
harris_pattern <- regex("(kamala|harris)", ignore_case = TRUE)

df <- clean_data |> 
  mutate(fullText = str_remove_all(fullText, "https://t [^ ]+")) |>
  mutate(
    date = as.Date(date),
    year = format(date, "%Y"),
    month = format(date, "%m"),
    day = format(date, "%d")
  ) |> select (-date, -year, -lang)|>
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

chunk_size <- 450000
output_folder <- "C:/Users/agrey25/Downloads"
base_filename <- "large_data"

# Get total rows and calculate chunk indices
total_rows <- nrow(df_ready)
chunk_starts <- seq(1, total_rows, by = chunk_size)

# Automatically execute chunk saving
for (i in seq_along(chunk_starts)) {
  start_row <- chunk_starts[i]
  end_row <- min(start_row + chunk_size - 1, total_rows)
  
  chunk <- df_ready |> slice(start_row:end_row)
  filename <- paste0(output_folder, "/", base_filename, "_chunk", i, ".csv")
  
  write_csv(chunk, filename)
  cat("Saved chunk", i, "- rows:", start_row, "to", end_row, "as", filename, "\n")
}
