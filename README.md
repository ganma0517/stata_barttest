# barttest

A Stata command that draws a **bar chart of group means with confidence-interval
error bars and pairwise t-test brackets**. Significant differences are drawn with
a **solid** bracket, non-significant ones with a **dashed** bracket; each bracket
is labeled with the mean difference and the p-value (or significance stars).

**No control group** (adjacent comparisons) vs **with a control group** (every group vs. a reference):

| No control group | With control group |
|---|---|
| ![no control](example_no_control.png) | ![with control](example_with_control.png) |

## Requirements

- Stata 16 or newer

## Installation

### Option A — `net install` (recommended)

```stata
net install barttest, from("https://raw.githubusercontent.com/ganma0517/stata_barttest/main/") replace
```

### Option B — `github install`

Requires the community `github` command (`ssc install github` once), then:

```stata
github install ganma0517/stata_barttest
```

After installing, read the help and run the example:

```stata
help barttest
do barttest_example.do
```

## Quick start

A practice dataset is included: **four groups** where adjacent comparisons are a
mix of significant and non-significant (1 vs 2 ns, 2 vs 3 significant, 3 vs 4 ns),
so you can see both solid and dashed brackets. Load it directly from the repo
(no install needed):

```stata
use "https://raw.githubusercontent.com/ganma0517/stata_barttest/main/barttest_demo.dta", clear
barttest outcome, by(treat)
```

Or use Stata's built-in data:

```stata
sysuse auto, clear
barttest price, by(rep78)
```

![significant example](example_significant.png)

## Examples: with vs. without a control group

```stata
sysuse auto, clear

* No control group — adjacent pairwise comparisons (default)
barttest price, by(rep78)

* No control group — pick specific pairs to compare
barttest price, by(rep78) compare("1/2 1/5 2/5")

* With a control group — every group compared to rep78==3
barttest price, by(rep78) base(3)

* With a control group + significance stars
barttest price, by(rep78) base(3) stars
```

Download the full tutorial do-file and step through it:

```stata
copy "https://raw.githubusercontent.com/ganma0517/stata_barttest/main/barttest_example.do" barttest_example.do, replace
doedit barttest_example.do
```

A solid bracket = significant difference; dashed = non-significant. See
`barttest_example.do` and `barttest_example_control.do` for runnable scripts.

## Faceting with `panel()`

Draw one sub-plot per level of another variable and combine them — ideal for
comparing the same grouping across sites, markers, time points, etc.

```stata
use "https://raw.githubusercontent.com/ganma0517/stata_barttest/main/barttest_panel_demo.dta", clear
barttest resp, by(arm) panel(site) stars

* add ycommon so bar heights are directly comparable across panels
barttest resp, by(arm) panel(site) stars ycommon
```

![panel example](example_panel.png)

## Syntax

```
barttest depvar [if] [in], by(groupvar) [options]
```

| Option | Description | Default |
|---|---|---|
| `by(varname)` | grouping variable (required) | — |
| `level(#)` | CI level for error bars | 95 |
| `alpha(#)` | solid-vs-dashed significance threshold | 0.05 |
| `compare("a/b c/d")` | pairs to test, using group values | adjacent pairs |
| `base(#)` | reference group; compare all others to it | — |
| `stars` | label brackets with `* ** ***` / `ns` | off (shows p) |
| `panel(varname)` | facet: one sub-plot per level | — |
| `cols(#)` | columns when faceting | auto |
| `ycommon` | shared y-axis across panels (matching bar heights) | off |
| `barwidth(#)` | bar width | 0.6 |
| `barcolor()` `capcolor()` | bar / error-bar colors | navy / red |
| `decimals(#)` | decimals for means and diff | 1 |
| `novalues` | hide the mean value label on each bar | off |
| `valpos()` | value-label position: `top` / `mean` / `inbar` (centered) | top |
| `valsize()` | mean value-label text size | small |
| `labsize()` | diff/p (or stars) bracket-label text size | auto |
| `title()` `ytitle()` `xtitle()` | titles | variable labels |
| `ylabel()` | full y-axis label spec | `, angle(0)` |
| `xlabel()` | extra x-axis label suboptions | — |
| `saving()` | export path (e.g. `fig.png`) | — |
| `name()` | graph window name | `barttest` |

See `help barttest` for full documentation and examples.

## Files

- `barttest.ado` — the command
- `barttest.sthlp` — Stata help file
- `barttest_example.do` — runnable examples (uses built-in `auto` data)
- `barttest_example_control.do` — with vs. without a control group
- `barttest_demo.dta` — practice data with significant group differences
- `example_no_control.png`, `example_with_control.png`, `example_significant.png` — demo figures
- `barttest.pkg`, `stata.toc` — package metadata for `net install`

## About the author

I am Wen-Cheng Lin, a PhD student in the Department of Political Science at
National Chengchi University, currently serving as a postdoctoral research fellow
at the Institute of Sociology, Academia Sinica. This package is a collaboration
between me and Claude. It is still at an experimental stage and is intended mainly
for presenting results from survey-experiment designs. If you have any questions,
you are warmly welcome to get in touch — beck740517@gmail.com

我是林文正，政治大學政治學系博士生，目前在中央研究院社會學研究所擔任博士後研究員。
本套件是我與 Claude 的協作成果，目前仍屬實驗性階段，主要用於調查實驗法（survey experiment）的
資訊呈現。若有任何問題，歡迎寫信與我交流。

## Citation

Lin, Wen-Cheng (2026). *barttest: Bar chart of group means with CI and pairwise
t-test brackets.* https://github.com/ganma0517/stata_barttest

## License

MIT — see [LICENSE](LICENSE).
