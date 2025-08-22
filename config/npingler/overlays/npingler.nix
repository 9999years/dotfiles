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

      # Upgrade edition from 2021 to 2024
      #
      # See: https://github.com/9999years/npingler/pull/8
      (final.fetchpatch {
        url = "https://github.com/9999years/npingler/commit/d9679f7c5745dfd53824da0af70286daf8b8001b.patch";
        hash = "sha256-R7DiBfyu0DYzWgV3dfpybMpBwoVa/uZEtvN/SveyPII=";
      })

      # app: Log out paths
      #
      # See: github.com/9999years/npingler/pull/9
      (final.fetchpatch {
        url = "https://github.com/9999years/npingler/commit/82b5f6add3f9ed2264e98c7cbad8e2cad1fe90b3.patch";
        hash = "sha256-9ZBnxQOqi6J0ywBVAJhfpaPw86fa6nOqUwo+qYGQD1g=";
      })

      # Avoid `sudo` registry/channel commands when possible
      #
      # See: https://github.com/9999years/npingler/pull/7
      (final.fetchpatch {
        url = "https://github.com/9999years/npingler/commit/278b1df896404bb9deb687e7c31cd519ad63be49.patch";
        hash = "sha256-A6C54x2G84tJaPaFuFch4EQ1GJSf6zl0o62cGsEqEb8=";
      })
    ];
  });
}
