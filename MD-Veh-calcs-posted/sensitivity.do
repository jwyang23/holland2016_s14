clear
clear matrix
set matsize 5000

cd "your directory here"

**** Baseline globals
global SCC 41  
global flag 0
global TempAdj 1
global trucks 0
global urbanrural 1
global doublegas 0
global VSLflag 0
global FutureGrid 0
global Uncertainty 0
global Regulation 0

 *** Sensitivity analyses 
***** SCC
global SCC 51
*global SCC 41
global SCC 31
do "create DamEVeh.do"
save "tempDamEVeh.dta", replace
do "create DamGVeh.do"
keep if vehicle>99
replace vehicle=vehicle/100
merge 1:1 vehicle fips using "tempDamEVeh.dta"
gen DamRedE=LGDamVeh-DamEVehEPRIProf
keep if vehicle==7
collapse (mean) DamEVehEPRIProf LGDamVeh DamRedE (min) minEV=DamEVehEPRIProf minGas=LGDamVeh minEB=DamRedE (max) maxEV=DamEVehEPRIProf maxGas=LGDamVeh maxEB=DamRedE [iweight = vmt1001]
order DamEVehEPRIProf minEV maxEV LGDamVeh minGas maxGas DamRedE minEB maxEB
br
global SCC 41


***  No temp
global TempAdj 0
do "create DamEVeh.do"
save "tempDamEVeh.dta", replace
do "create DamGVeh.do"
keep if vehicle>99
replace vehicle=vehicle/100
merge 1:1 vehicle fips using "tempDamEVeh.dta"
gen DamRedE=LGDamVeh-DamEVehEPRIProf
keep if vehicle==7
collapse (mean) DamEVehEPRIProf LGDamVeh DamRedE (min) minEV=DamEVehEPRIProf minGas=LGDamVeh minEB=DamRedE (max) maxEV=DamEVehEPRIProf maxGas=LGDamVeh maxEB=DamRedE [iweight = vmt1001]
order DamEVehEPRIProf minEV maxEV LGDamVeh minGas maxGas DamRedE minEB maxEB
br
global TempAdj 1


***  Charging profile
do "create DamEVeh.do"
save "tempDamEVeh.dta", replace
do "create DamGVeh.do"
keep if vehicle>99
replace vehicle=vehicle/100
merge 1:1 vehicle fips using "tempDamEVeh.dta"
gen DamRedE=LGDamVeh-DamEVehflat
keep if vehicle==7
collapse (mean) DamEVehflat LGDamVeh DamRedE (min) minEV=DamEVehflat minGas=LGDamVeh minEB=DamRedE (max) maxEV=DamEVehflat maxGas=LGDamVeh maxEB=DamRedE [iweight = vmt1001]
order DamEVehflat minEV maxEV LGDamVeh minGas maxGas DamRedE minEB maxEB
br

**  No urbanrural
global urbanrural 1
do "create DamEVeh.do"
save "tempDamEVeh.dta", replace
do "create DamGVeh.do"
keep if vehicle>99
replace vehicle=vehicle/100
merge 1:1 vehicle fips using "tempDamEVeh.dta"
gen DamRedE=LGDamVeh-DamEVehEPRIProf
keep if vehicle==7
collapse (mean) DamEVehEPRIProf LGDamVeh DamRedE (min) minEV=DamEVehEPRIProf minGas=LGDamVeh minEB=DamRedE (max) maxEV=DamEVehEPRIProf maxGas=LGDamVeh maxEB=DamRedE [iweight = vmt1001]
order DamEVehEPRIProf minEV maxEV LGDamVeh minGas maxGas DamRedE minEB maxEB
br
global urbanrural 1


***  double local gasoline emissions
global doublegas 1
do "create DamEVeh.do"
save "tempDamEVeh.dta", replace
do "create DamGVeh.do"
keep if vehicle>99
replace vehicle=vehicle/100
merge 1:1 vehicle fips using "tempDamEVeh.dta"
gen DamRedE=LGDamVeh-DamEVehEPRIProf
keep if vehicle==7
collapse (mean) DamEVehEPRIProf LGDamVeh DamRedE (min) minEV=DamEVehEPRIProf minGas=LGDamVeh minEB=DamRedE (max) maxEV=DamEVehEPRIProf maxGas=LGDamVeh maxEB=DamRedE [iweight = vmt1001]
order DamEVehEPRIProf minEV maxEV LGDamVeh minGas maxGas DamRedE minEB maxEB
br
global doublegas 0

***  VSL 
**** $VSLflag==0  (baseline)
**** $VSLflag==1  $2M VSL
**** $VSLflag==2  $6M VSL (Roman)
global VSLflag 1
do "create DamEVeh.do"
save "tempDamEVeh.dta", replace
do "create DamGVeh.do"
keep if vehicle>99
replace vehicle=vehicle/100
merge 1:1 vehicle fips using "tempDamEVeh.dta"
gen DamRedE=LGDamVeh-DamEVehEPRIProf
keep if vehicle==7
collapse (mean) DamEVehEPRIProf LGDamVeh DamRedE (min) minEV=DamEVehEPRIProf minGas=LGDamVeh minEB=DamRedE (max) maxEV=DamEVehEPRIProf maxGas=LGDamVeh maxEB=DamRedE [iweight = vmt1001]
order DamEVehEPRIProf minEV maxEV LGDamVeh minGas maxGas DamRedE minEB maxEB
br
global VSLflag 0

***  FutureGrid 
**** $FutureGrid==0  (baseline)
**** $FutureGrid==1  Clean Grid
global FutureGrid 1
do "create DamEVeh.do"
save "tempDamEVeh.dta", replace
do "create DamGVeh.do"
keep if vehicle>99
replace vehicle=vehicle/100
keep if vehicle==4
replace vehicle=7
merge 1:1 vehicle fips using "tempDamEVeh.dta"
gen DamRedE=LGDamVeh-DamEVehEPRIProf
keep if vehicle==7
***
**br fips countyname LGDamVeh DamEVehEPRIProf DamRedE if vehicle==7
collapse (mean) DamEVehEPRIProf LGDamVeh DamRedE (min) minEV=DamEVehEPRIProf minGas=LGDamVeh minEB=DamRedE (max) maxEV=DamEVehEPRIProf maxGas=LGDamVeh maxEB=DamRedE [iweight = vmt1001]
order DamEVehEPRIProf minEV maxEV LGDamVeh minGas maxGas DamRedE minEB maxEB
br
global FutureGrid 0

***** Uncertainty
**** $Uncertainty==0  (baseline)
**** $Uncertainty==1  (High damages)
**** $Uncertainty==2  (Low damages)
global Uncertainty 2
do "create DamEVeh.do"
save "tempDamEVeh.dta", replace
do "create DamGVeh.do"
keep if vehicle>99
replace vehicle=vehicle/100
merge 1:1 vehicle fips using "tempDamEVeh.dta"
gen DamRedE=LGDamVeh-DamEVehEPRIProf
keep if vehicle==7
collapse (mean) DamEVehEPRIProf LGDamVeh DamRedE (p5) minEV=DamEVehEPRIProf minGas=LGDamVeh minEB=DamRedE (p95) maxEV=DamEVehEPRIProf maxGas=LGDamVeh maxEB=DamRedE [iweight = vmt1001]
order DamEVehEPRIProf minEV maxEV LGDamVeh minGas maxGas DamRedE minEB maxEB
br
global Uncertainty 0

**** Regulation
**** $Regulation==0  (baseline)
**** $Regulation==1  (NOx only )
**** $Regulation==2  (NOx SO2 & CO2)
global Regulation 2
do "create DamEVeh.do"
save "tempDamEVeh.dta", replace
do "create DamGVeh.do"
keep if vehicle>99
replace vehicle=vehicle/100
merge 1:1 vehicle fips using "tempDamEVeh.dta"
gen DamRedE=LGDamVeh-DamEVehEPRIProf
keep if vehicle==7
collapse (mean) DamEVehEPRIProf LGDamVeh DamRedE (min) minEV=DamEVehEPRIProf minGas=LGDamVeh minEB=DamRedE (max) maxEV=DamEVehEPRIProf maxGas=LGDamVeh maxEB=DamRedE [iweight = vmt1001]
order DamEVehEPRIProf minEV maxEV LGDamVeh minGas maxGas DamRedE minEB maxEB
br
global Regulation 0

