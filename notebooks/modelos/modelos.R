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

df <- arrow::read_parquet(here("data", "featurefull.parquet") ) %>% relocate(starts_with("winner"), starts_with("looser"), starts_with("match"), starts_with("tournament"))
df %>% glimpse()

# vfold
set.seed(1)
df.folds <- vfold_cv(df, v = 5, repeats = 5) # no strata
df.folds %>% glimpse()

# # Feature Selection
#
# Algumas das nossas características são relações diretas de outras características, o que pode levar a problemas de multicolinariedade; portanto, vamos ter que escolher entre essas variáveis. Para isso, vamos ajustar vários modelos para cada conjunto de varíaveis de cada grupo, passo a passo, escolhendo o conjunto de cada grupo com melhor performance. Nesta secção vamos usar regressão logística, pela sua simplicidade.
#
# Nota: aqui, players indica 2 colunas, uma de winner e outra de looser
# * Rank:
#     * players.rank
#     * match.diffRank
#     * match.avgRank
# * Born:
#     * players.bornAt
#     * players.bornAt, players.bornAt.tournFreq
#     * players.bornAt, players.bornAt.hasTourn
#     * players.bornAt.tournFreq
#     * players.bornAt.hasTourn
#     * players.bornAt, match.playersBorn.hasTournXor
#     * match.playersBorn.hasTournXor
#     * players.bornAt, match.playersBorn.tournFreqDiff
#     * match.playersBorn.tournFreqDiff
# * Altura:
#     * players.height
#     * players.heightF
#     * players.heightFC
#     * match.diffHeights
#     * match.avgHeights
#     * match.heightFCvs
# * Nº de jogos
#     * players.nwins
#     * players.nlosses
#     * players.njogos
#     * players.winrate, players.jogos
#     * players.winrate
#     * match.njogosDiff
# * Nº de jogos total
#     * Será a mesma variável da de cima só que estrapulado, mas é preciso 
# * numero do torneio do jogador
#     * player.nTournament
#     * match.nTournamentDiff
# * delay do torneio dos jogadores
#     * player.lastTournamentDelay
# * Mão dominante dos jogadores
#     * match.domHands
# * backhands dos jogadores
#     * match.backhand
#     * match.backHandsL1
#     * match.backHandsL2
# * ronda do tourneio
#     * tournament.round
# * se jogo teve tie breaker
#     * match.hadTieBreaker
# * terreno do torneio
#     * tournament.ground
# * duracao do torneio
#     * tournament.duration
#     * tournament.durationF
#     * tournament.durationFL
# * data do torneio num ano
#     * tournament.quarter
#     * tournament.quarterL1
#     * tournament.quarterL2
#     * tournament.month
# * data do torneio
#     * tournament.dateDistance
# * recompensa do torneio
#     * tournament.prize
#     * tournament.smallPrize
#
#

df.featureSelect.model <- workflow() %>%
    add_model(logistic_reg())
df.featureSelect.model

library(formulaic) # add_formula(match.sets ~ .)
vars <- c(# variables with no direct correlation
    "winner.lastTournamentDelayW",
    "looser.lastTournamentDelayW",
    "match.domHands",
    "match.tournamentRound",
    "match.hadTieBreaker", 
    "tournament.dateDistance"
)
form <- create.formula(input.names = vars, outcome.name = "match.setsCount", dat = df)
print(form$formula)
print(form$inclusion.table$include.variable)

# primeiro modelo
df.featureSelect.model %>% add_formula(form$formula) %>% fit_resamples(df.folds)
