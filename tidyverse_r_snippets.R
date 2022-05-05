library(tidyverse)

# get all duplicated ID records
df %>% 
    group_by(ID) %>% 
    filter(n()>1)

# as above with count of each group
df %>% 
    group_by(ID) %>% 
    filter(n()>1) %>% 
    summarize(n=n())


#  THIS HAS BEEN SUPERCEDED BY `ACROSS` ***********
# Filter for all records where a string appears in multiple cols
out <- df %>%
    filter_all(any_vars(. %in% c('I489', 'I48')))
# or in only selected columns:
df %>%
    filter_at(vars(col1, col2), any_vars(. %in% c('M017', 'M018')))


# Replace all occurrences of a string with another string
df %>% 
  mutate_all(., list(~str_replace(., "G200", "G20")))


# WAYS TO SELECT PARTICULAR COLUMNS (WITH MUTATE)
iris %>% 
  mutate(across(-Species,  sum)) %>% 
  head()

iris %>% 
  mutate(across(starts_with("Sepal"), ~ mean(.x, na.rm = T)))

# Get sums across selected columns
iris %>% 
  mutate(blubb = rowSums(across(-Species))) %>% 
  head()

# Combine multiple cols into one (and remove NAs  - for character vectors)
df %>%
  unite(new_col_name, col_names_to-combine, sep = ",", na.rm=TRUE/FALSE)

# Generate an incrementing suffix
features <- paste0("ICD10_", sprintf("%02d", seq(1,11)))
suffix <- paste0("0", 1:10)
features <- glue::glue("ICD_{suffix}")

#Set values in a vector to NA (Can use NA_real_, NA_complex, NA_character_, NA_integer_)
X <- 1:50
x[2:4] <- NA_real_
x[2:4] <-NA_character_

# Read in multiple csv files and bind them together
do.call(rbind, lapply(list.files(pattern = ".csv"), read.csv))

# Bind Rows across Multiple Data frames (when they aren't in a list)
Big_dat <- mget(ls(pattern = "Flag_data")) %>%  #gather the df objects in the working environment
              map_df(I, .id = "source")     #combine into one df

# Convert list of lists to a dataframe CONVERT LIST OF LISTS TO A DATAFRAME
# --- Generate fake data
listoflists <- list(c(1,'a', 3, 4), c(5,'b', 6, 7))
listoflists
#---- Convert to a df, transpose, and convert the resulting matrix back to a dataframe
as.data.frame(t(as.data.frame(listoflists)))
#---- Strip out the rownames if desired
rownames(df) <- NULL
#----	Using dplyr 
as.data.frame(do.call(rbind, listoflists))

 

###########
# To make tables work in either Word or PDF – NOTE HAVEN’T ACTUALLY TRIED THIS
# to define the type of document, 
doc.type <- knitr::opts_knit$get('rmarkdown.pandoc.to') 
#then format tables using an if statement like:
if (doc.type == "docx") { pander(df) } else { kable(df) }
###########


#Code to expand number of rows in data frame by value in column
# -- use uncount(freq_column name)
df <- tibble(field_id = c(120, 121, 123), x = c("a", "b", "c"), n = c(1, 2, 5)); df
df %>% uncount(n)
df %>% uncount(n) %>% 
  group_by(field_id) %>% 
  mutate(ins_index = row_number()-1) %>% 
  ungroup()

