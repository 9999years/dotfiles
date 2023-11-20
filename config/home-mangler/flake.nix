{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    home-mangler.url = "github:home-mangler/home-mangler";
  };

  outputs = {
    self,
    nixpkgs,
    home-mangler,
  }: let
    configuration = system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          home-mangler.overlays.default
          (final: prev: {
            # Fix table alignment in output.
            # See: https://github.com/maralorn/nix-output-monitor/issues/78
            nix-output-monitor = prev.nix-output-monitor.overrideAttrs (old: {
              patches =
                (old.patches or [])
                ++ [
                  (final.fetchpatch {
                    url = "https://github.com/maralorn/nix-output-monitor/pull/121.diff";
                    hash = "sha256-l+F2qRltOeiCEHJ4KACWiAQ/RtbjIGSQ3dND3BS6K0c=";
                    excludes = ["default.nix" "nix-output-monitor.cabal"];
                  })
                ];
            });

            # See: https://github.com/NixOS/nixpkgs/pull/268762
            tokei = prev.tokei.overrideAttrs (old: {
              buildInputs = (old.buildInputs or []) ++ [final.libz];
            });
          })
        ];
      };
      home-mangler-lib = home-mangler.lib.${system};
    in
      home-mangler-lib.makeConfiguration
      {
        packages = [
          pkgs.actionlint
          pkgs.alejandra
          pkgs.bash
          pkgs.bat
          pkgs.broot
          pkgs.cargo-nextest
          pkgs.cargo-watch
          pkgs.coreutils
          pkgs.delta # git-delta
          pkgs.dig
          pkgs.eza
          pkgs.fd
          pkgs.fzf
          pkgs.fzy
          pkgs.gh
          pkgs.git-absorb
          pkgs.gitleaks
          pkgs.home-mangler
          pkgs.hub
          pkgs.jq
          pkgs.jujutsu
          pkgs.lua-language-server
          pkgs.neovim
          pkgs.nil
          pkgs.nix-diff
          pkgs.nix-direnv
          pkgs.nix-output-monitor
          pkgs.nix-top
          pkgs.nix-your-shell
          pkgs.nixUnstable
          pkgs.rcm
          pkgs.ripgrep
          pkgs.rust-analyzer
          pkgs.rustup
          pkgs.shellcheck
          pkgs.stylua
          pkgs.tmux
          pkgs.tokei
          pkgs.topgrade
          pkgs.universal-ctags
        ];
      };
  in {
    home-mangler = {
      grandiflora = configuration "aarch64-darwin";
      san-fransisco = configuration "aarch64-darwin";
    };
  };
}
