*===============================================================*
* barttest — example: with vs. without a control / reference group
* Uses Stata's built-in "auto" dataset (ships with Stata).
*===============================================================*
clear all
set more off

* make ado discoverable if running before install (optional)
capture which barttest
if _rc adopath ++ "`c(pwd)'"

sysuse auto, clear
replace price = price/1000
label variable price "Price (000s)"
label variable rep78 "Repair record 1978"

* (A) No control group: adjacent pairwise comparisons
*     Good for exploring whether neighbouring levels differ.
barttest price, by(rep78) ///
    title("(A) No control group: adjacent comparisons") ///
    saving("example_no_control.png")

* (B) With a control group: rep78==3 is the reference; every other
*     group is compared against it. Good for a clear baseline/control.
barttest price, by(rep78) base(3) stars ///
    title("(B) Control group = 3: each group vs. control") ///
    saving("example_with_control.png")

display as result "DONE"
