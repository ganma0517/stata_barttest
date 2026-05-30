*===============================================================*
* barttest — example: with vs. without a control/reference group
* Uses Stata's built-in auto dataset
*===============================================================*
clear all
set more off

* make ado discoverable if running before install (optional)
capture which barttest
if _rc adopath ++ "/Users/beck/Projects/stata-barttest"

sysuse auto, clear
replace price = price/1000
label variable price "Price (000s)"
label variable rep78 "Repair record 1978"

*---------------------------------------------------------------*
* (A) 無對照組：各組相鄰兩兩比較（沒有指定基準）
*     適合：探索各相鄰水準之間是否有差異
*---------------------------------------------------------------*
barttest price, by(rep78) ///
    title("(A) No control group: adjacent comparisons") ///
    saving("/Users/beck/Projects/Net_zero_2026/output/ex_no_control.png")

*---------------------------------------------------------------*
* (B) 有對照組：以 rep78==3 為對照組，其餘各組都跟它比
*     適合：實驗設計有明確控制組 / 基準組
*---------------------------------------------------------------*
barttest price, by(rep78) base(3) stars ///
    title("(B) Control group = 3: each group vs. control") ///
    saving("/Users/beck/Projects/Net_zero_2026/output/ex_with_control.png")

display as result "DONE"
