*! barttest v1.4  31May2026
*! Bar chart of group means with CI error bars and pairwise t-test brackets
*! Significant comparison -> solid bracket; non-significant -> dashed bracket
*!
*! Syntax:
*!   barttest depvar , by(groupvar) [ options ]
*!
*! Options:
*!   by(varname)        grouping variable (required)
*!   level(#)           confidence level for CI error bars (default 95)
*!   alpha(#)           significance threshold for solid vs dashed (default .05)
*!   compare(string)    space-separated pairs "a/b c/d ..." using group VALUES.
*!                      default = adjacent pairs in sorted group order.
*!   base(#)            reference group: compare every other group against it
*!                      (overrides compare()). e.g. base(1) -> 1 vs each other.
*!   stars              label brackets with significance stars instead of p-value
*!                      (* p<.05, ** p<.01, *** p<.001, ns otherwise)
*!   title(string)      graph title
*!   ytitle(string)     y-axis title (default = depvar label)
*!   xtitle(string)     x-axis title (default = groupvar label)
*!   ylabel(string)     full y-axis label spec (default ", angle(0)").
*!                      With a rule: ylabel(0(20)100, angle(0) grid)
*!                      Suboptions only: prefix a comma -> ylabel(, labsize(small))
*!   xlabel(string)     EXTRA x-axis label suboptions appended after the group
*!                      position labels (which are always kept). e.g.
*!                      xlabel(labsize(small) angle(45))
*!   barwidth(#)        bar width (default 0.6)
*!   barcolor(string)   bar fill color (default "26 71 95")
*!   capcolor(string)   error-bar color (default red)
*!   decimals(#)        decimals shown for means/diff (default 1)
*!   novalues           do NOT print the mean value label on each bar
*!   valpos(string)     position of the mean value label: top (above the CI,
*!                      default) | mean (at the bar top) | inbar (inside bar)
*!   valsize(string)    text size of the mean value label (default small)
*!   labsize(string)    text size of the diff/p (or stars) bracket label
*!   saving(string)     export path (e.g. "$out/fig.png")
*!   name(string)       graph window name (default barttest)

program define barttest
    version 16.0
    syntax varname(numeric) [if] [in], by(varname) ///
        [ Level(real 95) Alpha(real 0.05) Compare(string) ///
          BASE(string) STARs ///
          title(string asis) ytitle(string asis) xtitle(string asis) ///
          YLABel(string asis) XLABel(string asis) ///
          BARWidth(real 0.6) ///
          BARcolor(string) CAPcolor(string) Decimals(integer 1) ///
          NOVALues VALPos(string) VALSize(string) LABSize(string) ///
          saving(string) name(string) ]

    marksample touse
    local dv `varlist'
    local gv `by'
    markout `touse' `gv'

    if "`barcolor'" == "" local barcolor "26 71 95"
    if "`capcolor'" == "" local capcolor "red"
    if "`name'" == ""     local name "barttest"
    if `"`ytitle'"' == "" {
        local ytl : variable label `dv'
        if `"`ytl'"' == "" local ytl "`dv'"
        local ytitle `"`ytl'"'
    }
    if `"`xtitle'"' == "" {
        local xtl : variable label `gv'
        if `"`xtl'"' == "" local xtl "`gv'"
        local xtitle `"`xtl'"'
    }
    if `"`ylabel'"' == "" local ylabel ", angle(0)"
    if "`valsize'" == "" local valsize "small"
    if "`valpos'"  == "" local valpos "top"
    if !inlist("`valpos'","top","mean","inbar") {
        di as error "valpos() must be top, mean, or inbar"
        exit 198
    }
    * strip a single layer of surrounding double quotes from titles (if user typed them)
    foreach t in title ytitle xtitle {
        local tv `"``t''"'
        if substr(`"`tv'"',1,1)==`"""' & substr(`"`tv'"',-1,1)==`"""' {
            local `t' = substr(`"`tv'"',2,length(`"`tv'"')-2)
        }
    }

    * ---- group levels and x positions ----
    quietly levelsof `gv' if `touse', local(glevs)
    local k : word count `glevs'
    if `k' < 2 {
        di as error "need at least 2 groups in by()"
        exit 198
    }

    tempname M
    tempvar xpos mean lo hi
    quietly gen double `xpos' = .
    quietly gen double `mean' = .
    quietly gen double `lo'   = .
    quietly gen double `hi'   = .

    * value-label aware x tick labels
    local xlab ""
    local i = 0
    foreach g of local glevs {
        local ++i
        * mean and CI for this group
        quietly ci means `dv' if `touse' & `gv'==`g', level(`level')
        local m`g'  = r(mean)
        local lb`g' = r(lb)
        local ub`g' = r(ub)
        local x`g'  = `i'
        * store into plotting vars (one row per group, by obs index)
        quietly replace `xpos' = `i'      in `i'
        quietly replace `mean' = `m`g''   in `i'
        quietly replace `lo'   = `lb`g''  in `i'
        quietly replace `hi'   = `ub`g''  in `i'
        * x-axis label (use value label if available)
        local vl : label (`gv') `g'
        local xlab `xlab' `i' `"`vl'"'
    }

    * ---- comparisons ----
    if "`base'" != "" {
        * compare reference group against every other group
        local okbase = 0
        foreach g of local glevs {
            if `g' == `base' local okbase = 1
        }
        if `okbase' == 0 {
            di as error "base(`base') is not a valid group value of `gv'"
            exit 198
        }
        local compare ""
        foreach g of local glevs {
            if `g' != `base' local compare `compare' `base'/`g'
        }
    }
    else if `"`compare'"' == "" {
        * adjacent pairs in sorted order
        local compare ""
        forvalues j = 1/`=`k'-1' {
            local a : word `j' of `glevs'
            local b : word `=`j'+1' of `glevs'
            local compare `compare' `a'/`b'
        }
    }

    * ---- geometry for brackets ----
    quietly summarize `hi' , meanonly
    local ymax = r(max)
    local span = `ymax'
    local step = `span'*0.11
    local tick = `span'*0.025
    local base = `ymax' + `step'*0.6

    * ---- build twoway layers ----
    local fmt "%9.`decimals'f"
    local plot `"(bar `mean' `xpos', barwidth(`barwidth') color("`barcolor'")) "'
    local plot `"`plot' (rcap `hi' `lo' `xpos', lcolor(`capcolor') lwidth(medthick)) "'

    * mean value labels (optional, position configurable)
    local txt ""
    if "`novalues'" == "" {
        foreach g of local glevs {
            local lbltxt : display `fmt' `m`g''
            local lbltxt = trim("`lbltxt'")
            if "`valpos'" == "top" {
                local ty = `ub`g'' + `span'*0.03
                local vcol "black"
            }
            else if "`valpos'" == "mean" {
                local ty = `m`g'' + `span'*0.03
                local vcol "black"
            }
            else {   /* inbar */
                local ty = `m`g'' - `span'*0.04
                local vcol "white"
            }
            local txt `txt' text(`ty' `x`g'' "`lbltxt'", size(`valsize') placement(c) color(`vcol'))
        }
    }

    * brackets
    local nc : word count `compare'
    local row = 0
    foreach pair of local compare {
        local ++row
        tokenize "`pair'", parse("/")
        local a `1'
        local b `3'
        * run t-test
        quietly ttest `dv' if `touse' & inlist(`gv',`a',`b'), by(`gv')
        local pval = r(p)
        local diff = `m`a'' - `m`b''
        local adiff = abs(`diff')
        * line style
        if `pval' < `alpha' local lp "solid"
        else                local lp "dash"
        * bracket height (stack upward)
        local H  = `base' + (`row'-1)*`step'
        local Ht = `H' - `tick'
        local xa = `x`a''
        local xb = `x`b''
        local xmid = (`xa'+`xb')/2
        * bracket = 3 segments via pci
        local plot `"`plot' (pci `Ht' `xa' `H' `xa'  `H' `xa' `H' `xb'  `H' `xb' `Ht' `xb', lcolor(black) lpattern(`lp') lwidth(medium)) "'
        * label above bracket (trim padding from formatted numbers)
        local dnum : display `fmt' `adiff'
        local dnum = trim("`dnum'")
        if "`stars'" != "" {
            * significance stars
            if      `pval' < 0.001 local sig "***"
            else if `pval' < 0.01  local sig "**"
            else if `pval' < 0.05  local sig "*"
            else                   local sig "ns"
            local blbl "diff = `dnum' `sig'"
            local bsize "small"
        }
        else {
            local pnum : display %5.3f `pval'
            local pnum = trim("`pnum'")
            local blbl "diff = `dnum', p = `pnum'"
            local bsize "vsmall"
        }
        * user override of bracket label size
        if "`labsize'" != "" local bsize "`labsize'"
        local txt `txt' text(`=`H'+`span'*0.045' `xmid' "`blbl'", size(`bsize') placement(c))
    }

    local ytop = `base' + `nc'*`step' + `span'*0.05

    * ---- draw ----
    twoway `plot' ///
        , legend(off) ///
          xlabel(`xlab', noticks `xlabel') ///
          xtitle(`"`xtitle'"') ///
          ytitle(`"`ytitle'"') ///
          yscale(range(0 `ytop')) ///
          ylabel(`ylabel') ///
          title(`"`title'"') ///
          `txt' ///
          graphregion(color(white)) plotregion(margin(b=0)) ///
          name(`name', replace)

    if `"`saving'"' != "" {
        quietly graph export `"`saving'"', replace width(2000)
        di as result "saved: `saving'"
    }
end
