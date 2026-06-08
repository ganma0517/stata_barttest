*! barttest v1.7  8Jun2026
*! Bar chart of group means with CI error bars and pairwise t-test brackets
*! Significant comparison -> solid bracket; non-significant -> dashed bracket
*!
*! Syntax:
*!   barttest depvar , by(groupvar) [ options ]
*!
*! ---- required ----
*!   by(varname)        grouping variable
*!
*! ---- which comparisons & significance ----
*!   compare(string)    space-separated pairs "a/b c/d ..." using group VALUES;
*!                      default = adjacent pairs in sorted group order
*!   base(#)            reference group: compare every other group against it
*!                      (overrides compare()); e.g. base(1) -> 1 vs each other
*!   level(#)           confidence level for CI error bars (default 95)
*!   alpha(#)           significance threshold for solid vs dashed (default .05)
*!   stars              label brackets with significance stars instead of p-value
*!                      (* p<.05, ** p<.01, *** p<.001, ns otherwise)
*!
*! ---- faceting (small multiples) ----
*!   panel(varname)     draw one sub-plot per level and combine them
*!   cols(#)            number of columns when faceting (default: auto)
*!
*! ---- bars & colours ----
*!   barwidth(#)        bar width (default 0.6)
*!   barcolor(string)   bar fill colour for all bars (default "26 71 95")
*!   bycolors(string)   explicit colour per group, as value=colour pairs, e.g.
*!                      bycolors(North=navy South=forest_green West=gs7)
*!                      (colors() is kept as a backward-compatible alias)
*!   capcolor(string)   error-bar colour (default red)
*!
*! ---- value labels on bars ----
*!   novalues           do NOT print the mean value label on each bar
*!   valpos(string)     mean label position: top (above the CI, default) |
*!                      mean (at the bar top) | inbar (inside bar)
*!   valsize(string)    text size of the mean value label (default small)
*!   decimals(#)        decimals shown for means/diff (default 1)
*!   labsize(string)    text size of the diff/p (or stars) bracket label
*!
*! ---- axes, titles, output ----
*!   ytitle/xtitle/title(string)   titles (default y/x = variable labels)
*!   ylabel(string)     full y-axis label spec (e.g. ylabel(0(20)100, grid))
*!   xlabel(string)     EXTRA x-axis label suboptions (group labels kept)
*!   saving(string)     export path (e.g. "$out/fig.png")
*!   name(string)       graph window name (default barttest)

program define barttest
    version 16.0
    syntax varname(numeric) [if] [in], by(varname)                       ///
        [                                                                ///
          Compare(string) BASE(string) STARs                            /// comparisons
          Level(real 95) Alpha(real 0.05)                               /// significance
          PANel(varname) COLs(integer 0) YCOMMON YTOPForce(real -1)     /// faceting
          BARWidth(real 0.6) BARcolor(string)                           /// bars
          BYColors(string asis) COLORS(string asis) CAPcolor(string)    /// colours
          NOVALues VALPos(string) VALSize(string) Decimals(integer 1)   /// value labels
          LABSize(string)                                               ///
          title(string asis) ytitle(string asis) xtitle(string asis)    /// titles
          YLABel(string asis) XLABel(string asis)                       /// axes
          saving(string) name(string) ]

    local dv `varlist'
    local gv `by'

    * bycolors() is the documented name; colors() kept as backward-compatible alias
    if `"`bycolors'"'=="" local bycolors `"`colors'"'
    local colors `"`bycolors'"'

    * =====================================================
    * PANEL MODE: draw one barttest per level of panel()
    * and combine them into a single faceted graph.
    * =====================================================
    if "`panel'" != "" {
        if "`name'" == "" local name "barttest"
        tempvar ptouse
        marksample ptouse, novarlist
        markout `ptouse' `dv' `gv' `panel'
        quietly levelsof `panel' if `ptouse', local(plevs)
        local npan : word count `plevs'
        if `cols'==0 {
            if `npan'<=2 local cols = `npan'
            else if `npan'<=4 local cols = 2
            else local cols = 3
        }
        * collect passthrough options
        local opts `"level(`level') alpha(`alpha') barwidth(`barwidth') decimals(`decimals')"'
        if "`compare'"!=""   local opts `"`opts' compare(`compare')"'
        if "`base'"!=""      local opts `"`opts' base(`base')"'
        if "`stars'"!=""     local opts `"`opts' stars"'
        if "`novalues'"!=""  local opts `"`opts' novalues"'
        if "`valpos'"!=""    local opts `"`opts' valpos(`valpos')"'
        if "`valsize'"!=""   local opts `"`opts' valsize(`valsize')"'
        if "`labsize'"!=""   local opts `"`opts' labsize(`labsize')"'
        if "`barcolor'"!=""  local opts `"`opts' barcolor(`barcolor')"'
        if `"`colors'"'!=""  local opts `"`opts' colors(`colors')"'
        if "`capcolor'"!=""  local opts `"`opts' capcolor(`capcolor')"'
        if `"`ytitle'"'!=""  local opts `"`opts' ytitle(`"`ytitle'"')"'
        if `"`xtitle'"'!=""  local opts `"`opts' xtitle(`"`xtitle'"')"'
        if `"`ylabel'"'!=""  local opts `"`opts' ylabel(`"`ylabel'"')"'
        if `"`xlabel'"'!=""  local opts `"`opts' xlabel(`"`xlabel'"')"'

        * ycommon: give every panel the SAME y-axis top so bar heights match.
        * Derive it from the global CI-upper max and the largest number of
        * brackets drawn in any panel (so the tallest stack still fits).
        if "`ycommon'"!="" {
            * global upper bound of the data/CI across all panels
            tempvar ghi
            quietly gen double `ghi' = .
            quietly levelsof `gv' if `ptouse', local(_gg)
            local gymax = .
            foreach pl of local plevs {
                foreach gg of local _gg {
                    quietly ci means `dv' if `ptouse' & `panel'==`pl' & `gv'==`gg', level(`level')
                    if r(ub) > `gymax' | `gymax'==. local gymax = r(ub)
                }
            }
            * max number of comparisons across panels
            quietly levelsof `gv' if `ptouse', local(_gg)
            local kk : word count `_gg'
            if "`base'"!=""        local ncmax = `kk' - 1
            else if "`compare'"!="" {
                local ncmax : word count `compare'
            }
            else                   local ncmax = `kk' - 1
            * replicate the main-flow geometry: span=gymax, step=span*0.11
            local gspan = `gymax'
            local gstep = `gspan'*0.11
            local gbase = `gymax' + `gstep'*0.6
            local gytop = `gbase' + `ncmax'*`gstep' + `gspan'*0.05
            local opts `"`opts' ytopforce(`gytop')"'
        }

        local subnames ""
        local j = 0
        foreach pl of local plevs {
            local ++j
            local plab : label (`panel') `pl'
            if `"`plab'"'=="" local plab "`pl'"
            local sub`j' "_bt_panel`j'"
            barttest `dv' if `panel'==`pl' & `ptouse', by(`gv') `opts' ///
                title("`plab'") name(`sub`j'')
            local subnames `subnames' `sub`j''
        }
        graph combine `subnames', cols(`cols') ///
            `=cond("`ycommon'"=="","","ycommon")' ///
            `=cond(`"`title'"'=="","",`"title(`"`title'"')"')' ///
            graphregion(color(white)) name(`name', replace)
        if `"`saving'"' != "" {
            quietly graph export `"`saving'"', replace width(2600)
            di as result "saved: `saving'"
        }
        exit
    }

    marksample touse
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
    local ylabauto = 0
    if `"`ylabel'"' == "" {
        local ylabel ", angle(0)"
        local ylabauto = 1
    }
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
        * resolve this bar's colour: default = barcolor; an explicit
        * colors("group=colour") mapping overrides it (key = value label or value)
        local gcol`g' "`barcolor'"
        if `"`colors'"'!="" {
            foreach kv of local colors {
                local eq = strpos(`"`kv'"',"=")
                if `eq' {
                    local kk = substr(`"`kv'"',1,`eq'-1)
                    local cc = substr(`"`kv'"',`eq'+1,.)
                    if `"`kk'"'==`"`vl'"' | `"`kk'"'=="`g'" local gcol`g' `"`cc'"'
                }
            }
        }
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

    * default y-axis: start at 0 with a tidy step up to the data max (CI upper)
    if `ylabauto' {
        if      `ymax' <= 10  local ystep = 2
        else if `ymax' <= 20  local ystep = 5
        else if `ymax' <= 50  local ystep = 10
        else if `ymax' <= 100 local ystep = 20
        else if `ymax' <= 200 local ystep = 50
        else                  local ystep = round(`ymax'/5)
        local ytick = `ystep'*ceil(`ymax'/`ystep')
        local ylabel "0(`ystep')`ytick', angle(0)"
    }

    * ---- build twoway layers ----
    local fmt "%9.`decimals'f"
    * one bar layer per group so each can take its own colour (see colors())
    local plot ""
    local bi = 0
    foreach g of local glevs {
        local ++bi
        local plot `"`plot' (bar `mean' `xpos' if _n==`bi', barwidth(`barwidth') color("`gcol`g''")) "'
    }
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
            else {   /* inbar: vertically centered in the bar */
                local ty = `m`g''/2
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
    * common-height override (set by panel + ycommon)
    if `ytopforce' > 0 local ytop = `ytopforce'

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
