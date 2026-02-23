final: prev: {
  direnv = prev.direnv.overrideAttrs (drv: {
    env = (drv.env or { }) // {
      # See: https://github.com/NixOS/nixpkgs/pull/486452#issuecomment-4111228040
      CGO_ENABLED = if final.stdenv.isDarwin then 1 else 0;
    };
  });
}
