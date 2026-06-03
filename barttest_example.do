*===============================================================*
* barttest — full example / tutorial do-file
* Practice the complete syntax with the bundled 4-group dataset.
* Run section by section (select lines and Ctrl/Cmd-D), or run the whole file.
*
* The practice data has FOUR groups with a mix of significant and
* non-significant adjacent comparisons, so you can see both solid
* (significant) and dashed (non-significant) brackets.
*===============================================================*

clear all
set more off

*---------------------------------------------------------------*
* 0. Load the practice data straight from the repo (no install needed)
*---------------------------------------------------------------*
use "https://raw.githubusercontent.com/ganma0517/stata_barttest/main/barttest_demo.dta", clear
* (variables: treat = group 1-4 ; outcome = test score)


*===============================================================*
* PART A — THE BASICS
*===============================================================*

* A1. Simplest call: adjacent-group comparisons, 95% CI, p-values
barttest outcome, by(treat)

* A2. Significance stars (* ** ***, ns) instead of the p-value
barttest outcome, by(treat) stars

* A3. Change the CI confidence level (e.g. 90%)
barttest outcome, by(treat) level(90)

* A4. Change the significance threshold for solid vs dashed (e.g. .01)
barttest outcome, by(treat) alpha(0.01) stars


*===============================================================*
* PART B — CHOOSING WHICH GROUPS TO COMPARE
*===============================================================*

* B1. Specific pairs only (uses group VALUES: 1 2 3 4)
barttest outcome, by(treat) compare("1/2 3/4")

* B2. All pairwise comparisons
barttest outcome, by(treat) compare("1/2 1/3 1/4 2/3 2/4 3/4")

* B3. Control / reference group: every other group vs group 1
barttest outcome, by(treat) base(1)

* B4. Reference group with stars
barttest outcome, by(treat) base(1) stars


*===============================================================*
* PART C — VALUE LABELS ON THE BARS
*===============================================================*

* C1. Hide the mean value labels
barttest outcome, by(treat) novalues

* C2. Put the value label INSIDE each bar (centered, white)
barttest outcome, by(treat) valpos(inbar)

* C3. Value label at the bar top instead of above the CI
barttest outcome, by(treat) valpos(mean)

* C4. Bigger value labels + more decimals
barttest outcome, by(treat) valsize(medium) decimals(2)


*===============================================================*
* PART D — TEXT, TITLES, AND AXES
*===============================================================*

* D1. Custom titles
barttest outcome, by(treat) ///
    title("Test score by treatment group") ///
    ytitle("Mean test score") xtitle("Group")

* D2. Bigger bracket (diff/p) label text
barttest outcome, by(treat) labsize(medium)

* D3. Custom y-axis (rule + grid). By default the axis starts at 0.
barttest outcome, by(treat) ylabel(0(20)80, angle(0) grid)

* D4. Rotate / resize the x-axis group labels
barttest outcome, by(treat) xlabel(labsize(small) angle(20))


*===============================================================*
* PART E — APPEARANCE
*===============================================================*

* E1. Narrower bars
barttest outcome, by(treat) barwidth(0.5)

* E2. Custom bar and error-bar colors (one colour for all bars)
barttest outcome, by(treat) barcolor(navy) capcolor(maroon)

* E2b. Give each group its own colour with value=colour pairs. The key is the
*      group's value label, or its raw value (use the raw value when the label
*      contains spaces). Here treat is 1-4, so map the values directly.
barttest outcome, by(treat) colors(1=blue 2=green 3=gs8 4=black)

* E3. A polished, publication-style figure combining many options
barttest outcome, by(treat) stars ///
    valpos(inbar) valsize(medium) labsize(medium) ///
    barwidth(0.6) ytitle("Test score") xtitle("Treatment group") ///
    ylabel(0(20)80, angle(0) grid) ///
    title("barttest: putting it all together")


*===============================================================*
* PART F — SAVE THE FIGURE
*===============================================================*

* F1. Export to PNG (change the path to wherever you like)
barttest outcome, by(treat) stars ///
    title("Saved figure") ///
    saving("barttest_demo_fig.png")

display as result "barttest tutorial finished — see help barttest for details."
