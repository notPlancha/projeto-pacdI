.First <- function(){
	base::.First.sys()
	options(repos=c(CRAN="https://cran.radicaldevelop.com/"))
	tryCatch({
		here::i_am("readme.md")
		library(here)
		library(tidyverse)
		library(conflicted)
		library(tidymodels)
		# do conflicted::conflict_scout() if needed
		conflicts_prefer(
			dplyr::filter(),
			dplyr::lag(),
			stringr::fixed(),
			recipes::step(),
			scales::col_factor(),
			# let discard be,
			# let spec be
		)
	}, error= function(e){
		print("some libraries are not installed, not loading .Rprofile. Do devtools::install_deps()")
	})
}