final: prev: {
  lix = final.lixPackageSets.latest.lix;

  nix = final.lix;

  nixVersions = final.lib.mapAttrs (
    _name: pkg: if builtins.isAttrs pkg then final.lix else pkg
  ) prev.nixVersions;
}
