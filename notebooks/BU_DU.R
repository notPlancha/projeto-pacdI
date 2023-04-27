# -*- coding: utf-8 -*-
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

make_data <- TRUE

# O nosso objetivo é de prever o número de *sets* que um jogo de ténis profissional de Austrália vai ter, baseado num número de recursos que um jogo vai ter. 
#
# Um jogo de ténis é composto por pontos, jogos e sets. De acordo com as [regras de ténis da Federação Internacional de Tennis (IFT)](https://www.atptour.com/en/corporate/rulebook), um set é uma pontuação, onde o primeiro jogador a ganhar 6 jogos ganha um set, sendo um jogo decidido pelo número de sets que um jogador ganha. Um jogo pode ser à melhor de 3 ou à melhor de 5, ou seja, o jogador precisa de ganhar 2 sets (o que traduz para 3 sets de máximo) ou 3 sets (máximo 5), respectivamente.  O jogador que decide o lado que começa/quem serve primeiro é decidido aleatoriamente, sendo que o outro decide a outra decisão.
#
# Baseado nestes factos, parece que o projeto vai ser de regressão ordinal, sendo que o número de sets varia entre 2 e 5, não mais e não menos.

# # Raw

if (make_data){
    source(here("scripts", "toParquet.R"))
}
arrow::read_parquet(here("data", "atpRaw.parquet"), as_data_frame = TRUE) -> atp
head(atp)

nrow(atp)

# A base de dados mostra informação pública de [ATP Tour](https://www.atptour.com/en/players).
#
# A primeira vista dos dados revela vários factos:
#
# * A base de dados tem 1308835, sendo cada registro um jogo de um jogador "principal" (com as informações de tal) contra um oponente (sem as informações de tal).
#     * Isto poderá indicar que teremos de transformar os dados em registros de jogos entre os dois jogadores, sem jogador principal. Não temos a certeza se isto é necessário.
# * Ao fazer a cabeça dos dados, parece que apenas mostra o jogador Novak Djokovic como principal. Isto pode indicar que a base de dados pode estar ordenada de uma certa forma.
#     * Esta ordem apenas pode indicar como os dados foram obtidos, e nada sobre um registro específico. Informação sobre a recolha pode ajudar a perceber melhor o contexto da base de dados.
# * A data parece mostrar as datas do torneio e não do jogo especificamente
# * A coluna `prize` parece mal formatada, com valores omissos presentes. Da mesma forma, aprece que os valores estão em várias moedas diferentes.
# * A coluna `GameRank` parece indicar o *rank* do oponente, não o rank do jogo.
#     * Desta forma, desde que o oponente apareça também como principal, consegue-se ter o rank de ambas as pessoas. No entanto, isto não é garantido.
#     * Nos casos que isto acontece, pode ajudar fazer a diferença de rank entre jogadores.
# * A coluna `Hand` parece incluir ambas as informações do *backhand* e se é destro ou esquerdino
# * O score parece conter a pontuação de cada set, sendo ai onde vamos buscar o número de sets.

set.seed(1)
atp %>% slice_sample(n=5)

# Estes dados mostram também que há jogadores principais sem informações.

atp %>% distinct(PlayerName)

# ## Paises
# Nós pudemos observar no projeto anterior que a limpeza de dados geográficos podem levar a problemas. Decidimos pegar nos dados previamente feitos par a limpeza destes, de forma a garantir que estes se encontram consistentes para análise futura e para a seleção de torneiros australianos apenas e na sua totalidade.

if (make_data) {
    source(here("scripts", "locations.R"))
}
atpC <- arrow::read_parquet(here("data", "atpCountries.parquet"))
head(atpC)

# ## Date

atpC %>% 
    separate_wider_delim(Date, " - ", names=c("ds", "df"), too_few = "debug") %>%
    select(ds, df, Date, Date_ok, Date_pieces, Date_remainder) -> atpCD.debug

atpCD.debug %>% filter(Date_ok == F)

# +
# adapted from sgutreuter/SGmisc
#mid_date <- function(start, end){
#    inter <- interval(start, end)
#    res <- int_start(inter) + ((int_end(inter) - int_start(inter)) / 2)
#    as_date(res)
#}
# -

atpCD <- atpC %>% 
    separate_wider_delim(Date, " - ", names=c("ds", "df"), too_few = "align_start") %>% 
    mutate(tournament.date_start = ymd(ds), tournament.date_finish = ymd(df)) %>%
    select(-ds, -df) %>%
    mutate(tournament.duration = ifelse(
        tournament.date_finish %>% is.na(),
        0,
        tournament.date_finish - tournament.date_start
    ))#, tournament.midDay = ifelse(
     #   tournament.date_finish %>% is.na(),
     #   tournament.date_start,
     #   mid_date(tournament.date_start, tournament.date_finish)
     #)

atpCD

options(scipen=999)
atpCD %>% group_by(tournament.duration) %>% summarise(n=n(), freq = n/nrow(atpCD)*100) %>% arrange(-n)

# TODO analise disto
