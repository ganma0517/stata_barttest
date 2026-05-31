{smcl}
{* *! version 1.3  30may2026}{...}
{vieweralsosee "ttest" "help ttest"}{...}
{vieweralsosee "ci" "help ci"}{...}
{vieweralsosee "graph bar" "help graph bar"}{...}
{vieweralsosee "twoway" "help twoway"}{...}
{viewerjumpto "Syntax" "barttest##syntax"}{...}
{viewerjumpto "Description" "barttest##description"}{...}
{viewerjumpto "Options" "barttest##options"}{...}
{viewerjumpto "Examples" "barttest##examples"}{...}
{viewerjumpto "Author" "barttest##author"}{...}
{title:Title}

{phang}
{bf:barttest} {hline 2} Bar chart of group means with CI error bars and pairwise t-test brackets


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:barttest}
{it:depvar}
{ifin}
{cmd:,}
{opth by(varname)}
[{it:options}]

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{p2coldent:* {opth by(varname)}}grouping variable (required){p_end}
{synopt:{opt level(#)}}confidence level for CI error bars; default is {cmd:level(95)}{p_end}
{synopt:{opt alpha(#)}}significance threshold: solid bracket if p<alpha, dashed otherwise; default {cmd:alpha(0.05)}{p_end}

{syntab:Comparisons}
{synopt:{opt compare(string)}}space-separated pairs {cmd:"a/b c/d ..."} using group {it:values}; default = adjacent pairs{p_end}
{synopt:{opt base(#)}}reference group: compare every other group against it (overrides {opt compare()}){p_end}
{synopt:{opt stars}}label brackets with significance stars (* ** ***, ns) instead of the p-value{p_end}

{syntab:Appearance}
{synopt:{opt barw:idth(#)}}bar width; default is {cmd:barwidth(0.6)}{p_end}
{synopt:{opt barc:olor(string)}}bar fill color; default is {cmd:"26 71 95"}{p_end}
{synopt:{opt capc:olor(string)}}error-bar color; default is {cmd:red}{p_end}
{synopt:{opt d:ecimals(#)}}decimals shown for means and diff; default is {cmd:decimals(1)}{p_end}
{synopt:{opt noval:ues}}do not print the mean value label on each bar{p_end}
{synopt:{opt valp:os(string)}}position of mean value label: {cmd:top} (default), {cmd:mean}, or {cmd:inbar} (centered in the bar){p_end}
{synopt:{opt vals:ize(string)}}text size of mean value label; default {cmd:small}{p_end}
{synopt:{opt labs:ize(string)}}text size of the diff/p (or stars) bracket label{p_end}
{synopt:{opt title(string)}}graph title{p_end}
{synopt:{opt ytitle(string)}}y-axis title; default = {it:depvar} label{p_end}
{synopt:{opt xtitle(string)}}x-axis title; default = {it:groupvar} label{p_end}
{synopt:{opt ylab:el(string)}}full y-axis label spec; default {cmd:", angle(0)"}{p_end}
{synopt:{opt xlab:el(string)}}extra x-axis label suboptions (group position labels are always kept){p_end}

{syntab:Saving}
{synopt:{opt saving(string)}}export the graph to this path (e.g. {cmd:"$out/fig.png"}){p_end}
{synopt:{opt name(string)}}graph window name; default {cmd:barttest}{p_end}
{synoptline}
{p 4 6 2}* {opt by()} is required.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:barttest} draws a bar chart of the mean of {it:depvar} for each level of the
grouping variable, overlays confidence-interval error bars, and adds brackets
between selected group pairs annotated with a two-sample {help ttest:t-test}.
A {bf:solid} bracket marks a significant difference (p < {it:alpha}); a
{bf:dashed} bracket marks a non-significant difference. Each bracket is labeled
with the mean difference and either the p-value or significance stars.

{pstd}
Group means and CIs are computed with {help ci:ci means} at the requested
{opt level()}; pairwise comparisons use {help ttest:ttest}.


{marker options}{...}
{title:Options}

{phang}{opth by(varname)} specifies the grouping variable. Required. Value
labels, if present, are used for the x-axis tick labels.

{phang}{opt level(#)} sets the confidence level for the error bars. Default 95.

{phang}{opt alpha(#)} is the significance threshold that decides solid vs dashed
brackets. Default 0.05.

{phang}{opt compare(string)} lists the pairs to test, separated by spaces, each
pair as {cmd:a/b} using the group {it:values} (not labels), e.g.
{cmd:compare("1/2 2/3 1/3")}. Default compares adjacent groups in sorted order.

{phang}{opt base(#)} sets a reference group; every other group is compared
against it. Overrides {opt compare()}.

{phang}{opt stars} labels brackets with stars ({cmd:*} p<.05, {cmd:**} p<.01,
{cmd:***} p<.001, {cmd:ns} otherwise) instead of the numeric p-value.

{phang}{opt barwidth(#)} sets bar width. Default 0.6.

{phang}{opt barcolor(string)} / {opt capcolor(string)} set the bar and error-bar
colors.

{phang}{opt decimals(#)} controls decimals for means and differences. Default 1.

{phang}{opt novalues} hides the mean value label on each bar.

{phang}{opt valpos(string)} sets where the mean value label is drawn:
{cmd:top} (above the CI, default), {cmd:mean} (at the bar top), or
{cmd:inbar} (inside the bar near the top, in white).

{phang}{opt valsize(string)} sets the text size of the mean value label
(e.g. {cmd:vsmall}, {cmd:small}, {cmd:medium}). Default {cmd:small}.

{phang}{opt labsize(string)} sets the text size of the bracket (diff/p or stars)
label, overriding the automatic default.

{phang}{opt title(string)}, {opt ytitle(string)}, {opt xtitle(string)} set the
graph and axis titles. Surrounding quotes you type are handled automatically.

{phang}{opt ylabel(string)} passes a full y-axis label specification, e.g.
{cmd:ylabel(0(20)100, angle(0) grid)}. To pass only suboptions, prefix a comma:
{cmd:ylabel(, labsize(small))}. By default the y-axis starts at 0 with a tidy
step (bars are not visually exaggerated); pass your own {opt ylabel()} to override.

{phang}{opt xlabel(string)} appends extra suboptions to the x-axis labels; the
group position labels are always kept. e.g. {cmd:xlabel(labsize(small) angle(45))}.

{phang}{opt saving(string)} exports the graph (format from the file extension).
{opt name(string)} sets the graph window name.


{marker examples}{...}
{title:Examples}

{pstd}Load the bundled practice data (4 groups; mixed significance){p_end}
{phang2}{cmd:. use "https://raw.githubusercontent.com/ganma0517/stata_barttest/main/barttest_demo.dta", clear}{p_end}

{pstd}{bf:Basics}{p_end}
{phang2}{cmd:. barttest outcome, by(treat)}                {it:// adjacent pairs, p-values}{p_end}
{phang2}{cmd:. barttest outcome, by(treat) stars}          {it:// significance stars}{p_end}
{phang2}{cmd:. barttest outcome, by(treat) level(90)}      {it:// 90% CI}{p_end}
{phang2}{cmd:. barttest outcome, by(treat) alpha(0.01) stars}  {it:// stricter threshold}{p_end}

{pstd}{bf:Choosing comparisons}{p_end}
{phang2}{cmd:. barttest outcome, by(treat) compare("1/2 3/4")}{p_end}
{phang2}{cmd:. barttest outcome, by(treat) compare("1/2 1/3 1/4 2/3 2/4 3/4")}{p_end}
{phang2}{cmd:. barttest outcome, by(treat) base(1)}        {it:// every group vs control}{p_end}
{phang2}{cmd:. barttest outcome, by(treat) base(1) stars}{p_end}

{pstd}{bf:Value labels on bars}{p_end}
{phang2}{cmd:. barttest outcome, by(treat) novalues}{p_end}
{phang2}{cmd:. barttest outcome, by(treat) valpos(inbar)}  {it:// inside bar, centered}{p_end}
{phang2}{cmd:. barttest outcome, by(treat) valpos(mean)}{p_end}
{phang2}{cmd:. barttest outcome, by(treat) valsize(medium) decimals(2)}{p_end}

{pstd}{bf:Titles and axes}{p_end}
{phang2}{cmd:. barttest outcome, by(treat) title("Score by group") ytitle("Mean") xtitle("Group")}{p_end}
{phang2}{cmd:. barttest outcome, by(treat) labsize(medium)}{p_end}
{phang2}{cmd:. barttest outcome, by(treat) ylabel(0(20)80, angle(0) grid)}{p_end}
{phang2}{cmd:. barttest outcome, by(treat) xlabel(labsize(small) angle(20))}{p_end}

{pstd}{bf:Appearance}{p_end}
{phang2}{cmd:. barttest outcome, by(treat) barwidth(0.5)}{p_end}
{phang2}{cmd:. barttest outcome, by(treat) barcolor(navy) capcolor(maroon)}{p_end}

{pstd}{bf:Everything together, then save}{p_end}
{phang2}{cmd:. barttest outcome, by(treat) stars valpos(inbar) valsize(medium) labsize(medium) ytitle("Test score") ylabel(0(20)80, angle(0) grid) saving(fig.png)}{p_end}

{pstd}A full, runnable tutorial is in {bf:barttest_example.do} (see the repo).{p_end}


{marker author}{...}
{title:Author}

{pstd}{bf:Wen-Cheng Lin (林文正)}{break}
PhD student, Department of Political Science, National Chengchi University{break}
Postdoctoral research fellow, Institute of Sociology, Academia Sinica{break}
Email: beck740517@gmail.com{break}
{browse "https://github.com/ganma0517/stata_barttest":github.com/ganma0517/stata_barttest}{p_end}

{pstd}This package is a collaboration between the author and Claude. It is still
at an experimental stage and is intended mainly for presenting results from
survey-experiment designs. Questions and feedback are very welcome.{p_end}

{pstd}本套件是作者與 Claude 的協作成果，目前仍屬實驗性階段，主要用於調查實驗法的資訊呈現。
若有任何問題，歡迎來信交流：beck740517@gmail.com{p_end}
