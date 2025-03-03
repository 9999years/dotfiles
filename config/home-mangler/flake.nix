{
  inputs = {
    # Needs: https://nixpk.gs/pr-tracker.html?pr=381077
    nixpkgs.url = "github:NixOS/nixpkgs";
    home-mangler = {
      url = "github:home-mangler/home-mangler";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [ "https://cache.garnix.io" ];
    extra-trusted-substituters = [ "https://cache.garnix.io" ];
    extra-trusted-public-keys = [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
  };

  outputs =
    {
      self,
      nixpkgs,
      home-mangler,
    }:
    let
      inherit (nixpkgs) lib;

      makePkgs =
        system:
        import nixpkgs {
          inherit system;
          overlays = [
            home-mangler.overlays.default
            self.overlays.default
          ];
        };

      configuration =
        system:
        let
          pkgs = self.pkgs.${system};
          home-mangler-lib = home-mangler.lib.${system};

          # https://github.com/NixOS/nixpkgs/pull/385865
          git-revise = pkgs.git-revise.overridePythonAttrs (drv: {
            doCheck = false;
          });
        in
        home-mangler-lib.makeConfiguration {
          packages = [
            pkgs.coreutils
            pkgs.findutils # `find` and `xargs`
            pkgs.gnused
            pkgs.gnugrep
            pkgs.curl
            pkgs.man

            pkgs.__tmux_window_name
            pkgs.actionlint
            pkgs.alejandra
            pkgs.bashInteractive
            pkgs.bat
            pkgs.broot
            pkgs.cargo-nextest
            pkgs.cargo-watch
            pkgs.delta # `git-delta`
            pkgs.deno
            pkgs.dig
            pkgs.direnv
            pkgs.eza
            pkgs.fd
            pkgs.fish
            pkgs.fnm
            pkgs.fzf
            pkgs.fzy
            pkgs.gh
            pkgs.git
            pkgs.git-absorb
            pkgs.git-gr
            pkgs.git-gr
            pkgs.git-hub
            pkgs.git-lfs
            pkgs.git-prole
            git-revise
            pkgs.git-upstream
            pkgs.gitleaks
            pkgs.home-mangler
            pkgs.hub
            pkgs.hyperfine
            pkgs.imagemagickBig
            pkgs.isort # Python import sorter.
            pkgs.jq
            pkgs.jujutsu
            pkgs.keep-sorted
            pkgs.less
            pkgs.lua-language-server
            pkgs.neovim
            pkgs.nil
            pkgs.nix-diff
            pkgs.nix-direnv
            pkgs.nix-index
            pkgs.nix-top
            pkgs.nix-update
            pkgs.nix-your-shell
            pkgs.nixfmt-rfc-style
            pkgs.pre-commit
            pkgs.rcm
            pkgs.ripgrep
            pkgs.rnr # Batch/regex renamer.
            pkgs.ruff # Python formatter.
            pkgs.rust-analyzer
            pkgs.rustup
            pkgs.sd # `sed` replacement
            pkgs.shellcheck
            pkgs.stylua
            pkgs.tmux
            pkgs.tokei
            pkgs.topgrade
            pkgs.typescript-language-server
            pkgs.units
            pkgs.universal-ctags
            pkgs.vscode-langservers-extracted
            pkgs.weechat
            pkgs.yaml-language-server
          ];
        };
    in
    {
      home-mangler = {
        grandiflora = configuration "aarch64-darwin";
        san-fransisco = configuration "aarch64-darwin";
        helvetica = configuration "aarch64-darwin";
      };

      overlays.default = final: prev: {
        nixVersions = lib.mapAttrs (
          _name: pkg: if builtins.isAttrs pkg then final.lix else pkg
        ) prev.nixVersions;

        # TODO: Use `lib.packagesFromDirectoryRecursive` or similar.
        __tmux_window_name = final.callPackage ./__tmux_window_name.nix { };
      };

      pkgs = lib.mapAttrs (system: _pkgs: makePkgs system) nixpkgs.legacyPackages;
    };
}
