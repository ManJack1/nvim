local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local types = require("luasnip.util.types")
local parse = require("luasnip.util.parser").parse_snippet
local ms = ls.multi_snippet

local rec_ls
rec_ls = function()
  return sn(nil, {
    c(1, {
      -- important!! Having the sn(...) as the first choice will cause infinite recursion.
      t({ "" }),
      -- The same dynamicNode as in the snippet (also note: self reference).
      sn(nil, { t({ "", "\t\\item " }), i(1), d(2, rec_ls, {}) }),
    }),
  });
end

local tex = {}
tex.in_mathzone = function()
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end
tex.in_text = function()
  return not tex.in_mathzone()
end


table_node = function(args)
  local tabs = {}
  local count
  table = args[1][1]:gsub("%s", ""):gsub("|", "")
  count = table:len()
  for j = 1, count do
    local iNode
    iNode = i(j)
    tabs[2 * j - 1] = iNode
    if j ~= count then
      tabs[2 * j] = t " & "
    end
  end
  return sn(nil, tabs)
end

rec_table = function()
  return sn(nil, {
    c(1, {
      t({ "" }),
      sn(nil, { t { "\\\\", "" }, d(1, table_node, { ai[1] }), d(2, rec_table, { ai[1] }) })
    }),
  });
end


-- Some LaTeX-specific conditional expansion functions (requires VimTeX)

local tex_utils = {}
tex_utils.in_mathzone = function() -- math context detection
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end
tex_utils.in_text = function()
  return not tex_utils.in_mathzone()
end
tex_utils.in_comment = function() -- comment detection
  return vim.fn['vimtex#syntax#in_comment']() == 1
end
tex_utils.in_env = function(name) -- generic environment detection
  local is_inside = vim.fn['vimtex#env#is_inside'](name)
  return (is_inside[1] > 0 and is_inside[2] > 0)
end
-- A few concrete environments---adapt as needed
tex_utils.in_equation = function() -- equation environment detection
  return tex_utils.in_env('equation')
end
tex_utils.in_itemize = function() -- itemize environment detection
  return tex_utils.in_env('itemize')
end
tex_utils.in_tikz = function() -- TikZ picture environment detection
  return tex_utils.in_env('tikzpicture')
end


return {
  s("table", {
    t "\\begin{tabular}{",
    i(1, "0"),
    t { "}", "" },
    d(2, table_node, { 1 }, {}),
    d(3, rec_table, { 1 }),
    t { "", "\\end{tabular}" }
  }),

  s({ trig = "11", snippetType = "autosnippet" },
    fmta("\\left\\{ <>\\right\\}<>", { i(1), i(2), }), { condition = tex_utils.in_mathzone }
  ),
  s("ls", {
    t({ "\\begin{itemize}",
      "\t\\item " }), i(1), d(2, rec_ls, {}),
    t({ "", "\\end{itemize}" }), i(0)
  }),
  s("dm", {
    t({ "\\[", "\t" }),
    i(1),
    t({ "", "\\]" }),
  }, { condition = tex.in_text }),

  s({ trig = "ff", dscr = "Expands 'ff' into '\frac{}{}'" },
    {
      t("\\frac{"),
      i(1), -- insert node 1
      t("}{"),
      i(2), -- insert node 2
      t("}")
    }
  ),
  s({ trig = "eq", dscr = "A LaTeX equation environment" },
    fmt( -- The snippet code actually looks like the equation environment it produces.
      [[
      \begin{equation}
          <>
      \end{equation}
    ]],
      -- The insert node is placed in the <> angle brackets
      { i(1) },
      -- This is where I specify that angle brackets are used as node positions.
      { delimiters = "<>" }
    )
  ),
  s({ trig = "env", snippetType = "autosnippet" },
    fmta(
      [[
      \begin{<>}
          <>
      \end{<>}
    ]],
      {
        i(1),
        i(2),
        rep(1), -- this node repeats insert node i(1)
      }
    )
  ),
  s({ trig = "il", dscr = "A latex Interline env" },
    fmta(
      [[$<>$]],
      { i(1) }
    )
  ),

  -----math-notion
  s({ trig = "ol", dscr = "A latex overline" },
    fmta(
      [[\overline{<>}]],
      { i(1) }
    )
  ),

  s({ trig = "ob", dscr = "A latex overbar" },
    fmta(
      [[\overbar{<>}]],
      { i(1) }
    )
  ),



  s({ trig = "sum", dscr = "A latex sum notion" },
    fmta(
      [[\sum_{<>}^{<>}]],
      { i(1), i(2) }
    )
  ),

  s(
    { trig = "sqrt", dscr = "A sqrt in math-notion" },
    fmta(
      [[\sqrt{<>}]],
      { i(1) }
    )
  ),

  s(
    { trig = "obrace", dscr = "The overbrace of latex" },
    fmta(
      [[\overbrace{<>}^{<>}]],
      { i(1), i(2) }
    )
  ),

  s(
    { trig = "ubrace", dscr = "The underbrace of latex" },
    fmta(
      [[\underbrace{<>}_{<>}]],
      { i(1), i(2) }
    )
  ),


  s({ trig = "basic-e", dscr = "This is basic template of latex" }, fmta(
    [[
\documentclass[11pt, a4paper, oneside]{book}
\usepackage{amsmath, amsthm, amssymb, bm, graphicx, hyperref, mathrsfs}
\usepackage[dvipsnames]{xcolor}
\usepackage{tikz}
\usetikzlibrary{backgrounds}
\usetikzlibrary{arrows,shapes}
\usetikzlibrary{tikzmark}
\usetikzlibrary{calc}
\usepackage{graphicx}
\usepackage{annotate-equations}
\usepackage{geometry}
\geometry{
 a4paper,
 total={170mm,257mm},
 left=20mm,
 top=20mm,
 }


\usepackage{geometry}
\geometry{
 a4paper,
 total={170mm,257mm},
 left=20mm,
 top=20mm,
 }

%setting annotate
\renewcommand{\eqnannotationfont}{\bfseries\small}
\usepackage{titlesec}
\titleformat{\section}[hang]{\normalfont\Large\bfseries}{\thesection}{1em}{}
\titlespacing{\section}{0pt}{\baselineskip}{0.5\baselineskip}


%colorbox
\newcommand{\hlmath}[2]{\colorbox{#1!17}{$\displaystyle #2$}}
%\newcommand{\highlight}[2]{\colorbox{#1!17}{$#2$}}
\newcommand{\hltext}[2]{\colorbox{#1!47}{$\displaystyle #2$}}

%setting mathenv
\newtheorem{theorem}{Theorem}
\newtheorem{definition}{Definition}
\newtheorem{proposition}{Proposition}
\newtheorem{example}{Example}
\newtheorem{note}{Note}
\newtheorem{remark}{Remark}


title{{\Huge{\textbf{NoteTitle}}}\\--subtitle}
\author{ManJack}
\date{\today}
\linespread{1.5}


\begin{document}

\maketitle

\pagenumbering{roman}
\setcounter{page}{1}
\newpage
\begin{center}
    \Huge\textbf{preface}
\end{center}~\

There is a location for preface
~\\
\begin{flushright}
    \begin{tabular}{c}
        ManJack\\
        \today
    \end{tabular}
\end{flushright}

\newpage
\pagenumbering{Roman}
\setcounter{page}{1}
\tableofcontents
\newpage
\setcounter{page}{1}
\pagenumbering{arabic}

<>

\end{document}

   ]], { i(1) }
  )
  ),
  s({ trig = "basic-c", dscr = "This is chinese template" }, fmta(
    [[
%!TEX program = xelatex
\documentclass[11pt, a4paper, oneside,UTF8]{ctexbook}
\usepackage{amsmath, amsthm, amssymb, bm, graphicx, hyperref, mathrsfs}
\usepackage[dvipsnames]{xcolor}
\usepackage{tikz}
\usetikzlibrary{backgrounds}
\usetikzlibrary{arrows,shapes}
\usetikzlibrary{tikzmark}
\usetikzlibrary{calc}
\usepackage{graphicx}
\usepackage{geometry}
\usepackage{annotate-equations}
\geometry{
 a4paper,
 total={170mm,257mm},
 left=20mm,
 top=20mm,
 }

%setting annotate
\renewcommand{\eqnannotationfont}{\bfseries\small}
\usepackage{titlesec}
\titleformat{\section}[hang]{\normalfont\Large\bfseries}{\thesection}{1em}{}
\titlespacing{\section}{0pt}{\baselineskip}{0.5\baselineskip}



%colorbox
\newcommand{\hlmath}[2]{\colorbox{#1!17}{$\displaystyle #2$}}
%\newcommand{\highlight}[2]{\colorbox{#1!17}{$#2$}}
\newcommand{\hltext}[2]{\colorbox{#1!47}{$\displaystyle #2$}}



%setting mathenv
\newtheorem{theorem}{\indent 定理}[section]
\newtheorem{lemma}[theorem]{\indent 引理}
\newtheorem{proposition}[theorem]{\indent 命题}
\newtheorem{corollary}[theorem]{\indent 推论}
\newtheorem{definition}{\indent 定义}[section]
\newtheorem{example}{\indent 例}[section]
\newtheorem{remark}{\indent 注}[section]
\newenvironment{solution}{\begin{proof}[\indent\bf 解]}{\end{proof}}
\renewcommand{\proofname}{\indent\bf 证明}


\title{{\Huge{\textbf{你好}}}\\--副标题}
\author{ManJack}
\date{\today}
\linespread{1.5}


\begin{document}

\maketitle

\pagenumbering{roman}
\setcounter{page}{1}
\newpage
\begin{center}
    \Huge\textbf{前言}
\end{center}~\

这是前言的地方
~\\
\begin{flushright}
    \begin{tabular}{c}
        ManJack\\
        \today
    \end{tabular}
\end{flushright}

\newpage
\pagenumbering{Roman}
\setcounter{page}{1}
\tableofcontents
\newpage
\setcounter{page}{1}
\pagenumbering{arabic}

<>


\end{document}]],
    { i(1) }
  )),

  s({ trig = 'tb', dscr = "textbf of latex" }, fmta(
    [[\textbf{<>}]],
    { i(1) }
  ))

}
