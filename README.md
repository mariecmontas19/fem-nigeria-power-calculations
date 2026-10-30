# Power Calculations for a Cluster-Randomized Trial of a Family Planning Radio Campaign in Nigeria

Power calculation code for the evaluation of Family Empowerment Media's (FEM) radio campaign, a cluster-randomized trial in rural communities in Nigeria. Contact: Marie C. Montás, Department of Global Health and Population, Harvard T.H. Chan School of Public Health (mariemontas@fas.harvard.edu).

## Overview

The trial randomizes communities to FEM's radio programming or to control, with 3 treatment and 2 control communities in each randomization block, and its primary outcome is current use of modern contraception among women aged 15 to 45. Before baseline data existed, we needed realistic values for the baseline rate and the intra-cluster correlation (ICC) of the main outcomes. I estimated them from the 2018 Nigeria Demographic and Health Survey for rural women in the candidate states, using the survey design for the means and a random-intercept model by DHS cluster for the ICCs. The second script turns those inputs into minimum detectable effects (MDEs) for different numbers of communities. Under the protocol's assumptions (a baseline rate of 8.7 percent, an ICC of 0.1, 40 respondents per community, and covariates explaining 30 percent of the variance at both levels), the design can detect a 3.7 percentage point increase in modern contraceptive use with 165 communities, at 80 percent power and a 5 percent two-sided significance level.

## Contents

```
code/     01_power_inputs_dhs.do and 02_mde.do
tables/   baseline inputs by state, the primary-outcome inputs, and the MDE grid
```

DHS microdata are not included.

## Pipeline

Set `global FEM_ROOT` to the project folder (the folder that holds `dta/` and `tables/`); if it is not set, Stata uses the current working directory.

| Stage | What it does |
|---|---|
| 01 | `01_power_inputs_dhs.do`: survey-weighted means and standard deviations by state for births in the past one to three years, current pregnancy or a birth in the past year, modern and any contraceptive use among women who are not pregnant, weekly radio listening, and eligible women per household; ICCs from random-intercept models; writes `power_inputs.csv` |
| 02 | `02_mde.do`: MDEs for a two-arm cluster RCT with a binary outcome (Bloom 2005), under the protocol's assumptions and under the DHS estimates, for 75, 100, and 165 communities; writes `mde_grid.csv` |

## Results

Modern contraceptive use among rural women aged 15 to 45 who are not pregnant is 8.0 percent in the candidate states, with an ICC of 0.103, close to the protocol's assumptions. The ICCs for births in the past two and three years and for current pregnancy or a recent birth are between 0.04 and 0.05.

| Communities | MDE, protocol assumptions (pp) | MDE, DHS estimates (pp) |
|---|---|---|
| 75 | 5.5 | 5.4 |
| 100 | 4.8 | 4.7 |
| 165 | 3.7 | 3.6 |

## Software

StataNow 19.5 (MP) with `outreg2` 2.3.2.

## Data access

The 2018 Nigeria DHS individual recode (NGIR7B) and the birth-history extract built from it are available from the DHS Program (dhsprogram.com) after registration, and cannot be redistributed. Place them in `dta/` as `NGIR7BFL.DTA` and `family_planning_data_nigeria.DTA`.

## Citation

Montás, M. C. (2026). *Power Calculations for a Cluster-Randomized Trial of a Family Planning Radio Campaign in Nigeria.* Code repository, Harvard T.H. Chan School of Public Health.
