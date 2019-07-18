*! -checkinvariant- Check if a variable is invariant within a group
*! Luís Fonseca, https://github.com/luispfonseca

program define checkinvariant, rclass

syntax varlist, by(varlist) [QUIet VERBose ALLOWMISSing]

if "`verbose'" != "" & "`quiet'" != "" {
	di as error "Pick one or none between quiet and verbose."
	error
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
		by `by': gegen `first_value' = firstnm(`grouped_string')
		if "`allowmissing'" != "" {
			local missing_condition_str " | mi(`grouped_string')"
		}
		else {
			local missing_condition_str ""
		}
		cap assert `grouped_string' == `first_value' `missing_condition_str'
	}
	else {
		by `by': gegen `first_value' = firstnm(`var')
		if "`allowmissing'" != "" {
			local missing_condition_var " | mi(`var')"
		}
		else {
			local missing_condition_str ""
		}
		cap assert `var' == `first_value' `missing_condition_var'
	}

	if c(rc) == 0 {
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
}

return local invariantvarlist = "`invariantvarlist'"
return local   variantvarlist = "`variantvarlist'"

return local numinvariant : word count `invariantvarlist'
return local numvariant   : word count   `variantvarlist'

end
