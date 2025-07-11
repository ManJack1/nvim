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
local tex = require("util.md-env")
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
      t({ "" }),
      sn(nil, { t({ "", "\t\\item " }), i(1), d(2, rec_ls, {}) }),
    }),
  })
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
    { condition = tex.in_mathzone }
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

  s({ trig = "ff", dscr = "Expands 'ff' into '\frac{}{}'", snippetType = "autosnippet" }, {
    t("\\frac{"),
    i(1), -- insert node 1
    t("}{"),
    i(2), -- insert node 2
    t("}"),
  }, { condition = tex.in_mathzone }),

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
  s({ trig = "il", dscr = "A latex Interline env" }, fmta([[$<>$]], { i(1) })),

  -----math-notion
  s({ trig = "ol", dscr = "A latex overline" }, fmta([[\overline{<>}]], { i(1) })),

  s({ trig = "ob", dscr = "A latex overbar" }, fmta([[\overbar{<>}]], { i(1) })),

  -- s({ trig = "sum", dscr = "A latex sum notion" }, fmta([[\sum_{<>}^{<>}]], { i(1), i(2) })),

  s({ trig = "sqrt", dscr = "A sqrt in math-notion" }, fmta([[\sqrt{<>}]], { i(1) })),

  s({ trig = "obrace", dscr = "The overbrace of latex" }, fmta([[\overbrace{<>}^{<>}]], { i(1), i(2) })),

  s({ trig = "ubrace", dscr = "The underbrace of latex" }, fmta([[\underbrace{<>}_{<>}]], { i(1), i(2) })),
  s(
    { trig = "normat", decr = "Matrix of linear equations" },
    fmta(
      [[
\begin{vmatrix}
  a_{11} & a_{12} & \cdots & a_{1n} \\
  \vdots & \vdots & \vdots & \vdots \\
  a_{k 1} & a_{k2} & \cdots & a_{kn} \\
  \vdots & \vdots & \vdots & \vdots \\
  a_{n1} & a_{n2} & \cdots & a_{nn}
\end{vmatrix}  <>
  ]],
      {
        i(1),
      }
    ),
    { condition = tex.in_mathzone }
  ),

  s(
    { trig = "norfun", decr = "Matrix of linear equations" },
    fmta(
      [[
\begin{cases}
a_{11}x_1 + a_{12}x_2 + \cdots + a_{1m}x_m = b_1 \\
a_{21}x_1 + a_{22}x_2 + \cdots + a_{2m}x_m = b_2 \\
\vdots \\
a_{n1}x_1 + a_{n2}x_2 + \cdots + a_{nm}x_m = b_n
\end{cases} <>
  ]],
      {
        i(1),
      }
    ),
    { condition = tex.in_mathzone }
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
    ),
    { condition = tex.in_mathzone }
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
}
