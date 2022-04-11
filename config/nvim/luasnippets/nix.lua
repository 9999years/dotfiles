return {
    s("shell", {
        t({
            "{ pkgs ? import <nixpkgs> {} }:",
            "pkgs.mkShell {",
            "  nativeBuildInputs = with pkgs; [",
            "    ",
        }),
        i(1, "ghc"),
        t({
            "",
            "  ];",
            "}"
        }),
    }),
}
