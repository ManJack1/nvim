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
local tex = require("util.tex_utils")
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
-- local rec_ls
-- rec_ls = function()
--   return sn(nil, {
--     c(1, {
--       t({ "" }),
--       sn(nil, { t({ "", "\t\\item " }), i(1), d(2, rec_ls, {}) }),
--     }),
--   })
-- end

-- 对角矩阵生成函数
local function diag_mat(args, snip)
	local size = tonumber(snip.captures[1]) -- 捕获矩阵大小（行和列相同）
	local nodes = {}
	local ins_indx = 1

	-- 遍历每一行
	for j = 1, size do
		-- 处理每行中的每列
		for k = 1, size do
			if j == k then
				-- 对角线元素
				table.insert(nodes, i(ins_indx)) -- 可编辑插入点
				ins_indx = ins_indx + 1
			else
				-- 非对角线元素为 0
				table.insert(nodes, t("0"))
			end

			if k < size then
				table.insert(nodes, t(" & "))
			end
		end

		-- 如果不是最后一行，插入换行符
		if j < size then
			table.insert(nodes, t(" \\\\ "))
		end
	end

	return sn(nil, nodes)
end

-- 动态生成矩阵的函数
local function mat(args, snip)
	-- 获取行数和列数，并确保捕获的值可以转换为数字
	local rows = tonumber(snip.captures[1])
	local cols = tonumber(snip.captures[2])

	-- 检查 rows 和 cols 是否为数字
	if not rows or not cols then
		return sn(nil, t("Error: Invalid matrix dimensions."))
	end

	-- 创建节点列表
	local nodes = {}
	local ins_indx = 1

	for j = 1, rows do
		-- 插入每行的第一个单元格
		table.insert(nodes, i(ins_indx))
		ins_indx = ins_indx + 1

		-- 插入列的其他单元格，使用 & 分隔
		for k = 2, cols do
			table.insert(nodes, t(" & "))
			table.insert(nodes, i(ins_indx))
			ins_indx = ins_indx + 1
		end

		-- 如果不是最后一行，插入换行符 \\
		if j < rows then
			table.insert(nodes, t(" \\\\ "))
		end
	end

	return sn(nil, nodes)
end

-- -- 矩阵生成函数
-- local function mat(args, snip)
--   local rows = tonumber(snip.captures[2]) -- 捕获行数
--   local cols = tonumber(snip.captures[3]) -- 捕获列数
--   local nodes = {}
--   local ins_indx = 1
--
--   -- 遍历每一行
--   for j = 1, rows do
--     -- 每行的第一个单元格
--     table.insert(nodes, i(ins_indx))
--     ins_indx = ins_indx + 1
--
--     -- 处理剩余的单元格
--     for k = 2, cols do
--       table.insert(nodes, t(" & "))
--       table.insert(nodes, i(ins_indx))
--       ins_indx = ins_indx + 1
--     end
--
--     -- 如果不是最后一行，添加换行符
--     if j < rows then
--       table.insert(nodes, t(" \\\\ "))
--     end
--   end
--
--   return sn(nil, nodes)
-- end

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

return {
	s(
		{
			trig = "(%d+)diagmat", -- 匹配形如 "3diagmat" 的触发器
			regTrig = true, -- 使用正则表达式作为触发器
			snippetType = "autosnippet",
			name = "Diagonal Matrix Generator",
			dscr = "Generates a diagonal matrix of specified size",
		},
		fmt(
			[[
\begin{{bmatrix}}
{}
\end{{bmatrix}}
  ]],
			{
				-- 动态生成对角矩阵
				d(1, diag_mat),
			}
		)
	),
	s(
		{
			trig = "(%d+)*(%d+)mat", -- 匹配行数和列数，例如 "3x3mat"
			regTrig = true, -- 正则触发器
			snippetType = "autosnippet",
			name = "Matrix Generator",
			dscr = "Generates a matrix of specified size",
		},
		fmt(
			[[
\begin{{bmatrix}}
{}
\end{{bmatrix}}
  ]],
			{
				d(1, mat), -- 动态生成矩阵内容
			}
		)
	),
	s(
		{
			trig = "([bBpvV])mat(%d+)x(%d+)", -- 匹配类似 3x3mat 的触发词
			regTrig = true, -- 使用正则触发器
			snippetType = "autosnippet",
			name = "Matrix Generator", -- 描述
			dscr = "Generates a matrix of specified size", -- 描述
		},
		fmt(
			[[
\begin{{{}matrix}}
{}
\end{{{}matrix}}
  ]],
			{
				-- 捕获并返回矩阵类型（bmatrix, pmatrix 等）
				f(function(_, snip)
					return snip.captures[1]
				end),
				-- 动态生成矩阵内容
				d(1, mat),
				-- 捕获并返回矩阵类型
				f(function(_, snip)
					return snip.captures[1]
				end),
			}
		)
	),

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
		{ condition = tex.in_mathzone }
	),

	-- s("ls", {
	--   t({ "\\begin{itemize}", "\t\\item " }),
	--   i(1),
	--   d(2, rec_ls, {}),
	--   t({ "", "\\end{itemize}" }),
	--   i(0),
	-- }),
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
		{ trig = "cheat-model" },
		fmta(
			[[
% !TEX program = xelatex
\documentclass{ctexart}
\usepackage[a4paper, margin=0.25cm]{geometry}
\usepackage{fontspec}
\usepackage{multicol}
\usepackage{amsmath,amsfonts,amsthm,amssymb,mathrsfs,bbm,mathtools,nicefrac,bm,centernot,colonequals,dsfont}
\usepackage{derivative}
\usepackage[skip=.5\baselineskip-0.5pt]{parskip}
% \usepackage[extreme, mathspacing=normal, leadingfraction=0.85]{savetrees}
\usepackage[document]{ragged2e}
\usepackage{xeCJK} % 使用 xeCJK 支持中文

\usepackage{color,soul}
\usepackage{xcolor}

\DeclareMathOperator*{\argmax}{argmax}
\DeclareMathOperator*{\argmin}{argmin}

\newcommand{\lft}{\mathopen{}\mathclose\bgroup\left}
\newcommand{\rgt}{\aftergroup\egroup\right}

\newcommand{\E}{\mathbb{E}}
\newcommand{\R}{\mathbb{R}}

\renewcommand{\vec}[1]{\mathbf{#1}}
\newcommand{\mat}[1]{#1}
\newcommand{\transpose}[1]{#1^\top}
\newcommand{\dom}[1]{\mathrm{dom}(#1)}

\renewcommand{\familydefault}{\sfdefault}

\setlength{\columnseprule}{0.4pt}

\title{<>}

\newenvironment{topic}[1]
{\textbf{\sffamily \colorbox{black}{\rlap{\textbf{\textcolor{white}{#1}}}\hspace{\linewidth}\hspace{-2\fboxsep}}} \\ \vspace{0.2cm}}
{}

\begin{document}

\setlength{\columnsep}{0.2cm}

\begin{multicols*}{2}
<>
\end{multicols*}
\end{document}
]],
			{
				i(1, "Title"),
				i(0, "Content"),
			}
		)
	),

	s(
		{ trig = "tufte_book", dscr = "This is basic tufte_book template of LaTeX" },
		fmta(
			[[
% !TEX program = xelatex
% !TEX options = --shell-escape
\documentclass[justified,nobib,openany]{tufte-book}
\usepackage{xeCJK}
\usepackage{amsmath, amsthm, amssymb, bm, graphicx, hyperref, mathrsfs}
\usepackage[dvipsnames]{xcolor}
\usepackage{tikz}
\usetikzlibrary{backgrounds,arrows,shapes,tikzmark,calc}
\usepackage{geometry}
\usepackage{annotate-equations}
\usepackage{extarrows}
\usepackage{mdframed}
\usepackage{svg}
\usepackage{fancyhdr}
\usepackage{titlesec}
\usepackage{setspace}
\usepackage{enumitem}
\usepackage{caption}
\usepackage{tocloft}

\setcounter{tocdepth}{2}
\setcounter{secnumdepth}{2}  % 设置 section 和 subsection 编号深度
% 自定义命令和环境
\newcommand{\diff}{\mathrm{d}}

\newenvironment{note}
{\par\textcolor{blue}{\bfseries Note:}\itshape}{\par}
\newenvironment{remark}
{\par\textcolor{blue}{\bfseries Remark:}\itshape}{\par}
\newenvironment{example}
{\par\textcolor{blue}{\bfseries Example:}\itshape}{\par}

\newmdtheoremenv[
  innerleftmargin=10, 
  innerrightmargin=10, 
  innertopmargin=10, 
  innerbottommargin=10, 
  linewidth=0.3pt, 
  linecolor=black, 
  shadow=true, 
  shadowsize=0.4pt, 
  shadowcolor=black
]{theorem}{Theorem}[section]

\newmdtheoremenv[
  innerleftmargin=10, 
  innerrightmargin=10, 
  innertopmargin=10, 
  innerbottommargin=10, 
  linewidth=0.3pt, 
  linecolor=black, 
  shadow=true, 
  shadowsize=0.4pt, 
  shadowcolor=black
]{lemma}[theorem]{Lemma}

\newmdtheoremenv[
  innerleftmargin=10, 
  innerrightmargin=10, 
  innertopmargin=10, 
  innerbottommargin=10, 
  linewidth=0.3pt, 
  linecolor=black, 
  shadow=true, 
  shadowsize=0.4pt, 
  shadowcolor=black
]{definition}{Definition}[section]

\newmdtheoremenv[
  innerleftmargin=10, 
  innerrightmargin=10, 
  innertopmargin=10, 
  innerbottommargin=10, 
  linewidth=0.3pt, 
  linecolor=black, 
  shadow=true, 
  shadowsize=0.4pt, 
  shadowcolor=black
]{proposition}{Proposition}[section]

\newmdtheoremenv[
  innerleftmargin=10, 
  innerrightmargin=10, 
  innertopmargin=10, 
  innerbottommargin=10, 
  linewidth=0.3pt, 
  linecolor=black, 
  shadow=true, 
  shadowsize=0.4pt, 
  shadowcolor=black
]{corollary}{Corollary}[section]

% 页眉设置
\fancyhf{}
\fancyhead[R]{\rightmark \quad\thepage}
\pagestyle{fancy}

% 章节标题格式设置
\titleformat{\chapter}[hang]
  {\normalfont\Large\bfseries}
  {\thechapter.}{1em}{}
\titlespacing*{\chapter}{0pt}{*1.5}{*1}

% 节和子节标题格式设置
\titleformat{\section}
  {\normalfont\large\bfseries}
  {\thesection}{1em}{}
\titlespacing*{\section}{0pt}{*1.5}{*1}

\titleformat{\subsection}
  {\normalfont\normalsize\bfseries}
  {\thesubsection}{1em}{}
\titlespacing*{\subsection}{0pt}{*1.5}{*1}

% 行距设置
\setstretch{1.1}

% 段落间距和缩进设置
\setlength{\parskip}{0.5em} % 段落间距
\setlength{\parindent}{1.5em} % 段落缩进

% 列表设置
\setlist{noitemsep, topsep=0pt, left=2em}

% 标题设置
\captionsetup{font=small, labelfont=bf}

\begin{document}

\begin{titlepage}
    \centering
    \vspace*{2cm}
    
    {\Huge\bfseries <>\par}
    \vspace{1.5cm}
    
    {\Large <>\par}
    \vspace{2cm}
    
    {\Large\itshape \today\par}
    
    \vfill
    
    {\large \itshape  Tufte LaTeX ------ManJack\par}
    
    \vspace*{1cm}
\end{titlepage}
% 去掉新页命令，以避免不必要的空白页
%\newpage

\pagenumbering{roman}
\setcounter{page}{1}

\begin{center}
  \Huge\textbf{前言}
\end{center}
<>

\begin{flushright}
  \begin{tabular}{c}
    <>\\
    \today
  \end{tabular}
\end{flushright}

\newpage

\tableofcontents

\newpage % 确保分页正确

\pagenumbering{arabic}
\setcounter{page}{1} % 确保章节从第 1 页开始
<>

\bibliographystyle{plain}
\bibliography{references}

\end{document}
    ]],
			{
				i(1, "插入封面标题"), -- 插入封面标题
				i(2, "插入封面作者"), -- 插入封面作者
				i(3, "插入前言内容"), -- 插入前言内容
				rep(2), -- 重复插入封面作者
				i(0, " 插入章节内容"), -- 插入章节内容
			}
		)
	),

	s(
		{ trig = "basic-e", dscr = "This is basic template of latex" },
		fmta(
			[[
\documentclass[11pt, a4paper, oneside]{book}
\usepackage{amsmath, amsthm, amssymb, bm, graphicx, hyperref, mathrsfs}
\usepackage[dvipsnames]{xcolor}
\usepackage{tikz}
\usetikzlibrary{backgrounds,arrows,shapes,tikzmark,calc}
\usepackage{annotate-equations}
\usepackage{geometry}
\usepackage{thmbox}
\usepackage{titlesec}
\usepackage{fancyhdr}

% Geometry settings
\geometry{
  a4paper,
  total={170mm,257mm},
  left=20mm,
  top=20mm,
  bottom=20mm,
  right=20mm
}

% Annotate equations settings
\renewcommand{\eqnannotationfont}{\bfseries\small}

% Section and subsection formatting
\titleformat{\section}[hang]{\normalfont\Large\bfseries}{\thesection}{1em}{}
\titlespacing{\section}{0pt}{\baselineskip}{0.5\baselineskip}

% Highlighting commands
\newcommand{\hlmath}[2]{\colorbox{#1!17}{$\displaystyle #2$}}
\newcommand{\hltext}[2]{\colorbox{#1!47}{#2}}

% Math environments
\newtheorem{theorem}{Theorem}[section]
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{proposition}[theorem]{Proposition}
\newtheorem{corollary}[theorem]{Corollary}
\newtheorem{definition}[section]{Definition}
\newtheorem{example}[section]{Example}
\newtheorem{remark}[section]{Remark}

% Page style
\fancyhf{}
\fancyhead[L]{\small\leftmark}
\fancyhead[R]{\small\thepage}
\pagestyle{fancy}

% Title settings
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
			{ i(1, "test") }
		)
	),
	s(
		{ trig = "basic-c", dscr = "This is chinese template" },
		fmta(
			[[
% !TEX program = xelatex
% !TEX options = --shell-escape
\documentclass[10pt, a4paper, oneside, UTF8]{ctexbook}
\usepackage{amsmath, amsthm, amssymb, bm, graphicx, hyperref, mathrsfs}
\usepackage[dvipsnames]{xcolor}
\usepackage{tikz}
\usetikzlibrary{backgrounds,arrows,shapes,tikzmark,calc}
\usepackage{geometry}
\usepackage{annotate-equations}
\usepackage{extarrows}
\usepackage{thmbox}
\usepackage{svg}
\usepackage{fancyhdr}
\usepackage{titlesec}
\usepackage{setspace}
\usepackage{enumitem}
\usepackage{caption}
\setCJKmainfont{Noto Serif CJK HK}
% Custom commands and environments
\newcommand{\diff}{\mathrm{d}}

\newenvironment{note}
{\par\textcolor{blue}{\bfseries Note:}\itshape}{\par}
\newenvironment{remark}
{\par\textcolor{blue}{\bfseries Remark:}\itshape}{\par}

\newtheorem{theorem}{Theorem}[section]
\newtheorem{lemma}[theorem]{Lemma}
\newtheorem{definition}{Definition}[section]
% \newtheorem{example}{Example}[section]
\newtheorem{proposition}{Proposition}[section] % 新添加的命题环境
\newtheorem{corollary}{Corollary}[section] % 新添加的推论环境
\renewcommand{\eqnannotationfont}{\bfseries\small}

% Geometry settings (consolidated)
\geometry{
  a4paper,
  total={170mm,257mm},
  left=20mm,
  right=20mm,
  top=20mm,
  bottom=20mm,
}

% Page style
\fancyhf{}
\fancyhead[L]{\small\leftmark}
\fancyhead[R]{\small\thepage}
\pagestyle{fancy}

% Title formatting
\titleformat{\chapter}[hang]
  {\normalfont\Large\bfseries}
  {\thechapter.}{1em}{}
\titlespacing*{\chapter}{0pt}{*1.5}{*1}

% Section and subsection formatting
\titleformat{\section}
  {\normalfont\large\bfseries}
  {\thesection}{1em}{}
\titlespacing*{\section}{0pt}{*1.5}{*1}

\titleformat{\subsection}
  {\normalfont\normalsize\bfseries}
  {\thesubsection}{1em}{}
\titlespacing*{\subsection}{0pt}{*1.5}{*1}

% Line spacing
\setstretch{1.1}

% Paragraph spacing
\setlength{\parskip}{0.5em} % 段落间距
\setlength{\parindent}{1.5em} % 段落缩进

% Itemize settings
\setlist{noitemsep, topsep=0pt, left=2em}

% Caption settings
\captionsetup{font=small, labelfont=bf}

\title{{\Huge{\textbf{数学分析}}}\\------张筑生}
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
		{ condition = tex.in_mathzone }
	),
	s(
		{ trig = "sec", snippetType = "autosnippet" },
		fmta("\\section{<>}", {
			i(0),
		})
	),
	s(
		{ trig = "ssec", snippetType = "autosnippet" },
		fmta("\\subsection{<>}", {
			i(0),
		})
	),
}
