{ pkgs ? import <nixpkgs> { } }:
pkgs.callPackage ./build.nix {
  init_coc_python = pkgs.rebecca.init_coc_python or null;
}
