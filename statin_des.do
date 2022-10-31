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

distinct

sum


sort ma_the xml1_id ngay_vao
bys ma_the (xml1_id): gen stt = _n

gen statin_yn = 0
replace statin_yn = 1 if (atorvastatin_sl >0 | lovastatin_sl  >0 | pravastatin_sl  >0 | rosuvastatin_sl  >0 |simvastatin_sl >0)


gen eligi = 0
replace eligi = 1 if xhn ==1 | tia ==1 | dotquy_tm == 1

* first eligibility 
by ma_the (stt), sort: gen noccur = sum(eligi)
by ma_the: gen first_obs = noccur == 1  & noccur[_n - 1] != noccur

* first occur for xhn
by ma_the (stt), sort: gen xhn_event = sum(xhn)
by ma_the: gen xhn_first = xhn_event == 1  & xhn_event[_n - 1] != xhn_event


gen mark = 1 if first_obs == 1 & xhn == 0
bys ma_the: egen mark2 = total(mark)


* shift all patients to the time they 1st eligible
drop if noccur == 0


bys ma_the (stt): gen mark22 = 1 if mark2 == 0 & xhn_event[_n - 1] == xhn_event
by ma_the (stt), sort: gen mark22_sum = sum(mark22)
replace mark22_sum = . if mark2 == 1

drop if mark22_sum == 0 & mark22 == .

* Recaculated
bys ma_the (stt): gen stt2 = _n


bys ma_the (stt2): replace first_obs = 1 if mark2 == 0 & first_obs[1] == 0
by ma_the (stt2), sort: replace xhn_event = sum(xhn) if mark2 == 0
by ma_the: replace xhn_first = xhn_event == 1  & xhn_event[_n - 1] != xhn_event if mark2 == 0


egen max_obs = max(stt2), by(ma_the)

by ma_the: egen lasttime = max(cond(xhn_first == 1, stt2, .))
replace lasttime = max_obs if lasttime ==. 



* Statin
tab statin_yn if first_obs == 1

sum if first_obs == 1

bys ma_the: gen statin_itt = statin_yn if first_obs == 1
bys ma_the: egen statin_bs = total(statin_itt)


count if lasttime == stt2 | first_obs == 1

count if lasttime == stt2

* keep if lasttime == stt2

tab xhn if lasttime == stt2 | first_obs == 1
tab statin_bs if lasttime == stt2 | first_obs == 1

tab xhn statin_bs if lasttime == stt2 | first_obs == 1, chi exact ro co exp

cs xhn statin_bs if lasttime == stt2 | first_obs == 1, or


foreach var of varlist machvanh vantim rungnhi nutxoang than_roiloan dongmau {
			bys ma_the: gen `var'_itt = `var' if first_obs == 1
			bys ma_the: egen `var'_bs = total(`var'_itt)
}

gen condition1 = 1
replace condition1 = 0 if machvanh_bs ==1 | vantim_bs ==1 |rungnhi_bs ==1 |nutxoang_bs ==1 |than_roiloan_bs ==1 |dongmau_bs ==1

gen condition2 = 1
replace condition2 = 0 if machvanh_bs ==1 | vantim_bs ==1 |rungnhi_bs ==1 |nutxoang_bs ==1 |dongmau_bs ==1



keep if lasttime == stt2

tab xhn if condition1 == 1
tab statin_bs if condition1 == 1

tab xhn statin_bs if condition1 == 1, chi exact ro co exp
cs xhn statin_bs if condition1 == 1, or

tab xhn if condition2 == 1
tab statin_bs if condition2 == 1

tab xhn statin_bs if condition2 == 1, chi exact ro co exp
cs xhn statin_bs if condition2 == 1, or




qui log close _all