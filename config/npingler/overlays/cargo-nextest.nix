final: prev: {
  cargo-nextest = prev.cargo-nextest.overrideAttrs (prev: {
    patches =
      let
        prevPatches = prev.patches or [ ];
        filteredPatches = builtins.filter (
          patch:
          builtins.toString patch
          # This patch fails to apply as of cargo-nextest-0.9.126.
          #
          # Fix: https://github.com/NixOS/nixpkgs/pull/488786
          # See: https://github.com/nextest-rs/nextest/pull/3027
          # See: https://github.com/NixOS/nixpkgs/pull/456256
          # See: https://github.com/NixOS/nixpkgs/pull/392918
          != "/nix/store/h63a8l38nvjc3drjniqa33wd75nxdvdh-source/pkgs/by-name/ca/cargo-nextest/no-dtrace-macos.patch"
        ) (prev.patches or [ ]);
      in
      final.lib.warnIf (builtins.length filteredPatches == prevPatches)
        ''
          cargo-nextest: broken patch is no longer present, update your npingler overlay
        ''
        (
          filteredPatches
          ++ [
            # cargo-nextest: update no-dtrace-macos.patch
            #
            # See: https://github.com/NixOS/nixpkgs/pull/488786
            (final.fetchpatch {
              url = "https://raw.githubusercontent.com/9999years/nixpkgs/f40c4cf8d947162ecb441ee836e638197bb70895/pkgs/by-name/ca/cargo-nextest/no-dtrace-macos.patch";
              hash = "sha256-WHF9wi3JjOqbuL/9EiI65pZ6QQHDqeXvWguI5YIaOw0=";
            })
          ]
        );
  });
}
