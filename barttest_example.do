*===============================================================*
* barttest — example do-file
* Uses Stata's built-in auto dataset (no external data needed)
*===============================================================*

sysuse auto, clear
replace price = price/1000          // price in $000s for a cleaner axis
label variable price "Price (000s)"

* 1) Basic: adjacent-group comparisons, 95% CI
barttest price, by(rep78) title("barttest: basic")

* 2) All pairwise comparisons, 90% CI
barttest price, by(rep78) level(90) compare("3/4 4/5 3/5") ///
    title("barttest: all pairs, 90% CI")

* 3) Reference group (rep78==3) with significance stars
barttest price, by(rep78) base(3) stars ///
    title("barttest: base(3) with stars")

* 4) Custom appearance + export to PNG
barttest price, by(rep78) barwidth(0.5) ///
    ytitle("Price (000s)") xtitle("Repair record 1978") ///
    ylabel(0(2)16, angle(0) grid) xlabel(labsize(medsmall)) ///
    title("barttest: styled") ///
    saving("barttest_demo.png")

display as result "barttest example finished."
