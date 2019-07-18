cap program drop checkinvariant
qui do checkinvariant.ado

clear
set obs 10

gen id = floor((_n-1)/5)+1

gen invariantnumber = 2*id
gen   variantnumber = runiform()
gen invariantnumbermissing = invariantnumber if mod(_n,3)
gen   variantnumbermissing  =  variantnumber if mod(_n,4)

gen invariantstring = "bla" * id
gen   variantstring = "bla" * _n
gen invariantstringmissing = invariantstring if mod(_n,3)
gen   variantstringmissing  =  variantstring if mod(_n,4)

checkinvariant _all, by(id) verbose
assert "`r(invariantvarlist)'" == "invariantnumber invariantstring"
assert   "`r(variantvarlist)'" == "variantnumber invariantnumbermissing variantnumbermissing variantstring invariantstringmissing variantstringmissing"

checkinvariant _all, by(id) verbose allowmissing
assert "`r(invariantvarlist)'" == "invariantnumber invariantnumbermissing invariantstring invariantstringmissing"
assert   "`r(variantvarlist)'" == "variantnumber variantnumbermissing variantstring variantstringmissing"

gen alwaysmissnumber = .
gen alwaysmissstring = ""

checkinvariant alwaysmiss*, by(id) verbose
assert "`r(invariantvarlist)'" == "alwaysmissnumber alwaysmissstring"
assert "`r(numvariant)'" == "0"
checkinvariant alwaysmiss*, by(id) verbose allowmissing
assert "`r(invariantvarlist)'" == "alwaysmissnumber alwaysmissstring"
assert "`r(numvariant)'" == "0"