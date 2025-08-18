final: prev: {
  broot = prev.broot.overrideAttrs (prev: {
    patches = (prev.patches or [ ]) ++ [
      # Load `~/.config/git/ignore` on macOS.
      #
      # See: https://github.com/Canop/broot/pull/1033
      (final.fetchpatch {
        url = "https://github.com/Canop/broot/commit/b533cedd7d7549d0b0ad973c5bd77fed7c807401.patch";
        hash = "sha256-ip1EXabrr/VlBMWrmR5uieNPxdw0qxzHnJ27OsEjiQs=";
      })
    ];
  });
}
