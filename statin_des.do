n {
	do statin_setup.do
	local c_date = c(current_date)
	local c_time = c(current_time)
	local c_time_date = "`c_date'"+"_" +"`c_time'"
	local time_string = subinstr("`c_time_date'", ":", "_", .)
	local time_string = subinstr("`time_string'", " ", "_", .)
	display "`time_string'"
	qui log using "$resutl$system_sep`time_string'_statin.smcl", replace
}


des


qui log close _all
