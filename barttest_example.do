*===============================================================*
* barttest — example do-file
* Uses the bundled practice dataset (4 groups; mixed significance)
*===============================================================*

* load practice data from the repo (no install needed)
use "https://raw.githubusercontent.com/ganma0517/stata_barttest/main/barttest_demo.dta", clear

* 1) Basic: adjacent comparisons (some significant, some not)
*    1 vs 2 ns | 2 vs 3 *** | 3 vs 4 ns
barttest outcome, by(treat) title("barttest: 4 groups, mixed significance")

* 2) Significance stars instead of p-values
barttest outcome, by(treat) stars

* 3) Reference/control group (Control) vs every other group
barttest outcome, by(treat) base(1) stars

* 4) Value labels inside bars (centered), custom y-axis, export
barttest outcome, by(treat) valpos(inbar) valsize(medium) ///
    ytitle("Test score") ylabel(0(20)80, angle(0) grid) ///
    saving("barttest_demo_fig.png")

display as result "barttest example finished."
