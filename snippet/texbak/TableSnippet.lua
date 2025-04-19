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

local mat = function(args, snip)
  local rows = tonumber(snip.captures[2])
  local cols = tonumber(snip.captures[3])
  local nodes = {}
  local ins_indx = 1
  for j = 1, rows do
    table.insert(nodes, r(ins_indx, tostring(j) .. "x1", i(1)))
    ins_indx = ins_indx + 1
    for k = 2, cols do
      table.insert(nodes, t(" & "))
      table.insert(nodes, r(ins_indx, tostring(j) .. "x" .. tostring(k), i(1)))
      ins_indx = ins_indx + 1
    end
    table.insert(nodes, t({ " \\\\", "" }))
  end
  -- fix last node.
  nodes[#nodes] = t(" \\\\")
  return sn(nil, nodes)
end

-- 递归函数定义
local rec_ls
rec_ls = function()
  return sn(nil, {
    c(1, {
      -- 添加一个空选项以避免无限递归
      t({ "" }),
      -- 递归调用
      sn(nil, { t({ "", "\t\\item " }), i(1), d(2, rec_ls, {}) }),
    }),
  })
end

local tex = {}
tex.in_mathzone = function()
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
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
      tabs[2 * j] = t(" & ")
    end
  end
  return sn(nil, tabs)
end

rec_table = function()
  return sn(nil, {
    c(1, {
      t({ "" }),
      sn(nil, { t({ "\\\\", "" }), d(1, table_node, { ai[1] }), d(2, rec_table, { ai[1] }) }),
    }),
  })
end

-- Some LaTeX-specific conditional expansion functions (requires VimTeX)

local tex_utils = {}
tex_utils.in_mathzone = function() -- math context detection
  return vim.fn["vimtex#syntax#in_mathzone"]() == 1
end
tex_utils.in_text = function()
  return not tex_utils.in_mathzone()
end
tex_utils.in_comment = function() -- comment detection
  return vim.fn["vimtex#syntax#in_comment"]() == 1
end
tex_utils.in_env = function(name) -- generic environment detection
  local is_inside = vim.fn["vimtex#env#is_inside"](name)
  return (is_inside[1] > 0 and is_inside[2] > 0)
end
-- A few concrete environments---adapt as needed
tex_utils.in_equation = function() -- equation environment detection
  return tex_utils.in_env("equation")
end
tex_utils.in_itemize = function() -- itemize environment detection
  return tex_utils.in_env("itemize")
end
tex_utils.in_tikz = function() -- TikZ picture environment detection
  return tex_utils.in_env("tikzpicture")
end

return {

  s("table", {
    t("\\begin{tabular}{"),
    i(1, "0"),
    t({ "}", "" }),
    d(2, table_node, { 1 }, {}),
    d(3, rec_table, { 1 }),
    t({ "", "\\end{tabular}" }),
  }),

  s("trig8", {
    t("text: "),
    i(1),
    t({ "", "copy: " }),
    d(2, function(args)
      -- the returned snippetNode doesn't need a position; it's inserted
      -- "inside" the dynamicNode.
      return sn(nil, {
        -- jump-indices are local to each snippetNode, so restart at 1.
        i(1, args[1]),
      })
    end, { 1 }),
  }),
  s(
    { trig = "11", snippetType = "autosnippet" },
    fmta("\\left\\{ <>\\right\\}<>", { i(1), i(2) }),
    { condition = tex_utils.in_mathzone }
  ),
  s("ls", {
    t({ "\\begin{itemize}", "\t\\item " }),
    i(1),
    d(2, rec_ls, {}),
    t({ "", "\\end{itemize}" }),
    i(0),
  }),
  s("dm", {
    t({ "\\[", "\t" }),
    i(1),
    t({ "", "\\]" }),
  }, { condition = tex.in_text }),

  s({ trig = "ff", dscr = "Expands 'ff' into '\frac{}{}'" }, {
    t("\\frac{"),
    i(1), -- insert node 1
    t("}{"),
    i(2), -- insert node 2
    t("}"),
  }),
  s(
    { trig = "eq", dscr = "A LaTeX equation environment" },
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
  s(
    { trig = "env", snippetType = "autosnippet" },
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
  s({ trig = "il", dscr = "A latex Interline env" }, fmta([[$<>$]], { i(1) })),

  -----math-notion
  s({ trig = "ol", dscr = "A latex overline" }, fmta([[\overline{<>}]], { i(1) })),

  s({ trig = "ob", dscr = "A latex overbar" }, fmta([[\overbar{<>}]], { i(1) })),

  -- s({ trig = "sum", dscr = "A latex sum notion" }, fmta([[\sum_{<>}^{<>}]], { i(1), i(2) })),

  s({ trig = "sqrt", dscr = "A sqrt in math-notion" }, fmta([[\sqrt{<>}]], { i(1) })),

  s({ trig = "obrace", dscr = "The overbrace of latex" }, fmta([[\overbrace{<>}^{<>}]], { i(1), i(2) })),

  s({ trig = "ubrace", dscr = "The underbrace of latex" }, fmta([[\underbrace{<>}_{<>}]], { i(1), i(2) })),

  s(
    { trig = "basic-e", dscr = "This is basic template of latex" },
    fmta(
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
\usepackage{thmbox}
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
\newtheorem[M]{theorem}{Theorem}[section]
\newtheorem[M]{lemma}[theorem]{Lemma}
\newtheorem[M]{proposition}[theorem]{Proposition}
\newtheorem[M]{corollary}[theorem]{Corollary}
\newtheorem[M]{definition}{Definition}[section]
\newtheorem[M]{example}{Example}[section]
\newtheorem[M]{remark}{Remark}[section]




\title{{\Huge{\textbf{NoteTitle}}}\\--subtitle}
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

   ]],
      { i(1) }
    )
  ),
  s(
    { trig = "basic-c", dscr = "This is chinese template" },
    fmta(
      [[
%!TEX program = xelatex
% !TEX options = --shell-escape
\documentclass[11pt, a4paper, oneside, UTF8]{ctexbook}
\usepackage{amsmath, amsthm, amssymb, bm, graphicx, hyperref, mathrsfs}
\usepackage[dvipsnames]{xcolor}
\usepackage{tikz}
\usetikzlibrary{backgrounds,arrows,shapes,tikzmark,calc}
\usepackage{geometry}
\usepackage{annotate-equations}
\usepackage{extarrows}
\usepackage{thmbox}

\usepackage{svg}
\usepackage{graphicx}

\newcommand{\diff}{\mathrm{d}}
% Custom environments and commands
\newenvironment{note}
{\par\textcolor{blue}{\bfseries Note:}\itshape}{\par}
\newenvironment{remark}
{\par\textcolor{blue}{\bfseries Remark:}\itshape}{\par}
\newtheorem[M]{theorem}{Theorem}[section]
\newtheorem[M]{lemma}[theorem]{Lemma}
\newtheorem[M]{definition}{Definition}[section]
\newtheorem{example}{Example}[section]
\renewcommand{\eqnannotationfont}{\bfseries\small}

\title{{\Huge{\textbf{Linear Algebra}}}\\------HOFFMAN AND RAY KUNZE}
\author{ManJack}
\date{\today}
\linespread{1.5}

\geometry{
  a4paper,
  total={170mm,257mm},
  left=20mm,
  top=20mm,
}

\begin{document}

\maketitle

\pagenumbering{roman}
\setcounter{page}{1}

\newpage
\begin{center}
	\Huge\textbf{前言}
\end{center}

这是数学系线性代数的笔记，写给自己。如有错误请见谅，这些只是作为分享。

\begin{flushright}
	\begin{tabular}{c}
		ManJack \\
		\today
	\end{tabular}
\end{flushright}

\newpage
\tableofcontents
\newpage
\pagenumbering{arabic}
\setcounter{page}{1}

\chapter{Linear Equations}

% Start your content here


<>


\end{document}]],
      { i(1) }
    )
  ),

  s({ trig = "tb", dscr = "textbf of latex" }, fmta([[\textbf{<>}]], { i(1) })),
  s(
    { trig = "MRLE", decr = "Matrix of linear equations" },
    fmta(
      [[
\begin{align}
  A_{11}x_1 + A_{12}x_2 + \cdots + A_{1n}x_n = y_1, \\
  A_{21}x_1 + A_{22}x_2 + \cdots + A_{2n}x_n = y_2, \\
  \vdots \\
  A_{m1}x_1 + A_{m2}x_2 + \cdots + A_{mn}x_n = y_m.
\end{align}
<>
  ]],
      {
        i(1),
      }
    )
  ),
  s(
    { trig = "3mat", name = "3x3 Matrix", dscr = "Inserts a 3x3 matrix environment", snippetType = "autosnippet" },
    fmt(
      [[
      \begin{bmatrix}
      <> & <> & <> \\
      <> & <> & <> \\
      <> & <> & <>
      \end{bmatrix}
      ]],
      {
        i(1),
        i(2),
        i(3),
        i(4),
        i(5),
        i(6),
        i(7),
        i(8),
        i(9),
      },
      { delimiters = "<>" }
    ),
    { condition = tex_utils.in_mathzone }
  ),
}
