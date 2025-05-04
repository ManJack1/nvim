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
local get_visual = function(args, parent)
  if #parent.snippet.env.SELECT_RAW > 0 then
    return sn(nil, i(1, parent.snippet.env.SELECT_RAW))
  else -- If SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end
return {
  s({ trig = "In", snippetType = "autosnippet" }, t("\\in"), { condition = tex.in_mathzone }),
  s(
    { trig = "int", snippetType = "autosnippet" },
    fmta(
      [[
    \int_{<>}^{<>}<><>
    ]],
      {
        i(1),
        i(2),
        i(3),
        i(0),
      }
    ),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "sum", snippetType = "autosnippet" },
    fmta(
      [[
    \sum\limits_{<>}^{<>}<>
    ]],
      {
        i(1),
        i(2),
        i(0),
      }
    ),
    { condition = tex.in_math }
  ),

  s(
    { trig = "oin", snippetType = "autosnippet", privoty = "3000" },
    fmta(
      [[
    \oint\limits_{<>}<>
    ]],
      {
        i(1),
        i(0),
      }
    ),
    { condition = tex.in_mathzone }
  ),

  s(
    { trig = "ff", snippetType = "autosnippet" },
    fmta(
      [[
    \frac{<>}{<>}<>
    ]],
      {
        i(1),
        i(2),
        i(0),
      }
    ),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "lim", snippetType = "autosnippet" },
    fmta(
      [[
    \lim\limits_{<>}<>
    ]],
      {
        i(1),
        i(0),
      }
    ),
    { condition = tex.in_mathzone }
  ),

  s(
    { trig = "lim", snippetType = "autosnippet" },
    fmta(
      [[
    \lim\limits_{<>}<>
    ]],
      {
        i(1),
        i(0),
      }
    ),
    { condition = tex.in_mathzone }
  ),

  s({ trig = "to", snippetType = "autosnippet" }, t("\\to "), { condition = tex.in_mathzone }),
  s(
    { trig = "sq", snippetType = "autosnippet" },
    fmta(
      [[
    \sqrt{<>}<>
    ]],
      {
        i(1),
        i(0),
      }
    ),
    { condition = tex.in_mathzone }
  ),

  s(
    { trig = "nsq", snippetType = "autosnippet" },
    fmta(
      [[
    \sqrt[n]{<>}<>
    ]],
      {
        i(1),
        i(0),
      }
    ),
    { condition = tex.in_mathzone }
  ),

  s(
    { trig = "pow", regTrig = true, snippetType = "autosnippet" },
    fmta(
      [[
        <>^{<>}<>
        ]],
      {
        i(1),
        i(2),
        i(0),
      }
    ),
    { condition = tex.in_mathzone }
  ),

  s(
    { trig = "(%w+)pow", regTrig = true, snippetType = "autosnippet" },
    fmta(
      [[
        <>^{<>}<>
        ]],
      {
        f(function(_, snip)
          return snip.captures[1]
        end),
        i(1),
        i(0),
      }
    ),
    { condition = tex.in_mathzone }
  ),

  s(
    { trig = "sub", regTrig = true, snippetType = "autosnippet" },
    fmta(
      [[
        <>_{<>}<>
        ]],
      {
        i(1),
        i(2),
        i(0),
      }
    ),
    { condition = tex.in_mathzone }
  ),

  s(
    { trig = "(%w+)sub", regTrig = true, snippetType = "autosnippet" },
    fmta(
      [[
        <>_{<>}<>
        ]],
      {
        f(function(_, snip)
          return snip.captures[1]
        end),
        i(1),
        i(0),
      }
    ),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "\\{", snippetType = "autosnippet" },
    fmta("\\left\\{ <>\\right\\}<>", { i(1), i(2) }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "l%[", regTrig = true, snippetType = "autosnippet" },
    fmta(
      [[
        \left[ <> \right]
        ]],
      {
        i(0),
      }
    ),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "cmat", snippetType = "autosnippet" },
    fmta(
      [[
      \begin{pmatrix}
       <>\\
       \vdots \\
       <>
       \end{pmatrix} <>
      ]],
      {
        i(1),
        i(2),
        i(0),
      }
    ),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "bim", snippetType = "autosnippet" },
    fmta(
      [[
      \binom{<>}{<>}<>
      ]],
      {
        i(1),
        i(2),
        i(0),
      }
    ),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "l%(", regTrig = true, snippetType = "autosnippet" },
    fmta(
      [[
        \left( <> \right)<>
        ]],
      {
        i(1),
        i(0),
      }
    ),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "l%{", regTrig = true, snippetType = "autosnippet" },
    fmta(
      [[
        \left\{ <> \right\}<>
        ]],
      {
        i(1),
        i(0),
      }
    ),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "msf", snippetType = "autosnippet" },
    fmta("\\mathsf{<>}", {
      i(0),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "(%w+)bc", regTrig = true, snippetType = "autosnippet" },
    fmta("<>(<>)<>", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      i(1),
      i(0),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    "series",
    fmta(
      [[
<>_1, <>_2, \cdots, <>_<> <>
    ]],
      {
        i(1), -- 输入变量名称，默认 "x"
        rep(1), -- 自动复用变量名称
        rep(1), -- 再次复用变量名称
        i(2, "n"), -- 输入最大下标，默认 "n"
        i(0),
      }
    )
  ),
  s(
    { trig = "bc", regTrig = true, snippetType = "autosnippet" },
    fmta("(<>)<>", {
      i(1),
      i(0),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "D(%w+)", regTrig = true, snippetType = "autosnippet" },
    fmta("\\diff <>", {
      f(function(_, snip)
        return snip.captures[1]
      end),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "(%w+)sr", regTrig = true, snippetType = "autosnippet" },
    fmta("<>^2<>", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      i(0),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "(%w+)cb", regTrig = true, snippetType = "autosnippet" },
    fmta("<>^3<>", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      i(0),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "sr", regTrig = true, snippetType = "autosnippet" },
    fmta("<>^2<>", {
      i(1),
      i(0),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "cb", regTrig = true, snippetType = "autosnippet" },
    fmta("<>^3<>", {
      i(1),
      i(0),
    }),
    { condition = tex.in_mathzone }
  ),
}
