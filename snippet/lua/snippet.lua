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
		{ trig = "tsnip", dscr = "text snippet" },
		fmta(
			[[
	 s({ trig = "<>", snippetType = "autosnippet" }, { t("\\<>") }, { condition = <> })
      ]],
			{
				i(1),
				i(2),
				i(0),
			}
		)
	),

	s(
		{ trig = "fsnip", dscr = "fmta text snippet" },
		fmta(
			[[
	s(
		{ trig = "<>", snippetType = "autosnippet" },
		fmta(
    <>, 
    {
    <>
		}),
		{ condition = <> }
	),
}

      ]],
			{
				i(1),
				i(2),
				i(3),
				i(0),
			}
		)
	),

	s(
		{ trig = "rsnip", dscr = "regTrig snippet" },
		fmta(
			[[
	s(
		{ trig = "<>", regTrig = true,snippetType = "autosnippet" },
		fmta(
    <>, 
    {
    <>
		}),
		{ condition = <> }
	),
}
      ]],
			{
				i(1),
				i(2),
				i(3),
				i(0),
			}
		)
	),
}
