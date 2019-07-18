cap program drop checkinvariant
qui do checkinvariant.ado

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

* Standard tests
checkinvariant _all, by(id) verbose
assert "`r(invariantvarlist)'" == "invariantnumber invariantstring"
assert   "`r(variantvarlist)'" == "variantnumber invariantnumbermissing variantnumbermissing variantstring invariantstringmissing variantstringmissing"

checkinvariant _all, by(id) verbose allowmissing
assert "`r(invariantvarlist)'" == "invariantnumber invariantnumbermissing invariantstring invariantstringmissing"
assert   "`r(variantvarlist)'" == "variantnumber variantnumbermissing variantstring variantstringmissing"

* Testing when always missing
gen alwaysmissnumber = .
gen alwaysmissstring = ""

checkinvariant alwaysmiss*, by(id) verbose
assert "`r(invariantvarlist)'" == "alwaysmissnumber alwaysmissstring"
assert "`r(numvariant)'" == "0"
checkinvariant alwaysmiss*, by(id) verbose allowmissing
assert "`r(invariantvarlist)'" == "alwaysmissnumber alwaysmissstring"
assert "`r(numvariant)'" == "0"

* Testing the fill option
checkinvariant *miss*, by(id) verbose allowmissing fill
assert "`r(numfilled)'" == "2"
assert "`r(numvariant)'" == "2"
assert "`r(numinvariant)'" == "2"

checkinvariant invariantnumbermissing invariantstringmissing, by(id)
assert "`r(numvariant)'" == "0"
assert mi(variantnumbermissing) if !mod(_n,4)
assert mi(variantnumbermissing) if !mod(_n,4)
