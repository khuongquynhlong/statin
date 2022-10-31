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

keep if lasttime == stt2

tab xhn 
tab statin_bs 

tab xhn statin_bs, chi exact ro co exp

cs xhn statin_bs, or



qui log close _all