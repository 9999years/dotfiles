{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    home-mangler.url = "github:home-mangler/home-mangler";
  };

  nixConfig = {
    extra-substituters = ["https://cache.garnix.io"];
    extra-trusted-substituters = ["https://cache.garnix.io"];
    extra-trusted-public-keys = ["cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="];
  };

  outputs = {
    self,
    nixpkgs,
    home-mangler,
  }: let
    inherit (nixpkgs) lib;

    makePkgs = system:
      import nixpkgs {
        inherit system;
        overlays = [
          home-mangler.overlays.default
          self.overlays.default
        ];
      };

    configuration = system: let
      pkgs = self.pkgs.${system};
      home-mangler-lib = home-mangler.lib.${system};
    in
      home-mangler-lib.makeConfiguration {
        packages = [
          pkgs.coreutils
          pkgs.findutils # `find` and `xargs`
          pkgs.gnused
          pkgs.gnugrep
          pkgs.curl

          pkgs.actionlint
          pkgs.alejandra
          pkgs.bashInteractive
          pkgs.bat
          pkgs.broot
          pkgs.cargo-nextest
          pkgs.cargo-watch
          pkgs.delta # `git-delta`
          pkgs.dig
          pkgs.direnv
          pkgs.eza
          pkgs.fd
          pkgs.fish
          pkgs.fnm
          pkgs.fzf
          pkgs.fzy
          pkgs.gh
          pkgs.lix.man
          pkgs.git
          pkgs.git-hub
          pkgs.git-lfs
          pkgs.git-absorb
          pkgs.git-gr
          pkgs.git-revise
          pkgs.git-upstream
          pkgs.git-gr
          pkgs.gitleaks
          pkgs.home-mangler
          pkgs.hub
          pkgs.hyperfine
          pkgs.imagemagickBig
          pkgs.jq
          pkgs.jujutsu
          pkgs.less
          pkgs.lua-language-server
          pkgs.neovim
          pkgs.nil
          pkgs.nix-diff
          pkgs.nix-direnv
          pkgs.nix-index
          pkgs.nix-output-monitor
          pkgs.nix-top
          pkgs.nix-your-shell
          pkgs.nixfmt-rfc-style
          pkgs.pre-commit
          pkgs.rcm
          pkgs.ripgrep
          pkgs.rnr # Batch/regex renamer.
          pkgs.rust-analyzer
          pkgs.rustup
          pkgs.sd # `sed` replacement
          pkgs.shellcheck
          pkgs.stylua
          pkgs.tmux
          pkgs.tokei
          pkgs.topgrade
          pkgs.units
          pkgs.universal-ctags
          pkgs.weechat
        ];
      };
  in {
    home-mangler = {
      grandiflora = configuration "aarch64-darwin";
      san-fransisco = configuration "aarch64-darwin";
      helvetica = configuration "aarch64-darwin";
    };

    overlays.default = final: prev: {
      nixVersions =
        lib.mapAttrs (
          _name: pkg:
            if builtins.isAttrs pkg
            then final.lix
            else pkg
        )
        prev.nixVersions;
    };

    pkgs = lib.mapAttrs (system: _pkgs: makePkgs system) nixpkgs.legacyPackages;
  };
}
