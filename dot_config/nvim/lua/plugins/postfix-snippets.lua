-- IntelliJ-style postfix snippets for JS/TS via LuaSnip
return {
  "L3MON4D3/LuaSnip",
  config = function()
    local ls = require("luasnip")
    local postfix = require("luasnip.extras.postfix").postfix
    local l = require("luasnip.extras").lambda
    local f = ls.function_node
    local i = ls.insert_node
    local t = ls.text_node
    local sn = ls.snippet_node
    local d = ls.dynamic_node

    -- Helper: get POSTFIX_MATCH from parent env
    local function match(_, parent)
      return parent.snippet.env.POSTFIX_MATCH
    end

    local snippets = {
      -- Console methods
      postfix(".log", {
        t("console.log("),
        f(match, {}),
        t(")"),
      }),
      postfix(".warn", {
        t("console.warn("),
        f(match, {}),
        t(")"),
      }),
      postfix(".error", {
        t("console.error("),
        f(match, {}),
        t(")"),
      }),

      -- Variable declarations
      postfix(".const", {
        t("const "),
        i(1, "name"),
        t(" = "),
        f(match, {}),
      }),
      postfix(".let", {
        t("let "),
        i(1, "name"),
        t(" = "),
        f(match, {}),
      }),
      postfix(".constd", {
        t("const { "),
        i(1),
        t(" } = "),
        f(match, {}),
      }),

      -- Control flow
      postfix(".return", {
        t("return "),
        f(match, {}),
      }),
      postfix(".await", {
        t("await "),
        f(match, {}),
      }),
      postfix(".if", {
        t("if ("),
        f(match, {}),
        t({ ") {", "\t" }),
        i(1),
        t({ "", "}" }),
      }),
      postfix(".throw", {
        t("throw "),
        f(match, {}),
      }),

      -- Expressions
      postfix(".not", {
        t("!"),
        f(match, {}),
      }),
      postfix(".typeof", {
        t("typeof "),
        f(match, {}),
      }),
      postfix(".new", {
        t("new "),
        f(match, {}),
        t("("),
        i(1),
        t(")"),
      }),
      postfix(".spread", {
        t("[..."),
        f(match, {}),
        t("]"),
      }),
      postfix(".instanceof", {
        f(match, {}),
        t(" instanceof "),
        i(1, "Type"),
      }),

      -- Iteration
      postfix(".for", {
        t("for (const "),
        i(1, "item"),
        t(" of "),
        f(match, {}),
        t({ ") {", "\t" }),
        i(2),
        t({ "", "}" }),
      }),
      postfix(".foreach", {
        f(match, {}),
        t(".forEach(("),
        i(1, "item"),
        t({ ") => {", "\t" }),
        i(2),
        t({ "", "})" }),
      }),

      -- Array methods
      postfix(".map", {
        f(match, {}),
        t(".map(("),
        i(1, "item"),
        t(") => "),
        i(2),
        t(")"),
      }),
      postfix(".filter", {
        f(match, {}),
        t(".filter(("),
        i(1, "item"),
        t(") => "),
        i(2),
        t(")"),
      }),
      postfix(".find", {
        f(match, {}),
        t(".find(("),
        i(1, "item"),
        t(") => "),
        i(2),
        t(")"),
      }),
    }

    ls.add_snippets("javascript", snippets, { key = "js_postfix" })

    ls.filetype_extend("typescript", { "javascript" })
    ls.filetype_extend("typescriptreact", { "javascript" })
    ls.filetype_extend("javascriptreact", { "javascript" })
  end,
}
