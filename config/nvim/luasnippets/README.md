Each file has this general structure:

```lua
return {
    -- List of snippets:
    ls.parser.parse_snippet("snippet trigger text", "snippet expansion")
}, {
    -- Autotriggered snippets:
    ls.parser.parse_snippet("autotrigger", "autoexpansion")
}
```

<https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#lua-snippets-loader>
