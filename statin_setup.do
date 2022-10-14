* Xoá bỏ những thành phần của lần phân tích trước
set more off, permanently
set linesize 150
macro drop _all
cap log close _all
clear 

*----- Cài đặt các gói cần thiết 
/*
	capture which table1
	if _rc == 111 {
	ssc install table1
	}
	capture which st0408 //distinct
	if _rc == 111 {
	net from http://www.stata-journal.com/software/sj15-3
	net install st0408
	}
	capture which st0085_2 //eststo
	if _rc == 111 {
	net from http://www.stata-journal.com/software/sj14-2
	net install st0085_2 
	}

*/


* Thiết lập môi trường phân tích

global result 		"E:\ncmr_work\working\statin"

global data_path 	"E:\ncmr_work\working\statin"
global res_ai_pt    "C:\Users\hung\Dropbox\Shared\ai_pt\result"
global resutl 		"C:\Users\hung\Dropbox\hung\ProjectsDocs\Private\ai_pt_moi\result"
global dataname     "statin_final.csv"
global datastata    "statin_final.dta"
global system_sep   "\"

global c_date:      display %tdCCYYNNDD date(c(current_date), "DMY")


* Import data csv
* import delim "$data_path$system_sep$dataname", clear delim(",") varnames(1) charset("utf8")
use "$data_path$system_sep$datastata", clear
