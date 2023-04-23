.First <- function(){
	base::.First.sys()
	here::i_am("readme.md")
	library(here)
	library(tidyverse)
	library(conflicted)
	conflicts_prefer(
		dplyr::filter(),
		dplyr::lag()
	)
}