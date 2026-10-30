****************************************************************************************
*Dofile for minimum detectable effects, FEM cluster RCT
****************************************************************************************
* CREATED: Marie Montás, Oct 29 2026
*
* MDE for a two-arm cluster RCT with a binary outcome (Bloom 2005):
*   MDE = (t_{1-alpha/2} + t_{power}) * sqrt( p(1-p) * [icc(1-R2) + (1-icc)(1-R2)/m] / (P(1-P) J) )
* with J clusters, m respondents per cluster, share P of clusters treated,
* and covariates explaining R2 of the variance at both levels; df = J - 2.

clear all
set more off

****************************************************************************************
* SET UP PATHS
****************************************************************************************
* Set FEM_ROOT to the project folder (holds dta/ and tables/).
if "$FEM_ROOT" == "" global FEM_ROOT "`c(pwd)'"
global tables "${FEM_ROOT}/tables/"

****************************************************************************************
* ASSUMPTIONS
****************************************************************************************
local alpha = 0.05
local power = 0.80
local m     = 40     // respondents per community used for power (45 sampled, minus pulse-survey respondents)
local P     = 0.6    // 3 treatment and 2 control communities per randomization block
local R2    = 0.30   // blocks, pre-treatment outcomes, and LASSO-selected covariates

* Baseline rate and ICC estimated from the 2018 DHS in 01_power_inputs_dhs.do
import delimited "${tables}/power_inputs.csv", clear
local p_dhs   = baseline_mean[1]
local icc_dhs = icc[1]

****************************************************************************************
* MDE GRID
****************************************************************************************
tempname grid
postfile `grid' str12 scenario p icc J mde_pp using "${tables}/mde_grid.dta", replace

foreach J in 75 100 165 {
	foreach s in protocol dhs {
		if "`s'" == "protocol" {
			local p   = 0.087   // baseline rate assumed in the protocol
			local icc = 0.10    // conservative ICC assumed in the protocol
		}
		else {
			local p   = `p_dhs'
			local icc = `icc_dhs'
		}
		local df  = `J' - 2
		local M   = invttail(`df', `alpha'/2) + invttail(`df', 1 - `power')
		local var = `p'*(1 - `p') * (`icc'*(1 - `R2') + (1 - `icc')*(1 - `R2')/`m')
		local mde = `M' * sqrt(`var' / (`P'*(1 - `P')*`J'))
		post `grid' ("`s'") (`p') (`icc') (`J') (100*`mde')
	}
}
postclose `grid'

use "${tables}/mde_grid.dta", clear
format p icc %5.3f
format mde_pp %4.1f
list, sepby(J) noobs
export delimited using "${tables}/mde_grid.csv", datafmt replace
erase "${tables}/mde_grid.dta"
