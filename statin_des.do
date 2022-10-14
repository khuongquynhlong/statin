n {
	do statin_setup.do
	local c_date = c(current_date)
	local c_time = c(current_time)
	local c_time_date = "`c_date'"+"_" +"`c_time'"
	local time_string = subinstr("`c_time_date'", ":", "_", .)
	local time_string = subinstr("`time_string'", " ", "_", .)
	display "`time_string'"
	qui log using "$result$system_sep`time_string'_statin.smcl", replace
}

count

des

table1, vars (gioi_tinh cat\ ) ///
			  format(%2.1f) one saving("$result\table1.xls", sheet (Sheet1, replace))

qui log close _all