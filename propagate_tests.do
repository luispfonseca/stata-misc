clear
set obs 10000

gen id = floor((_n-1)/5)+1

gen invariantnumber = 2* (mod(id,5)+1)
gen   variantnumber = runiform()
gen invariantnumbermissing = invariantnumber if mod(_n,3)
gen   variantnumbermissing  =  variantnumber if mod(_n,4)

gen invariantstring = "bla" * (mod(id,9)+1)
gen   variantstring = "bla" * (mod(_n,4)+1)
gen invariantstringmissing = invariantstring if mod(_n,3)
gen   variantstringmissing  =  variantstring if mod(_n,4)

gen mixedstringmissing = invariantstringmissing
replace mixedstringmissing = variantstringmissing if id <= 3
gen mixedcopy = mixedstringmissing

cap program drop propagate
do propagate.ado

*** propagate missing data
propagate _all, by(id)
