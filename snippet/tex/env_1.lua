local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local d = ls.dynamic_node
local fmta = require("luasnip.extras.fmt").fmta
local rep = require("luasnip.extras").rep
local line_begin = require("luasnip.extras.expand_conditions").line_begin
-- local tex = require("util.latex")
local tex = require("util.tex_utils")
local get_visual = function(args, parent)
  if #parent.snippet.env.SELECT_RAW > 0 then
    return sn(nil, i(1, parent.snippet.env.SELECT_RAW))
  else -- If SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end

return {
  s(
    { trig = "ii", wordTrig = false, snippetType = "autosnippet" },
    fmta(
      [[
      \(<>\)<>
      ]],
      {
        d(1, get_visual),
        i(0),
      }
    ),
    { condition = tex.in_text }
  ),
  s(
    { trig = "dd", snippetType = "autosnippet" },
    fmta(
      [[
      \[
        <>
      .\]
      ]],
      {
        d(1, get_visual),
      }
    ),
    { condition = tex.in_text }
  ),
  s(
    { trig = "thm" },
    fmta(
      [[
    \begin{theorem}[<>]
      <>
    \label{thm:<>}
    \end{theorem}
    ]],
      {
        i(1),
        i(0),
        rep(1),
      }
    ),
    { condition = tex.in_text }
  ),
  s(
    { trig = "def" },
    fmta(
      [[
      \begin{definition}[<>]
        <>
      \label{def:<>}
      \end{definition}
      ]],
      {
        i(1),
        i(0),
        rep(1),
      }
    ),
    { condition = tex.in_text }
  ),
  s(
    { trig = "beg", snippetType = "autosnippet" },
    fmta(
      [[
      \begin{<>}
        <>
      \end{<>}
      ]],
      {
        i(1),
        i(0),
        rep(1),
      }
    ),
    { condition = line_begin }
  ),
  s(
    { trig = "foot" },
    fmta(
      [[
      \footnote{<>}
      ]],
      {
        i(0),
      }
    ),
    { condition = tex.in_text }
  ),

  s(
    { trig = "mark", desc = "不会产生编号" },
    fmta(
      [[
      \marginnote{<>}<>
      ]],
      {
        i(1),
        i(0),
      }
    ),
    { condition = tex.in_text }
  ),

  s(
    { trig = "side", desc = "会产生编号" },
    fmta(
      [[
      \sidenote{<>}<>
      ]],
      {
        i(1),
        i(0),
      }
    ),
    { condition = tex.in_text }
  ),
  s(
    { trig = "topic" },
    fmta(
      [[
      \begin{topic}{\textbf{<>}}
        <>
      \end{topic}
      ]],
      {
        i(1),
        i(0),
      }
    ),
    { condition = tex.in_text }
  ),
}
