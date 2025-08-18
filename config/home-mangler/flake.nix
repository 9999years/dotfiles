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
        {
          system,
          work ? false,
        }:
        let
          pkgs = self.legacyPackages.${system};
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

            # keep-sorted start ignore_prefixes=pkgs,pkgs.rbt
            pkgs._7zz # 7-zip.org
            pkgs.rbt.__tmux_window_name
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
            pkgs.gitoxide # `gix`
            pkgs.home-mangler
            pkgs.hub
            pkgs.hyperfine
            pkgs.imagemagickBig
            pkgs.isort # Python import sorter.
            pkgs.jq
            pkgs.jujutsu
            pkgs.just
            pkgs.keep-sorted
            pkgs.less
            pkgs.lixPackageSets.latest.nix-eval-jobs
            pkgs.lua-language-server
            pkgs.ncdu
            pkgs.neovim
            pkgs.nil
            pkgs.nix-diff
            pkgs.nix-direnv
            pkgs.nix-index
            pkgs.nix-init
            pkgs.nix-top
            pkgs.nix-tree
            pkgs.nix-update
            pkgs.nix-your-shell
            pkgs.nixfmt-rfc-style
            pkgs.nmap
            pkgs.nodejs_latest
            pkgs.npins
            pkgs.rbt.npins-init
            pkgs.omnisharp-roslyn
            pkgs.pandoc
            pkgs.pre-commit
            pkgs.pyright
            pkgs.rbt.pythonEnv
            pkgs.rbt.pywatchman
            pkgs.rcm
            pkgs.ripgrep
            pkgs.rnr # Batch/regex renamer.
            pkgs.rsync
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
            pkgs.watch
            pkgs.watchman
            pkgs.weechat
            pkgs.yaml-language-server
            # keep-sorted end
          ]
          ++ lib.optionals (!work) [
            # keep-sorted start ignore_prefixes=pkgs,pkgs.rbt
            pkgs.rbt.beetsWithBeetcamp
            pkgs.ffmpeg-full
            pkgs.rbt.slsk-batchdl
            pkgs.yt-dlp
            # keep-sorted end
          ];
        };
    in
    {
      home-mangler = {
        grandiflora = configuration {
          system = "aarch64-darwin";
        };
        sectra = configuration {
          system = "aarch64-darwin";
          work = true;
        };
        helvetica = configuration {
          system = "aarch64-darwin";
          work = true;
        };
      };

      overlays.default = lib.composeManyExtensions [
        (import ./overlays/lix.nix)
        (import ./overlays/broot.nix)
        (import ./overlays/python.nix)
        (import ./overlays/pkgs.nix)
      ];

      legacyPackages = lib.mapAttrs (system: _pkgs: makePkgs system) nixpkgs.legacyPackages;
    };
}
