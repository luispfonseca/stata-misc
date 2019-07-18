*! -checkinvariant- Check if a variable is invariant within a group
*! Luís Fonseca, https://github.com/luispfonseca

program define checkinvariant, rclass

syntax varlist, by(varlist) [QUIet VERBose]

if "`verbose'" != "" & "`quiet'" != "" {
	di as error "Pick one or none between quiet and verbose."
	error
}

* exclude the by variables from the list if they are passed (e.g. in _all)
local varlist: list varlist - by

* compute results
foreach var in `varlist' {
	tempvar _Unique
	qui gunique `var', by(`by') gen(`_Unique') replace
	cap confirm variable `_Unique'
	if c(rc) {
		di as error "It is likely that `var' only has missing observations and so it will be skipped."
		continue
	}

	cap assert `_Unique' == 1 | `_Unique' == 0
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

return local num_invariant : word count `invariantvarlist'
return local num_variant   : word count   `variantvarlist'

end
