{
  inputs = {
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
        in
        home-mangler-lib.makeConfiguration {
          packages = [
            # keep-sorted start
            pkgs.coreutils
            pkgs.curl
            pkgs.findutils # `find` and `xargs`
            pkgs.gnugrep
            pkgs.gnused
            pkgs.man
            # keep-sorted end

            # keep-sorted start
            pkgs.actionlint
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
            pkgs.git
            pkgs.git-absorb
            pkgs.git-gr
            pkgs.git-hub
            pkgs.git-lfs
            pkgs.git-prole
            pkgs.git-revise
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
            pkgs.lixPackageSets.latest.nix-eval-jobs
            pkgs.lua-language-server
            pkgs.neovim
            pkgs.nil
            pkgs.nix-diff
            pkgs.nix-direnv
            pkgs.nix-index
            pkgs.nix-top
            pkgs.nix-tree
            pkgs.nix-update
            pkgs.nix-your-shell
            pkgs.nixfmt-rfc-style
            pkgs.nodejs_latest
            pkgs.npins
            pkgs.pre-commit
            pkgs.rbt.__tmux_window_name
            pkgs.rbt.beetsWithBeetcamp
            pkgs.rbt.slsk-batchdl
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
            pkgs.uv
            pkgs.vscode-langservers-extracted
            pkgs.weechat
            pkgs.yaml-language-server
            pkgs.yt-dlp
            # keep-sorted end
          ];
        };
    in
    {
      home-mangler = {
        grandiflora = configuration "aarch64-darwin";
        sectra = configuration "aarch64-darwin";
        helvetica = configuration "aarch64-darwin";
      };

      overlays.default = lib.composeManyExtensions [
        (import ./overlays/lix.nix)
        (import ./overlays/pkgs.nix)
      ];

      pkgs = lib.mapAttrs (system: _pkgs: makePkgs system) nixpkgs.legacyPackages;
    };
}
