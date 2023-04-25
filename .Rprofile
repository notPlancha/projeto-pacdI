.First <- function(){
	base::.First.sys()
	options(repos=c(CRAN="https://cran.radicaldevelop.com/"))
	tryCatch({
		here::i_am("readme.md")
		library(here)
		library(tidyverse)
		library(conflicted)
		conflicts_prefer(
			dplyr::filter(),
			dplyr::lag()
		)
	}, error= function(e){
		print("some libraries are not installed, not loading .Rprofile. Do devtools::install_deps()")
	})
}