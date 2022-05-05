#Taken from here:
#https://www.r-bloggers.com/2021/10/a-one-liner-for-generating-random-participant-ids/
#see also here: https://rdrr.io/cran/ids/f/README.md

#On one of the Slacks I browse, someone asked how to de-identify a column of participant
#IDs. The original dataset was a wait list, so the ordering of IDs itself was a 
#sensitive feature of the data and we need to scramble the order of IDs produced.

#We want to map the participant identifiers onto some sort of shuffled-up random IDs.

library(tidyverse)
data <- tibble::tribble(
  ~ participant, ~ timepoint, ~ score,
  "DB",           1,       7,
  "DB",           2,       8,
  "DB",           3,       8,
  "TW",           1,      NA,
  "TW",           2,       9,
  "CF",           1,       9,
  "CF",           2,       8,
  "JH",           1,      10,
  "JH",           2,      10,
  "JH",           3,      10
)
data

#........................................
#Suggestion 1 : hashing the IDs with "digest". 
# This approach cryptographically compresses the input into a short "digest". (It is not a random ID.)
data %>% 
  mutate(
    participant = Vectorize(digest::sha1)(participant)
  )
#hashing just transforms the IDs. we want to be rid of them completely
#........................................


#........................................
# Suggestion 2 : use the uuid package
# UUIDgenerate generates a new Universally Unique Identifier. 
#It can be either time-based or random
data %>% 
  group_by(participant) %>% 
  mutate(
    id = uuid::UUIDgenerate(use.time = FALSE)
  ) %>% 
  ungroup() %>% 
  select(-participant, participant = id) %>% 
  relocate(participant)


#........................................
# Suggestion 3 : use the forcats package
# fct_anon: Replaces factor levels with arbitrary numeric identifiers. # Neither the values nor the order of the levels are preserved
# only wrinkle is that it requires converting our IDs to a factor in order to work
data %>% 
  mutate(
    participant = participant %>% 
      as.factor() %>% 
      forcats::fct_anon(prefix = "p0")
  )


#........................................
# Suggestion 4 : use match() 
# match(x, table) returns the first positions of the x elements in some vector table.

data %>% 
  mutate(
    participant = match(participant, sample(unique(participant)))
  )

#For more aesthetically pleasing names, and for names that will sort correctly,
# we can zero-pad the results with sprintf().
zero_pad <- function(xs, prefix = "", width = 0) {
  # use widest element if bigger than `width`
  width <- max(c(nchar(xs), width))
  sprintf(paste0(prefix, "%0", width, "d"), xs)    
}

#the nomatch argument allows you to customise the NAs that result if there is no match
data %>% 
  mutate(
    participant = match(participant, sample(unique(participant)), nomatch=0),
    participant = zero_pad(participant, "p", 3)
  )

