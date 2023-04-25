# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .R
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.14.5
#   kernelspec:
#     display_name: ir_pacd
#     language: R
#     name: ir_pacd
# ---

arrow::read_parquet(here("data", "atpRaw.parquet"), as_data_frame = TRUE) -> atp
path <- here("data", "locations.parquet")

atp %>% group_by(Location) %>% 
    separate_wider_delim(Location, delim=",", names=c("City", "Country"), too_few="debug", too_many="debug") -> atpLocations

atpLocations %>% select(Location, City, Country, Location_ok, Location_pieces)

atpLocations %>%
    filter(Location_ok == FALSE) %>%
    select(Location, City, Country, Location_pieces)

atpLocations %>% 
    filter(Location_pieces > 2 & !(Location %>% endsWith("U.S.A."))) %>%
    select(Location, City, Country, Location_pieces)

read.csv("https://raw.githubusercontent.com/notPlancha/projeto-adb/main/data/countryAlias.csv") %>% distinct() -> aliases
aliases %>% head()

atp %>%
    mutate(
        Location = case_when(
            is.na(Location) | str_trim(Location) %in% c("TBA", "TBC", "TBD", "") ~ NA,
            TRUE ~ str_extract(Location, "(?<=,\\s)[^,]+$") %>% str_squish()
        ), Born = case_when(
            is.na(Born) | str_trim(Born) %in% c("TBA", "TBC", "TBD", "") ~ NA,
            TRUE ~ str_extract(Born, "(?<=,\\s)[^,]+$") %>% str_squish()
        )
    ) -> atpAliases
atpAliases %>% select(Location, Born)

atpAliases %>% head() %>% 
    left_join(aliases, by = join_by(Location == alias)) %>%
    select(Location, country, code)

aliases %>% group_by(alias) %>% summarise(country = first(country)) -> aliasesFixed

atpAliases %>% head() %>% 
    left_join(aliasesFixed, by = join_by(Location == alias)) %>% 
    mutate(tournament.location = country) %>% select(-country, -Location) %>%
    left_join(aliasesFixed, by = join_by(Born == alias)) %>% 
    mutate(principal.born = country) %>% select(-country, -Born) -> atpWCountries
atpWCountries %>% select(tournament.location, principal.born)

atpWCountries %>% arrow::write_parquet(here("data", "atpCountries.parquet"))
