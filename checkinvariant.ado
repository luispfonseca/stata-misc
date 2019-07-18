*! -checkinvariant- Check if a variable is invariant within a group
*! Luís Fonseca, https://github.com/luispfonseca

program define checkinvariant, rclass

syntax varlist, by(varlist) [QUIet VERBose ALLOWMISSing fill]

if "`verbose'" != "" & "`quiet'" != "" {
	di as error "Pick one or none between quiet and verbose."
	error
}

if "`allowmissing'" == "" & "`fill'" != "" {
	di as error "The fill option can only be called with the allowmissing option."
	error 198
}

* exclude the by variables from the list if they are passed (e.g. in _all)
local varlist: list varlist - by

tempvar originalsort
gen `originalsort' = _n

* compute results
foreach var in `varlist' {
	qui hashsort `by'
	tempvar first_value

	*gegen doesn't take strings as input
	if substr("`:type `var''" , 1, 3) == "str" {
		tempvar grouped_string
		gegen `grouped_string' = group(`var')
		local finalvar `grouped_string'
	}
	else {
		local finalvar `var'
	}

	by `by': gegen `first_value' = firstnm(`finalvar')

	if "`allowmissing'" != "" {
		local missing_condition " | mi(`finalvar')"
	}
	else {
		local missing_condition ""
	}

	cap assert `finalvar' == `first_value' `missing_condition'

	if c(rc) == 0 {
		if "`fill'" != "" & "`allowmissing'" != "" {
			cap assert `finalvar' == `first_value'
			if c(rc) {
				* missing numbers are sorted last by default, but strings are first
				if substr("`:type `var''" , 1, 3) == "str" {
					qui hashsort `by' - `var'
				}
				else {
					qui hashsort `by' `var'
				}
				qui by `by': replace `var' = `var'[1]
				local filledvarlist filledvarlist `var'
			}
		}
		if "`verbose'" != "" {
			di as result "Invariant within `by': `var'"
		}
		local invariantvarlist `invariantvarlist' `var'
	}
	else {
		if "`verbose'" != "" {
			di as result "  Variant within `by': `var'"
		}
		local   variantvarlist   `variantvarlist' `var'
	}
}

qui hashsort `originalsort'

if "`quiet'" == "" {
	if "`invariantvarlist'" != "" {
		di as result "Invariant within `by':"
		foreach var in `invariantvarlist' {
			di as result "`var'"
		}
	}
	if "`variantvarlist'" != "" {
		di as result "Variant within `by':"
		foreach var in `variantvarlist' {
			di as result "`var'"
		}
	}
	if "`filledvarlist'" != "" {
		di as result "Variables missing values were replaced by unique non-missing value:"
		foreach var in `filledvarlist' {
			di as result "`var'"
		}
	}
}

return local invariantvarlist = "`invariantvarlist'"
return local   variantvarlist =   "`variantvarlist'"
return local    filledvarlist =    "`filledvarlist'"

return local numinvariant : word count `invariantvarlist'
return local numvariant   : word count   `variantvarlist'
if "`fill'" != "" & "`allowmissing'" != "" {
	return local numfilled    : word count    `filledvarlist'
}

end
