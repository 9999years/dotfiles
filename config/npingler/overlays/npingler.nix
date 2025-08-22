final: prev: {
  npingler = prev.npingler.overrideAttrs (prevDrv: {
    patches = (prevDrv.patches or [ ]) ++ [
      # Only prefer `~/.local/state/nix/profile` if `use-xdg-base-directories` is
      # set.
      #
      # See: https://github.com/9999years/npingler/pull/5
      (final.fetchpatch {
        url = "https://github.com/9999years/npingler/commit/a04c0cec9f96a9bf237e488a7db23c572e95684b.patch";
        hash = "sha256-7zN+ZCWYKB2v6SEeAV2KXiL7isjfpCqCM649r3Zrl3I=";
      })
    ];
  });
}
