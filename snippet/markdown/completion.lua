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
local get_visual = function(args, parent)
  if #parent.snippet.env.SELECT_RAW > 0 then
    return sn(nil, i(1, parent.snippet.env.SELECT_RAW))
  else -- If SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end

return {
  -- s(
  --   { trig = "(%a);", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
  --   fmta("\\hat{<>}", {
  --     f(function(_, snip)
  --       return snip.captures[1]
  --     end),
  --   }),
  --   { condition = tex.in_mathzone }
  -- ),
  s(
    { trig = "([%a%)%]%}])(%d)", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
    fmta("<>_<>", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      f(function(_, snip)
        return snip.captures[2]
      end),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "([%a%)%]%}])_(%d)(%d)", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
    fmta("<>_{<><>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      f(function(_, snip)
        return snip.captures[2]
      end),
      f(function(_, snip)
        return snip.captures[3]
      end),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "([%a%)%]%}])(%a)%2", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 100 },
    fmta("<>_<>", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      f(function(_, snip)
        return snip.captures[2]
      end),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    {
      trig = "([%a%)%]%}])_(%a)(%a)%3",
      regTrig = true,
      wordTrig = false,
      snippetType = "autosnippet",
      priority = 2000,
    },
    fmta("<>_{<><>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      f(function(_, snip)
        return snip.captures[2]
      end),
      f(function(_, snip)
        return snip.captures[3]
      end),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "(%d+)/", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 100 },
    fmta("\\frac{<>}{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      i(1),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "(%a)/", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 100 },
    fmta("\\frac{<>}{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      i(1),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "%((.+)%)/", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
    fmta("\\frac{<>}{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      i(1),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "(\\%a+)/", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 2000 },
    fmta("\\frac{<>}{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      i(1),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "(\\%a+%{%a+%})/", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 3000 },
    fmta("\\frac{<>}{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
      i(1),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "\\%)(%a)", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 2000 },
    fmta("\\) <>", {
      f(function(_, snip)
        return snip.captures[1]
      end),
    })
  ),
  s(
    { trig = "lim", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
    fmta("\\lim\\limits_{<>}<>", {
      c(1, {
        i(nil, "n \\to \\infty"),
        i(nil, "x \\to 0"),
        i(nil, "x \\to a"),
        i(nil, "x \\to \\infty"),
        i(nil, "x \\to -\\infty"),
      }),
      i(0),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "sum", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
    fmta("\\sum\\limits_{<>}^{<>}<>", {
      c(1, {
        i(nil, "i=1"),
        i(nil, "i=0"),
        i(nil, "n=1"),
        i(nil, "k=1"),
        i(nil), -- 允许自定义输入
      }),
      c(2, {
        i(nil), -- 允许自定义输入
        i(nil, "n"),
        i(nil, "\\infty"),
        i(nil, "N"),
      }),
      i(0),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "prod", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
    fmta("\\prod\\limits_{<>}^{<>}<>", {
      i(1),
      i(2),
      i(0),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "bot", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 2000 },
    fmta("\\bigotimes\\limits_{<>}^{<>}", {
      i(1),
      i(0),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "pd", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
    fmta("\\prod\\limits_{<>}^{<>}", {
      i(1),
      i(0),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "bcap", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 2000 },
    fmta("\\bigcap\\limits_{<>}^{<>}", {
      i(1),
      i(0),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "bcup", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 2000 },
    fmta("\\bigcup\\limits_{<>}^{<>}", {
      i(1),
      i(0),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "bscap", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 2000 },
    fmta("\\bigsqcap\\limits_{<>}^{<>}", {
      i(1),
      i(0),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "bscup", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 2000 },
    fmta("\\bigsqcup\\limits_{<>}^{<>}", {
      i(1),
      i(0),
    }),
    { condition = tex.in_mathzone }
  ),
  -- s(
  --   { trig = "int", regTrig = true, wordTrig = false, snippetType = "autosnippet" },
  --   fmta("\\int_{<>}^{<>} <> \\dd{<>}", {
  --     i(1),
  --     i(2),
  --     i(3),
  --     i(0),
  --   }),
  --   { condition = tex.in_mathzone }
  -- ),
  s(
    { trig = "2int", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 2000 },
    fmta("\\int_{<>}^{<>}\\int_{<>}^{<>} <> \\dd{<>}\\dd{<>}", {
      i(1),
      i(2),
      i(3),
      i(4),
      i(5),
      i(6),
      i(0),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "iint", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 2000 },
    fmta("\\iint\\limits_{<>}^{<>} <> ", {
      i(1, "-\\infty"),
      i(2, "\\infty"),
      i(0),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "lint", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 2000 },
    fmta("\\int\\limits_{<>} <> ", {
      i(1, "\\infty"),
      i(0),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "(%a)%.mbb", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 100 },
    fmta("\\mathbb{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
    }),
    { condition = tex.in_mathzone }
  ),

  -- 匹配多个字母后跟 .mbb
  s(
    { trig = "(%a+)%.mbb", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 200 },
    fmta("\\mathbb{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
    }),
    { condition = tex.in_mathzone }
  ),

  -- 匹配 LaTeX 命令后跟 .mbb
  s(
    { trig = "(\\%a+)%.mbb", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 1000 },
    fmta("\\mathbb{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
    }),
    { condition = tex.in_mathzone }
  ),

  -- 匹配带参数的 LaTeX 命令后跟 .mbb
  s(
    { trig = "(\\%a+%{[^}]+%})%.mbb", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 2000 },
    fmta("\\mathbb{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
    }),
    { condition = tex.in_mathzone }
  ),
  ---
  s(
    { trig = "(%a+_%w+)%.mbb", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 2000 },
    fmta("\\mathbb{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
    }),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "(%a+_%{[^}]+%})%.mbb", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 2000 },
    fmta("\\mathbb{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
    }),
    { condition = tex.in_mathzone }
  ),
  -- 匹配括号内容后跟 .mbb
  s(
    { trig = "%((.+)%)%.mbb", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 500 },
    fmta("\\mathbb{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
    }),
    { condition = tex.in_mathzone }
  ),

  -- 匹配带2个反斜杠命令的表达式
  s(
    { trig = "(\\?%a+\\%a+)%.mbb", regTrig = true, wordTrig = false, snippetType = "autosnippet", priority = 1500 },
    fmta("\\mathbb{<>}", {
      f(function(_, snip)
        return snip.captures[1]
      end),
    }),
    { condition = tex.in_mathzone }
  ),
}
