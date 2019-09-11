*! -propagate- Fill missing values with the unique non-missing value within a group
*! Luís Fonseca, https://github.com/luispfonseca

program define propagate

syntax [varlist], [by(varlist)]

cap which gtools
if c(rc) {
	di as error "This command requires the gtools command."
	di as error "Follow the instructions in https://github.com/mcaceresb/stata-gtools to install it."
	error
}

* if no varlist is passed, assume all variables are passed
if "`varlist'" == "" {
	local varlist _all
}

* ensure no duplicates in the varlist to loop over
local varlist : list uniq varlist

* exclude the by variables from the list if they are passed (e.g. in _all)
local varlist: list varlist - by

tempvar originalsort
qui gen `originalsort' = _n

* compute results
foreach var in `varlist' {
	tempvar _Unique
	qui gunique `var', by(`by') gen(`_Unique')

	* if _Unique is always greater than 1, there is not a unique non-missing value
	* for that group to fill in, so we can skip
	cap assert `_Unique' > 1
	if !c(rc) {
		di as result "Never unique within `by': `var'"
	}
	else {
		* check if any changes will actually happen
		tempvar tochange
		qui gen `tochange' = 0
		qui replace `tochange' = 1 if mi(`var') & `_Unique' == 1
		cap assert `tochange' == 0
		if c(rc) {
			*gegen doesn't take strings as input
			if substr("`:type `var''" , 1, 3) == "str" {
				qui hashsort `by' - `var'
				qui by `by': replace `var' = `var'[1] if mi(`var') & `_Unique' == 1
			}
			else {
				tempvar first_value
				gegen `first_value' = firstnm(`var'), by(`by')
				qui replace `var' = `first_value' if mi(`var') & `_Unique' == 1
			}
			di as result "Filled in missing values: `var'"
		}
		else {
			di as result "Nothing to propagate in: `var'"
		}
	}
}

qui sort `originalsort'

end
