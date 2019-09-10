*! -fmtstrlen- Format string variables to their maximum length
*! Luís Fonseca, https://github.com/luispfonseca

program define fmtstrlen, rclass

syntax [varlist]

* if no varlist is passed, assume it means all string variables
if "`varlist'" == "" {
	local varlist _all
}

* find which of the variables are strings
qui ds `varlist', has(type string)
local strvars "`r(varlist)'"

* not sure if the most efficient way
foreach var of varlist `strvars' {
	local str_length = substr("`:type `var''" , 4, .)
	format `var' %`str_length's
}

end
