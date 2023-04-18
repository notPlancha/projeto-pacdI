here::i_am("readme.md")
library(dplyr)
filePath <- here::here("data", "atpplayers.json")
dest <- here::here("data", "atpRaw.parquet")

print(paste("Getting", filePath))
ndjson::stream_in(filePath) -> atp

print(paste("Writing parquet to", dest))
atp %>% arrow::write_parquet(dest)
# Rscript .\scripts\toParquet.R