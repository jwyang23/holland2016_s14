
clear
clear matrix
set matsize 5000

**** This .do file calculates the damages from electric vehicles by county
****  The file creates DamEVeh.dta
*global SCC 41
**** SCC in current dollars:  $41 is from $39 2015 SCC in 2011$ updated to 2014$
global CPIadj 1.37
*global CPIadj 1
*** adjust 2000$ to 2014$

global flag 0
***  $flag==0 no file replacement
***  $flag==1 for all damages (main calculations)
***  $flag==2 for own state damages
***  $flag==3 for own county damages

*global TempAdj 1
****  $TempAdj==0 no temperature adjustment
****  $TempAdj==1 adjusts EV range for temperature

*global VSLflag 0
**** $VSLflag==0  (baseline)
**** $VSLflag==1  $2M VSL
**** $VSLflag==2  $6M VSL (Roman)

cd "your directory here"

local year= 2011
* local year=2008

use "MDelectric_local_`year'.dta", clear
***  from Preliminary_Hourly_Results_MD_KWH_Power_`year'.xlsx  worksheet "local"
merge 1:1 hour using "MDelectric_carbon_`year'.dta"
***  from Preliminary_Hourly_Results_MD_KWH_Power_`year'.xlsx  worksheet "CO2 Hourly"
if $VSLflag==1 {
use "MDelectric_local_`year'_2MVSL.dta", clear
***  from Preliminary_Hourly_Results_MD_KWH_Power_`year'_2MVSL.xlsx  worksheet "local"
merge 1:1 hour using "MDelectric_carbon_`year'_2MVSL.dta"
***  from Preliminary_Hourly_Results_MD_KWH_Power_`year'_2MVSL.xlsx  worksheet "CO2 Hourly"
}
if $VSLflag==2 {
use "MDelectric_local_`year'_Roman.dta", clear
***  from Preliminary_Hourly_Results_MD_KWH_Power_`year'_Roman.xlsx  worksheet "local"
merge 1:1 hour using "MDelectric_carbon_`year'_Roman.dta"
***  from Preliminary_Hourly_Results_MD_KWH_Power_`year'_Roman.xlsx  worksheet "CO2 Hourly"_2MVSL
}

if $FutureGrid==1 {
use "MDelectric_local_`year'_Future.dta", clear
***  from Preliminary_Hourly_Results_MD_KWH_Power_`year'_Future_Grid.xlsx  worksheet "local"
merge 1:1 hour using "MDelectric_carbon_`year'_Future.dta"
***  from Preliminary_Hourly_Results_MD_KWH_Power_`year'_Future_Grid.xlsx  worksheet "CO2 Hourly"_2MVSL
}
if $Uncertainty==1 {
use "MDelectric_local_`year'_95th.dta", clear
*use "MDelectric_local_`year'_95thAdd.dta", clear
***  from Preliminary_Hourly_Results_MD_KWH_Power_`year'_Uncertainty.xlsx  worksheet "95th"
merge 1:1 hour using "MDelectric_carbon_`year'.dta"
***  from Preliminary_Hourly_Results_MD_KWH_Power_`year'.xlsx  worksheet "CO2 Hourly"
}
if $Uncertainty==2 {
use "MDelectric_local_`year'_5th.dta", clear
*use "MDelectric_local_`year'_5thAdd.dta", clear
***  from Preliminary_Hourly_Results_MD_KWH_Power_`year'_Uncertainty.xlsx  worksheet "5th"
merge 1:1 hour using "MDelectric_carbon_`year'.dta"
***  from Preliminary_Hourly_Results_MD_KWH_Power_`year'.xlsx  worksheet "CO2 Hourly"
}
if $Regulation==1 {
use "MDelectric_local_`year'_Reg1.dta", clear
***  from Preliminary_Hourly_Results_MD_KWH_Power_`year'_Regulation.xlsx  worksheet "local1"
merge 1:1 hour using "MDelectric_carbon_`year'.dta"
***  from Preliminary_Hourly_Results_MD_KWH_Power_`year'.xlsx  worksheet "CO2 Hourly"
}
if $Regulation==2 {
use "MDelectric_local_`year'_Reg2.dta", clear
***  from Preliminary_Hourly_Results_MD_KWH_Power_`year'_Regulation.xlsx  worksheet "local1"
merge 1:1 hour using "MDelectric_carbon_`year'_Reg2.dta"
***  from Preliminary_Hourly_Results_MD_KWH_Power_`year'_Regulation.xlsx  worksheet "CO2_Reg"
}

foreach X in ercot wecc frcc mro npcc rfc serc spp ca {
replace `X'=$CPIadj*(`X')+$SCC*co2_md_kwh_`X'/35
}
drop co2* _merge

*use "MDelectric_`year'.dta", clear
***  from Preliminary_Hourly_Results_MD_KWH_Power_`year'.xlsx
merge 1:1 hour using ChargPct.dta
drop _merge
preserve
collapse (mean) ercot wecc frcc mro npcc rfc serc spp ca
gen _varname="flat"
save temp.dta, replace
restore
foreach X in prof14  prof58 prof912 prof1316 prof1720 prof2124{
preserve
collapse (mean) ercot wecc frcc mro npcc rfc serc spp ca [aweight = `X']
gen _varname="`X'"
append using temp.dta
save temp.dta, replace
restore
}
collapse (mean) ercot wecc frcc mro npcc rfc serc spp ca [aweight = EPRIProf]
gen _varname="EPRIProf"
append using temp.dta
save temp.dta, replace
use "MDelectric_local_`year'.dta", clear
***  from Preliminary_Hourly_Results_MD_KWH_Power_`year'.xlsx  tab: "Local"
foreach X in ercot wecc frcc mro npcc rfc serc spp ca {
replace `X'=$CPIadj*(`X')
}
if $flag==2  { 
use "MDelectric_local_`year'_State.dta", clear
***  from Preliminary_Hourly_Results_MD_KWH_Power_`year'_STATE.xlsx  tab: "Local"
foreach X in ercot wecc frcc mro npcc rfc serc spp ca {
replace `X'=$CPIadj*(`X')
}
}
if $flag==3  { 
use "MDelectric_local_`year'_Cnty.dta", clear
***  from Preliminary_Hourly_Results_MD_KWH_Power_`year'_County.xlsx  tab: "Local"
foreach X in ercot wecc frcc mro npcc rfc serc spp ca {
replace `X'=$CPIadj*(`X')
}
}
merge 1:1 hour using ChargPct.dta
drop _merge
*collapse (mean) ercot wecc frcc mro npcc rfc serc spp ca
collapse (mean) ercot wecc frcc mro npcc rfc serc spp ca [aweight = EPRIProf]
* first statement uses flat load profile; second statement uses EPRI load profile 
gen _varname="local"
append using temp.dta
xpose, clear varname
rename _varname NERC
*joinby NERC using fips2NERCold.dta
replace NERC="miso" if NERC=="mro"
joinby NERC using fips2NERC.dta
replace fips=12086 if fips==12025
****  Miami-Dade county was renamed
save temp.dta, replace

use "VMT_NEI_v1_2011_21aug2013_v5.dta", clear
*** county-level VMT data from EPA MOVES model
keep if inlist(vehicle_class,1001,1020,1040)
*keep if vehicle_class==1001
collapse (sum) vmt, by(fips)
replace vmt=vmt/1000000000
rename vmt vmt1001plus
merge 1:m fips using temp.dta
drop if _merge ==1
drop _merge

merge 1:m fips using TemperatureMonth.dta
drop if _merge==2
drop _merge

cross using electriccar.dta
gen Y=-1*(19.4-68)^2/ln(1-0.33)
** (variance) parameter for Gaussian distribution assuming 33% range degradation at 19.4 deg F
*gen Y=-1*(90-68)^2/ln(0.8)
** (variance) parameter for Gaussian distribution assuming 20 % range degradation at 90 deg F
if $TempAdj==1  {
replace kwhrsmile=1/(1/kwhrsmile*exp(-1*(avgdaily-68)^2/Y))
} 
*scatter kwhrsmile avgdailymaxairtemperaturef if vehicle ==7
***** Code below uses alternative assumption: max at 65F & inflection at 30F
*gen Y=2*(65-30)^2
*replace kwhrsmile=1/(1/kwhrsmile*exp(-1*(avgdaily-65)^2/Y))

collapse (mean) kwhrsmile [aweight = day], by ( fips vmt1001 local EPRIProf prof2124 prof1720 prof1316 prof912 prof58 prof14 flat NERC electriccar vehicle)

**** Data for Nick's maps  "Map data.xlsx"  on worksheet "kwh per mile"
*br fips kwhrsmile  if vehicle==7 

foreach X in flat local prof14  prof58 prof912 prof1316 prof1720 prof2124 EPRIProf{
gen DamEVeh`X'=`X'*kwhrsmile*100
label var DamEVeh`X' "`X' cents per mile"
drop `X'
}

if $flag==1  {
save DamEVeh_`year'.dta, replace
}
if $flag==2  {
drop DamEVehflat DamEVehprof14 DamEVehprof58 DamEVehprof912 DamEVehprof1316 DamEVehprof1720 DamEVehprof2124 
save "DamEVeh_`year'State.dta", replace
}
if $flag==3  {
drop DamEVehflat DamEVehprof14 DamEVehprof58 DamEVehprof912 DamEVehprof1316 DamEVehprof1720 DamEVehprof2124 
save "DamEVeh_`year'Cnty.dta", replace
}
