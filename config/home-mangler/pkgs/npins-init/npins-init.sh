set -x

if [[ ! -e npins/sources.json ]]; then
    npins init --bare
fi

if [[ ! -e package.nix ]]; then
    cat << EOF > package.nix
{
  lib,
  stdenv,
}:

stdenv.mkDerivation {
  name = "my-package";
  src = lib.cleanSource ./.;
}
EOF
fi

if [[ ! -e default.nix ]]; then
    cat << EOF > default.nix
let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { };
in
pkgs.callPackage ./package.nix { }
EOF
fi

if [[ ! -e shell.nix ]]; then
    cat << EOF > shell.nix
let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { };
in
pkgs.callPackage ./package.nix { }
EOF
fi

if [[ ! -e .envrc ]]; then
    cat << 'EOF' > .envrc
if [[ "$(type -t nix_direnv_manual_reload)" == function ]]; then
    nix_direnv_manual_reload
fi

source_env_if_exists .envrc.local

use nix
EOF
fi

if ! jq --exit-status .pins.nixpkgs npins/sources.json >/dev/null; then
    npins add github nixos nixpkgs --verbose --branch nixos-unstable
fi
