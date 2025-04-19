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
		{ trig = "tbf", dscr = "text bold font", snippetType = "autosnippet" },
		fmta("**<>**", {
			d(1, get_visual),
		}),
		{ condition = tex.in_text }
	),
	s(
		{ trig = "tbi", dscr = "text bold font", snippetType = "autosnippet" },
		fmta("*<>*", {
			d(1, get_visual),
		}),
		{ condition = tex.in_text }
	),
}
