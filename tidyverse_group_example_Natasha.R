library(data.table)
library(tidyverse)


dat <- tribble(
  ~app_id, ~Genetic, ~Imaging, ~Imaging_bulk, ~HES,
   1171,     "No",      "No",  "No",  "No",
    289,     "No",      "No",  "No",  "No",
    270,     "No",      "No",  "No",  "No",
    166,     "No",      "No",  "No", "Yes",
    291,     "No",      "No",  "No", "Yes",
  36647,    "Yes",      "No",  "No", "Yes",
  62709,    "Yes",     "Yes",  "No", "Yes",
  58030,    "Yes",     "Yes", "Yes", "Yes",
  58872,    "Yes",      "No",  "No", "Yes",
  60410,    "Yes",     "Yes", "Yes", "Yes"
  )

final<-dat %>%  
  pivot_longer(cols = !app_id, names_to = "type", values_to = "yes_no") %>% 
  group_by(type) %>% 
  count(yes_no) %>% 
  ungroup() %>% 
  pivot_wider(names_from = yes_no, values_from = n)
final
