.First <- function(){
	base::.First.sys()
	options(repos=c(CRAN="https://cran.radicaldevelop.com/"))
	tryCatch({
		here::i_am("readme.md")
		library(here)
		library(tidyverse)
		library(conflicted)
		library(tidymodels)
		library(tidylog)
		# do conflicted::conflict_scout() if needed
		conflict_prefer_all("tidylog", c("dtplyr", "dplyr"))
		conflicts_prefer(
			tidylog::filter(),
			tidylog::lag(),
			stringr::fixed(),
			recipes::step(),
			scales::col_factor(),
			dplyr::left_join(),# still broken in 1.0.1.9000 (tidylog/issues/58)
			dplyr::join_by(),
			# let discard be,
			# let spec be
		)
	}, error= function(e){
		print("some libraries are not installed, not loading .Rprofile. Do devtools::install_deps()")
	})
}