library(ecosscraper)
library(rvest)
library(tidyverse)

# get listed animals from LII because it has an easy-to-grab HTML table
an <- read_html("https://www.law.cornell.edu/cfr/text/50/17.11")
tabs <- html_table(an, fill = TRUE)
an_tab <- tabs[[3]]
head(an_tab)
an_tab <- an_tab[-1, ]
an_tab$plant_animal <- "animals"

# get listed plants from LII because it has an easy-to-grab HTML table
pl <- read_html("https://www.law.cornell.edu/cfr/text/50/17.12")
tabs <- html_table(pl, fill = TRUE)
pl_tab <- tabs[[3]]
head(pl_tab)
pl_tab <- pl_tab[-1, ]
pl_tab <- pl_tab[, c(2,1,3,4,5)]
pl_tab$plant_animal <- "plants"

# combine plant and animal tables
names(an_tab) == names(pl_tab)
names(an_tab) <- names(pl_tab) <- c("common_name", "scientific_name",
                                    "where_listed", "status", "listing_cit",
                                    "plant_animal")
list_1 <- bind_rows(an_tab, pl_tab)
list_2 <- filter(listed_1, common_name != scientific_name)
saveRDS(list_2, "data-raw/ESA-listed_CFR_raw.rds")

# Now, grab the TECP from FWS to get additional columns
TECP_table_bak <- TECP_table
TECP_table <- get_TECP_table()
names(TECP_table)

min1 <- select(TECP_table, c(1,6,7,10)) %>%
  distinct()
min1$Scientific_Name <- gsub(min1$Scientific_Name,
                             pattern = " (=Salmo)",
                             replacement = "", fixed = TRUE)

j1 <- left_join(list_2, min1, by=c("scientific_name" = "Scientific_Name"))
mis1 <- filter(j1, is.na(j1$Species_Group))
