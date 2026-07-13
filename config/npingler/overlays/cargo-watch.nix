final: prev: {
  cargo-watch = prev.cargo-watch.overrideAttrs (drv: {
    # Work around the ld64 hardening crash on Darwin by linking with lld,
    # like the upstream workarounds (e.g. https://github.com/NixOS/nixpkgs/pull/537877).
    # Delete this once this PR is merged: https://github.com/NixOS/nixpkgs/pull/536365
    nativeBuildInputs =
      (drv.nativeBuildInputs or [ ])
      ++ final.lib.optionals final.stdenv.hostPlatform.isDarwin [ final.llvmPackages.lld ];
    env = (drv.env or { }) // final.lib.optionalAttrs final.stdenv.hostPlatform.isDarwin {
      NIX_CFLAGS_LINK = "-fuse-ld=lld";
    };
  });
}
