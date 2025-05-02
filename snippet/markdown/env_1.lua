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
  s(
    { trig = "ii", wordTrig = false, snippetType = "autosnippet" },
    fmta(
      [[
     $<>$<>
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
    c(1, {
      fmta(
        [[
        $$ 
        <> 
        $$
        ]],
        {
          d(1, get_visual),
        }
      ),
      fmt(
        [[
        >$$
        {}
        >$$
        ]],
        {
          d(1, get_visual),
        }
      ),
    }),
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
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "Mat", regTrig = false, wordTrig = false, snippetType = "autosnippet" },
    fmta(
      [[
      \begin{<>}
      <>
      \end{<>}
      ]],
      {
        c(1, {
          t("bmatrix"),
          t("vmatrix"),
          t("pmatrix"),
          t("Vmatrix"),
          t("matrix"),
          t("smallmatrix"),
        }),
        i(2),
        rep(1), -- 重复第一个节点的内容
      }
    ),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "bmat", snippetType = "autosnippet" },
    fmta(
      [[
      \begin{bmatrix}
        <>
      \end{bmatrix} <>
      ]],
      {
        i(1),
        i(0),
      }
    ),
    { condition = tex.in_mathzone }
  ),
  s(
    { trig = "vmat", snippetType = "autosnippet" },
    fmta(
      [[
      \begin{vmatrix}
        <>
      \end{vmatrix} <>
      ]],
      {
        i(1),
        i(0),
      }
    ),
    { condition = tex.in_mathzone }
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
  s(
    { trig = "def" },
    fmt(
      [[
> [!Definition] 
> {}
      ]],
      {
        d(1, get_visual), -- 使用 get_visual 获取选中的文本或插入节点
      }
    ),
    { condition = tex.in_text } -- 片段仅在非数学环境中触发
  ),
  s(
    { trig = "thm" },
    fmt(
      [[
> [!Theorem] 
> {}
      ]],
      {
        d(1, get_visual), -- 使用 get_visual 获取选中的文本或插入节点
      }
    ),
    { condition = tex.in_text } -- 片段仅在非数学环境中触发
  ),
  s(
    { trig = "exam" },
    fmt(
      [[
> [!Example] 
> {}
      ]],
      {
        d(1, get_visual), -- 使用 get_visual 获取选中的文本或插入节点
      }
    ),
    { condition = tex.in_text } -- 片段仅在非数学环境中触发
  ),
  s(
    { trig = "prop" },
    fmt(
      [[
> [!Proposition]
> {}
      ]],
      {
        d(1, get_visual), -- 使用 get_visual 获取选中的文本或插入节点
      }
    ),
    { condition = tex.in_text } -- 片段仅在非数学环境中触发
  ),
  s(
    { trig = "tags" },
    fmta(
      [[
        ---
        id: <>
        aliases: <>
        tags: [<>]
        date: <>
        ---
        ]],
      {
        i(1), -- id 字段
        i(2), -- aliases 字段
        i(3), -- tags 字段
        i(0), -- 自动插入当前日期
      }
    )
  ),
  s(
    { trig = "Tags" },
    fmta(
      [[
        ---
        id: <>
        aliases: <>
        tags: [<>]
        date: <>
        ---
        ]],
      {
        i(1), -- id 字段
        i(2), -- aliases 字段
        i(3), -- tags 字段
        i(0), -- 自动插入当前日期
      }
    )
  ),
}
