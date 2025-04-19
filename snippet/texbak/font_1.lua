local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local f = ls.function_node
local i = ls.insert_node
local d = ls.dynamic_node
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local line_begin = require("luasnip.extras.expand_conditions").line_begin
ls.config.setup({ store_selection_keys = "<tab>" })
local get_visual = function(args, parent)
  if #parent.snippet.env.SELECT_RAW > 0 then
    return sn(nil, i(1, parent.snippet.env.SELECT_RAW))
  else -- If SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end

-- local tex = require("util.latex")
local tex = require("util.tex_utils")

return {
  s(
    { trig = "bb(%a+)", regTrig = true, snippetType = "autosnippet" },
    fmta(
      [[
        \mathbb{<>}
        ]],
      {
        f(function(_, snip)
          return snip.captures[1]
        end),
      }
    ),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "rm(%a+)", regTrig = true, snippetType = "autosnippet" },
    fmta(
      [[
        \mathrm{<>}
        ]],
      {
        f(function(_, snip)
          return snip.captures[1]
        end),
      }
    ),
    { condition = tex.in_mathzone }
  ),

  s(

    { trig = "rmb", snippetType = "autosnippet", priority = 2000 },
    { t("\\mathrm{b}") },
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "rmd", snippetType = "autosnippet", priority = 2000 },
    { t("\\mathrm{d}") },
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "tbf", snippetType = "autosnippet" },
    fmta("\\textbf{<>}", {
      i(0),
    })
  ),
}
