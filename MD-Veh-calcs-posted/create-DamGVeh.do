
clear
clear matrix
set matsize 5000

**** This .do file calculates the damages from non-electric vehicles by county
****  The file creates DamGVeh.dta
*global SCC 41  
**** SCC in current dollars:  $41 is from $39 2015 SCC in 2011$ updated to 2014$  (Baseline)
global CPIadj 1.37
*global CPIadj 1
*** adjust 2000$ to 2014$

global flag 0
***  $flag==0 no file replacement
***  $flag==1 for all damages (main calculations)
***  $flag==2 for own state damages
***  $flag==3 for own county damages

global trucks 0
***  $trucks==0  drops all trucks and calculates SO2 and CO2 from mpg  (Baseline)
***  $trucks==1  keeps trucks with no city v. highway mpg difference (also $35 SCC)

*global urbanrural 1
***  $urbanrural==0 uses average mpg
***  $urbanrural==1 uses city mpg for urban counties and hwy mpg for rural counties (Baseline)

*global doublegas 0
***  $doublegas==0 (Baseline)
***  $doublegas==1  Doubles local pollutant emissions from gas cars

*global VSLflag 0
**** $VSLflag==0  (baseline)
**** $VSLflag==1  $2M VSL
**** $VSLflag==2  $6M VSL (Roman)

local year= 2011
* local year=2008
cd "your directory here"
use "Area_Source_MD_`year'_6MVSL.dta", clear
if $VSLflag==1{
use "Area_Source_MD_2011_2MVSL.dta", clear
}
if $VSLflag==2{
use "Area_Source_MD_2011_6MVSL_Roman.dta", clear
}
if $Uncertainty==1{
use "Area_Source_MD_2011_6MVSL_5th_95th.dta", clear
*use "Area_Source_MD_2011_6MVSL_5th_95th_Additive.dta", clear
keep *_95th* fips number
foreach X in NH3 NOX SO2 VOC PM25 {
ren `X' `X'_`year'
}
}
if $Uncertainty==2{
use "Area_Source_MD_2011_6MVSL_5th_95th.dta", clear
*use "Area_Source_MD_2011_6MVSL_5th_95th_Additive.dta", clear
keep *_5th* fips number
foreach X in NH3 NOX SO2 VOC PM25 {
ren `X' `X'_`year'
}
}
foreach X in NH3 NOX SO2 VOC PM25 {
replace `X'_`year'=$CPIadj *`X'_`year'
}
if $flag==2  {
merge 1:1 fips using ShareState.dta
replace NH3_`year'=NH3_`year'*nh3
replace NOX_`year'=NOX_`year'*nox
replace SO2_`year'=SO2_`year'*so2
replace VOC_`year'=VOC_`year'*voc
replace PM25_`year'=PM25_`year'*pm25
drop nh3 nox so2 voc pm25 _merge
}
if $flag==3  {
merge 1:1 fips using ShareCnty.dta
replace NH3_`year'=NH3_`year'*nh3
replace NOX_`year'=NOX_`year'*nox
replace SO2_`year'=SO2_`year'*so2
replace VOC_`year'=VOC_`year'*voc
replace PM25_`year'=PM25_`year'*pm25
drop nh3 nox so2 voc pm25 _merge
}

replace fips=12086 if fips==12025
****  Miami-Dade county was renamed
merge 1:1 fips using fipscodes.dta
replace state="Arkansas" if fips==5097
replace countyname ="Montgomery" if fips==5097
drop if _m==2
drop _merge number fipsstate fipscounty NH3_`year'
save temp.dta, replace

use "cbsatocountycrosswalk.dta", clear
*** crosswalk from NBER
keep fipscounty cbsa cbsaname 
drop if cbsa==""
destring fipscounty, replace
rename fipscounty fips
rename cbsa msa
rename cbsaname msaname
duplicates drop
merge 1:1 fips using temp.dta
drop if _merge ==1
drop _merge
save temp.dta, replace

use "VMT_NEI_v1_2011_21aug2013_v5.dta", clear
*** we'd need to get earlier year's vmt data
*** county-level VMT data from EPA MOVES model
*** old code
*replace vehicle_class=1020 if vehicle_class==1040
*replace vehicle_class=30073 if vehicle_class==30075
*collapse (sum) vmt, by(fips vehicle_class)
*replace vmt=vmt/1000000000
*reshape wide vmt, i(fips) j(vehicle_class)
*drop vmt1080 vmt30001 vmt30060 vmt30071 
*label variable vmt1001 "car VMT"
*label variable vmt1020 "light truck VMT"
*label variable vmt1070 "Heavy Duty IIb gas VMT"
*label variable vmt30072 "Heavy Duty III-V VMT"
*label variable vmt30073 "Heavy Duty VI-VII VMT"
*label variable vmt30074 "Heavy Duty VIIIb VMT"
keep if inlist(vehicle_class,1001,1020,1040)
*keep if vehicle_class==1001
collapse (sum) vmt, by(fips)
replace vmt=vmt/1000000000
rename vmt vmt1001plus
merge 1:1 fips using temp.dta
drop if _merge ==1
drop _merge
gen urban=msaname!="" 

cross using vehicles.dta
if $trucks==0 {
drop if vehicle>10 & vehicle<100
drop co2edam co2e so2
if $urbanrural==1 {
replace mpg=mpgcity*(urban==1)+mpghwy*(urban==0)
}
gen so2= 0.00616*23.4/mpg
**GREET has .00616g of S02 per mile at 23.4 MPG
*****
gen co2edam=.00892/mpg*$SCC 
**  .00892 MT of CO2 per gal;  
**** old code (error with MT v. short ton)
*gen co2edam=.00892*1000000/mpg/907185*$SCC
**  .00892*1000000 g of CO2 per gal;  907185 grams per short ton
**  note this is only CO2 damages, $trucks==1 has CO2e damages
}
drop mpghwy mpgcity
gen pm25dam= (pm25*PM25_`year')/907185
gen so2dam= ( so2 *SO2_`year' )/907185
gen noxdam= (noxstd *NOX_`year')/907185
gen vocdam= (voc* VOC_`year')/907185
gen LDamVeh= (pm25*PM25_`year' + so2 *SO2_`year' + noxstd *NOX_`year'+ voc* VOC_`year')/907185*100
if $doublegas==1 {
replace LDamVeh=2*LDamVeh
}
replace co2edam=co2edam*100
gen LGDamVeh=LDamVeh+co2edam
**** 907185 grams/ton
label var LDamVeh "Local Damages (cents per mile)"
label var LGDamVeh "Local+Global Damages (cents per mile)"
drop NOX_`year' SO2_`year' VOC_`year' PM25_`year'

if $flag==1  {
save "DamGVeh_`year'.dta", replace
}
if $flag==2  {
drop LGDamVeh
save "DamGVeh_`year'State.dta", replace
}
if $flag==3  {
drop LGDamVeh
save "DamGVeh_`year'Cnty.dta", replace
}
