
clear
clear matrix
set matsize 5000

****  The file creates the tables

cd "your directory here"

* local year= 2011
* local year=2008
**These locals may not work well....

use "DamGVeh_2011.dta", clear
use "DamEVeh_2011.dta", clear


***Table 1
use "DamEVeh_2011.dta", clear
table NERC  if vehicle==7 [iweight = vmt1001], contents(mean  DamEVehEPRIProf mean DamEVehflat  mean  DamEVehprof14 mean  DamEVehprof58 ) row
table NERC  if vehicle==7 [iweight = vmt1001], contents ( mean  DamEVehprof912 mean  DamEVehprof1316 mean  DamEVehprof1720 mean  DamEVehprof2124 n DamEVehEPRIProf) row


*****Tables 2-4 use "environmental benefits" of equivalent electric car 

use "DamGVeh_2011.dta", clear
keep if vehicle>99
replace vehicle=vehicle/100
merge 1:1 vehicle fips using "DamEVeh_2011.dta"
gen DamRedE=LGDamVeh-DamEVehEPRIProf
gen DamRedElocal=LDamVeh-DamEVehlocal
gen DamRedEglobal=(LGDamVeh-LDamVeh)-(DamEVehEPRIProf-DamEVehlocal)
replace msaname="Rural" if msaname==""

******* Data for Nick's maps  "Map data.xlsx"  worksheet "County"
*br fips countyname LGDamVeh DamEVehEPRIProf DamRedE if vehicle==7

*** correlation between gas and electric damages
corr LGDamVeh DamEVehEPRIProf if vehicle ==7

***Table 2
table vehicle [iweight = vmt1001], contents(mean DamEVehEPRIProf med DamEVehEPRIProf sd DamEVehEPRIProf min DamEVehEPRIProf max DamEVehEPRIProf )
table vehicle [iweight = vmt1001], contents(mean LGDamVeh med LGDamVeh sd LGDamVeh min LGDamVeh max LGDamVeh )
table vehicle [iweight = vmt1001], contents(mean DamRedE med DamRedE sd DamRedE min DamRedE max DamRedE )

table vehicle [iweight = vmt1001], contents(mean DamRedEglobal med DamRedEglobal sd DamRedEglobal min DamRedEglobal max DamRedEglobal )
table vehicle [iweight = vmt1001], contents(mean DamRedElocal med DamRedElocal sd DamRedElocal min DamRedElocal max DamRedElocal )

*** Damage per gallon
gen dampgall=LGDamVeh *mpg
table vehicle [iweight = vmt1001], contents(mean dampgall med dampgall sd dampgall min dampgall max dampgall )


*** Table 3
preserve
*replace DamRedE=LGDamVeh-DamEVehflat
qui table msaname  if vehicle==7 [iweight = vmt1001], contents(mean DamRedE n DamRedE mean LGDamVeh mean DamEVehEPRIProf) row replace
gsort -table1
list msaname table1 table2 table3 table4  if _n<6, clean
*list msaname table1 table2 table3 table4  if table2>15 &_n>=6 & msaname!="Rural"& msaname!="" , clean
list msaname table1 table2 table3 table4  if table2>24 &_n>=6 & msaname!="Rural"& msaname!="" , clean
list msaname table1 table2 table3 table4  if msaname=="Rural"|msaname=="", clean
list msaname table1 table2 table3 table4  if _n>373, clean
restore


*** Table 4
preserve
qui table state  if vehicle==7 [iweight = vmt1001], contents(mean DamRedE n DamRedE mean LGDamVeh mean DamEVehEPRIProf) row replace
gsort -table1
list state table1 table2 table3 table4  if _n<6, clean
*list state table1 table2 table3 table4  if table2>39 & _n<46 & _n>5 & _n!=16, clean
list state table1 table2 table3 table4  if table2>70 & _n<46 & _n>5 & _n!=16, clean
list state table1 table2 table3 table4  if _n>45, clean
list state table1 table2 table3 table4  if state=="", clean
**
*list state table1 table2 table3 table4 , clean
restore

**** Data for Andy's optimal subsidy calculations: Welfare gain.xlsx  (not used)
br fips state countyname DamRedE LGDamVeh DamEVehEPRIProf vmt1001 if vehicle ==7
preserve
keep if vehicle==7
collapse (mean) DamRedE LGDamVeh DamEVehEPRIProf (rawsum) vmt1001 [iweight = vmt1001], by (state)
br
restore

***** Data for Maps  in "Map Data County Subsidy.xlsx"
gen subsplus0= 150000*(LGDamVeh-1.0* DamEVehEPRIProf)
gen State=floor(fips/1000)
br fips state  DamRedE subsplus0 vmt1001 State LGDamVeh DamEVehEPRIProf if vehicle==7

*********************
**** Table 5
*** and Andy data for "Welfare gainv6.xlsx"
*** and Nick's maps 
**************
use "DamGVeh_2011Cnty.dta", clear
keep if vehicle>99
replace vehicle=vehicle/100
merge 1:1 vehicle fips using "DamEVeh_2011Cnty.dta"
drop _merge
keep if vehicle==7
keep fips LDamVeh DamEVehlocal
rename LDamVeh LDamVehCnty
rename DamEVehlocal DamEVehlocalCnty
save temp.dta, replace
*
use "DamGVeh_2011State.dta", clear
keep if vehicle>99
replace vehicle=vehicle/100
merge 1:1 vehicle fips using "DamEVeh_2011State.dta"
drop _merge
keep if vehicle==7
keep fips LDamVeh DamEVehlocal
rename LDamVeh LDamVehState
rename DamEVehlocal DamEVehlocalState
merge 1:1 fips using temp.dta
drop _merge
save temp.dta, replace
*
use "DamGVeh_2011.dta", clear
keep if vehicle>99
replace vehicle=vehicle/100
merge 1:1 vehicle fips using "DamEVeh_2011.dta"
drop _merge
** This statement combines vmt1001, vmt1020, and vmt1040
*replace vmt1001 =vmt1001+vmt1020
keep if vehicle==7
merge 1:1 fips using temp.dta
drop _merge

gen DamRedE=LGDamVeh-DamEVehEPRI
gen DamRedEloc=LDamVeh-DamEVehlocal
gen DamRedEState=LDamVehState-DamEVehlocalState
gen DamRedECnty=LDamVehCnty-DamEVehlocalCnty


*** Table 5
tabstat DamEVehEPRI DamEVehlocal DamEVehlocalState DamEVehlocalCnty [aweight = vmt1001], stat(mean med sd min max n sum) col(stat)
tabstat LGDamVeh LDamVeh LDamVehState LDamVehCnty [aweight = vmt1001], stat(mean med sd min max n sum) col(stat)
tabstat DamRedE DamRedEloc DamRedEState DamRedECnty [aweight = vmt1001], stat(mean med sd min max n sum) col(stat)


*** Map data
preserve
collapse (mean) DamRedE DamRedEloc DamRedEState LDamVeh LDamVehState DamEVehlocal DamEVehlocalState [iweight = vmt1001], by(state)
gsort -DamRedE
gen gasexport=1-LDamVehState/LDamVeh
gen elecexport=1-DamEVehlocalState/DamEVehlocal
*** Data for Nick's maps  Map data.xlsx"  worksheet "State"
*br state DamRedE DamRedEState gasexport elecexport
restore


***
**** Data for Andy's optimal subsidy calculations: Welfare gain.xlsx
** tab: Counties 2011 all
br fips state countyname DamRedE LGDamVeh DamEVehEPRIProf vmt1001
preserve
collapse (mean) DamRedE LGDamVeh DamEVehEPRIProf (rawsum) vmt1001 [iweight = vmt1001], by (state)
** tab: States 2011 all
br
restore
** tab: Counties 2011 local
br fips state countyname DamRedEState LDamVehState DamEVehlocalState vmt1001
preserve
collapse (mean) DamRedEState LDamVehState DamEVehlocalState (rawsum) vmt1001 [iweight = vmt1001], by (state)
** tab: States 2011 local
br
restore
*** Federal native damages include 10% of carbon damages
gen LDamVehFed= LDamVeh+ .1*(LGDamVeh-LDamVeh)
gen DamEVehFed=DamEVehlocal+.1*(DamEVehEPRIProf-DamEVehlocal)
gen DamRedEFed=LDamVehFed-DamEVehFed

collapse (mean) DamRedEFed LDamVehFed DamEVehFed (rawsum) vmt1001 [iweight = vmt1001]
** tab: Fed 2011 native
br

preserve 
collapse (mean) DamRedE DamRedEState  (rawsum) vmt1001 [iweight = vmt1001], by (state)
merge 1:1 state using StateIncents.dta
corr DamRedE DamRedEState subsidy MainIncent AllIncentRegs AllIncent
reg subsidy DamRedE
reg subsidy DamRedEState 
reg MainIncent  DamRedE
reg MainIncent  DamRedEState
reg AllIncentRegs  DamRedE
reg AllIncentRegs  DamRedEState
reg AllIncent  DamRedE
reg AllIncent  DamRedEState
restore

