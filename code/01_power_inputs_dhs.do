****************************************************************************************
*Dofile for inputs for power calculations FEM project 
****************************************************************************************
* CREATED: Marie Montás, 1st July 2024
* LAST UPDATE: Marie Montás, Oct 29 2026

clear all
set more off
set maxvar 10000   // the DHS individual recode has more than 5,000 variables

****************************************************************************************
* SET UP PATHS
****************************************************************************************
* Set FEM_ROOT to the project folder (holds dta/ and tables/).
if "$FEM_ROOT" == "" global FEM_ROOT "`c(pwd)'"
global dta    "${FEM_ROOT}/dta/"
global tables "${FEM_ROOT}/tables/"

use "${dta}/family_planning_data_nigeria.DTA", clear

**Setting the sample* 

tab stratum
decode stratum, gen(stratum_str)

gen state = 0 
local i = 0 
foreach c in "abia" "enugu" "katsina" "nasarawa" "niger" "plateau" "ondo" "oyo" "kaduna" "kebbi" {
	local i = 1 + `i'
	replace state = `i' if strpos(stratum_str, "`c'")
}
tab stratum if state <= 0
label define state 0 "N/A" 1 "Abia" 2 "Enugu" 3 "Katsina" 4 "Nasarawa" 5 "Niger" 6 "Plateau" 7 "Ondo" 8 "Oyo" 9 "Kaduna" 10 "Kebbi"
label values state state
tab state


/* Number of births in the past 1, 2 and 3 years preceding interview**/

foreach n of numlist 1/20 {
	foreach v in birth_date_month_ birth_date_day_ birth_date_year_ {
		tostring `v'`n', gen(`v'`n'_str)
	}
	gen birth_date_`n'_str = birth_date_month_`n'_str + "/" + birth_date_day_`n'_str + "/" + birth_date_year_`n'_str
	gen birth_date_`n' = date(birth_date_`n'_str, "MDY")
	format birth_date_`n' %td
	drop birth_date_month_`n' birth_date_year_`n' birth_date_month_`n'_str birth_date_year_`n'_str birth_date_`n'_str birth_date_day_`n'_str
}

gen num_birth_1yr = 0 
gen num_birth_2yr = 0 
gen num_birth_3yr = 0 

foreach n of numlist 1/20 {
	replace num_birth_1yr = num_birth_1yr + 1 if (birth_date_`n' >= (int_date_exact - 365)) & birth_date_`n'!=.
	replace num_birth_2yr = num_birth_2yr + 1 if (birth_date_`n' >= (int_date_exact - 730)) & birth_date_`n'!=.
	replace num_birth_3yr = num_birth_3yr + 1 if (birth_date_`n' >= (int_date_exact - 1095)) & birth_date_`n'!=. 
	gen birth_date_1yr_`n' = birth_date_`n' if (birth_date_`n' >= (int_date_exact - 365)) & birth_date_`n'!=.
	format birth_date_1yr_`n' %td
	gen birth_date_2yr_`n' = birth_date_`n' if (birth_date_`n' >= (int_date_exact - 730)) & birth_date_`n'!=.
	format birth_date_2yr_`n' %td
	gen birth_date_3yr_`n' = birth_date_`n' if (birth_date_`n' >= (int_date_exact - 1095)) & birth_date_`n'!=.
	format birth_date_3yr_`n' %td
}

tab num_birth_1yr
/*num_birth_1 |
         yr |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     35,200       84.17       84.17
          1 |      6,484       15.50       99.67
          2 |        136        0.33      100.00
          3 |          1        0.00      100.00
------------+-----------------------------------
      Total |     41,821      100.00*/
	  
tab num_birth_2yr	  
/*
num_birth_2 |
         yr |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     29,003       69.35       69.35
          1 |     12,349       29.53       98.88
          2 |        454        1.09       99.96
          3 |         15        0.04      100.00
------------+-----------------------------------
      Total |     41,821      100.00

*/
tab num_birth_3yr
/*
num_birth_3 |
         yr |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     24,519       58.63       58.63
          1 |     14,875       35.57       94.20
          2 |      2,320        5.55       99.74
          3 |        101        0.24       99.99
          4 |          6        0.01      100.00
------------+-----------------------------------
      Total |     41,821      100.00
*/


/*Proportion of women currently pregnant or with a birth in the last year*/ 

tab preg_current 
tab num_birth_1yr

gen num_birth_1yr_bin = 0
replace num_birth_1yr_bin = 1 if num_birth_1yr == 1 | num_birth_1yr == 2 |num_birth_1yr == 3
tab num_birth_1yr_bin

gen current_preg_or_pastyear = 0 
replace current_preg_or_pastyear = 1 if preg_current == 1 | num_birth_1yr_bin == 1

tab current_preg_or_pastyear
/*current_pre |
g_or_pastye |
         ar |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     31,091       74.34       74.34
          1 |     10,730       25.66      100.00
------------+-----------------------------------
      Total |     41,821      100.00

*/

gen included_q1 = 0
replace included_q1 = 1 if (age >= 15 & age <= 45) & urban ==0 & state > 0 


/*Proportion of women with at least one birth or pregnancy in past three years whose most recent birth or pregnancy is <18 and <24 months after their previous birth or pregnancy*/

local 12 = 365
local 18 = 545
local 24 = 730

foreach c in 12 18 24 {
	gen num_birth_3yr_sbi_`c'mo = 0 if num_birth_3yr > 0 
	foreach n of numlist 1/3 {
		local i = `n' + 1
		replace num_birth_3yr_sbi_`c'mo = num_birth_3yr_sbi_`c'mo + 1 if num_birth_3yr_sbi_`c'mo!=. & ((birth_date_3yr_`i' + ``c'') > birth_date_3yr_`n') & (birth_date_3yr_`i'!=. & birth_date_3yr_`n'!=.) & (birth_date_3yr_`i'!= birth_date_3yr_`n')
	}
	gen has_sbi_3yr_`c'mo = 0 if num_birth_3yr > 0 & num_birth_3yr!=.
	replace has_sbi_3yr_`c'mo = 1 if num_birth_3yr_sbi_`c'mo > 0 & num_birth_3yr_sbi_`c'mo!=.	
}

gen included_q2 = 0 
replace included_q2 = 1 if (age >= 15 & age <= 45) & num_birth_3yr > 0 & num_birth_3yr!=. & urban == 0 & state > 0


***Calculations of three first outcomes***

svyset, clear
svyset cluster [pw = woman_weight], strata(stratum) singleunit(centered)

svy, subpop(included_q1): mean num_birth_2yr num_birth_3yr current_preg_or_pastyear, over(state)
estat sd
outreg2 using "${tables}/table2.xls", replace label auto(4) noaster ctitle("1") 
svy, subpop(included_q1): mean num_birth_1yr num_birth_2yr num_birth_3yr current_preg_or_pastyear 
estat sd
outreg2 using "${tables}/table2.xls", append label auto(4) noaster ctitle("2") 

/*
svy, subpop(included_q2): mean has_sbi_3yr_12mo has_sbi_3yr_18mo has_sbi_3yr_24mo, over(state)
outreg2 using "${tables}/table2.xls", append label auto(4) noaster ctitle("3") 

svy, subpop(included_q3): mean has_sbi_3yr_12mo has_sbi_3yr_18mo has_sbi_3yr_24mo 
outreg2 using "${tables}/table2.xls", append label auto(4) noaster ctitle("4")  */

foreach v in num_birth_2yr num_birth_3yr current_preg_or_pastyear {
	mixed `v' if included_q1 == 1 || cluster:
	estat icc
	local icc_`v' = r(icc2)
}


***Currently using modern contraception****

use "${dta}/NGIR7BFL.DTA", clear

*Moder contraception definition: hormonal and barrier methods, sterilization, emergency contraception

gen modern_contraception_nonpregnant = 1
gen any_contraception_nonpregnant =1 
replace modern_contraception_nonpregnant = 0 if v312 == 0 | v312 == 8 | v312 == 10 | v312 == 9 | v312 ==13 | v312==18
*excluding not using, withdrawal, LAM, beads, other traditional & periodic abstinence 
replace any_contraception_nonpregnant = 0 if v312 == 0
*excluding not using 

tab modern_contraception_nonpregnant 
/*modern_cont |
raception_n |
 onpregnant |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     37,902       90.63       90.63
          1 |      3,919        9.37      100.00
------------+-----------------------------------
      Total |     41,821      100.00

*/

tab any_contraception_nonpregnant 

/*any_contrac |
eption_nonp |
    regnant |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     36,179       86.51       86.51
          1 |      5,642       13.49      100.00
------------+-----------------------------------
      Total |     41,821      100.00


*/

**Not pregnant & not sterilized 

gen notpreg_sterilized = 1

replace notpreg_sterilized = 0 if v213 == 1 | v312 == 6 

tab notpreg_sterilized

/*notpreg_ste |
    rilized |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      4,264       10.20       10.20
          1 |     37,557       89.80      100.00
------------+-----------------------------------
      Total |     41,821      100.00
*/

**Women that ever listen to radio and that listen at least once a week 

gen radio_ever = 1 
replace radio_ever = 0 if v158 == 0 
tab radio_ever
/* radio_ever |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     18,930       45.26       45.26
          1 |     22,891       54.74      100.00
------------+-----------------------------------
      Total |     41,821      100.00
*/

gen radio_atlstonce = 0
replace radio_atlstonce = 1 if v158 == 2
tab radio_atlstonce
/*
radio_atlst |
       once |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     29,768       71.18       71.18
          1 |     12,053       28.82      100.00
------------+-----------------------------------
      Total |     41,821      100.00
*/

*Number of eligible women in household

rename v138 hh_women 

*Setting the sample 

rename sstate state 
rename v012 age 
rename v025 urban 

decode state, gen(state_str)
gen state_analysis = 0 
local i = 0 
foreach c in "abia" "enugu" "katsina" "nasarawa" "niger" "plateau" "ondo" "oyo" "kaduna" "kebbi" {
	local i = 1 + `i'
	replace state_analysis = `i' if strpos(state_str, "`c'")
}

tab state if state_analysis <= 0
label define state 0 "N/A" 1 "Abia" 2 "Enugu" 3 "Katsina" 4 "Nasarawa" 5 "Niger" 6 "Plateau" 7 "Ondo" 8 "Oyo" 9 "Kaduna" 10 "Kebbi"
label values state_analysis state
tab state_analysis

gen included_q3 = 0
replace included_q3 = 1 if (age >= 15 & age <= 45) & urban ==2 & state_analysis > 0 



**calculations**

svyset, clear
svyset v001 [pweight=v005], strata(v022) vce(linearized) singleunit(centered)

svy, subpop(included_q3): mean notpreg_sterilized hh_women radio_atlstonce radio_ever, over(state_analysis)
outreg2 using "${tables}/table3.xls", replace label auto(4) noaster ctitle("1") 
estat sd
svy, subpop(included_q3): mean notpreg_sterilized hh_women radio_atlstonce radio_ever
estat sd 
outreg2 using "${tables}/table3.xls", append label auto(4) noaster ctitle("2") 

**Not pregnant outcomes**
svy, subpop(included_q3 if v213 ==0): mean modern_contraception_nonpregnant any_contraception_nonpregnant hh_women, over(state_analysis)
estat sd
outreg2 using "${tables}/table3.xls", append label auto(4) noaster ctitle("3") 
svy, subpop(included_q3 if v213 ==0): mean modern_contraception_nonpregnant any_contraception_nonpregnant hh_women
estat sd
outreg2 using "${tables}/table3.xls", append label auto(4) noaster ctitle("4") 

foreach v in modern any {
	mixed `v'_contraception_nonpregnant if included_q3 == 1 & v213 == 0 || v001:
	estat icc
	local icc_`v' = r(icc2)
}

**Baseline rate and ICC of the primary outcome, read by 02_mde.do**
svy, subpop(if included_q3 == 1 & v213 == 0): mean modern_contraception_nonpregnant
local p_modern = r(table)[1,1]

file open inputs using "${tables}/power_inputs.csv", write replace
file write inputs "outcome,baseline_mean,icc" _n
file write inputs "modern_contraception," %6.4f (`p_modern') "," %6.4f (`icc_modern') _n
file close inputs
