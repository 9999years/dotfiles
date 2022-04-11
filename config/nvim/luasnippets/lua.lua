isn = require("luasnip.nodes.snippet").ISN

return {
    s("fn", {
        t"function(", i(1), t({")", ""}),
        isn(2, {t"  ", i(1)}, "$PARENT_INDENT  "),
        t({"", "end"}),
    }),
}
