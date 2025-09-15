let
  npins-sources = import ./npins;
  pkgs = import npins-sources.nixpkgs {
    overlays = [
      (final: prev: {
        inherit npins-sources;
      })
      # keep-sorted start
      (import ./overlays/lix.nix)
      (import ./overlays/npingler-lib.nix)
      (import ./overlays/pkgs.nix)
      (import ./overlays/python.nix)
      (import ./overlays/rcm.nix)
      # keep-sorted end
    ];
  };

  inherit (pkgs) lib npingler-lib;

  rust-analyzer = lib.meta.hiPrio pkgs.rust-analyzer;

  makeProfile =
    {
      work ? false,
    }:

    npingler-lib.makeProfile {
      pins = {
        nixpkgs = npins-sources.nixpkgs;
      };

      paths = [
        # keep-sorted start
        pkgs.coreutils
        pkgs.curl
        pkgs.findutils # `find` and `xargs`
        pkgs.gnugrep
        pkgs.gnused
        pkgs.man
        # keep-sorted end

        # keep-sorted start ignore_prefixes=pkgs.,pkgs.rbt.
        pkgs._7zz # 7-zip.org
        pkgs.rbt.__tmux_window_name
        pkgs.actionlint
        pkgs.bashInteractive
        pkgs.bat
        pkgs.broot
        pkgs.cargo-autoinherit
        pkgs.cargo-edit # `cargo upgrade`
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
        pkgs.hub
        pkgs.hyperfine
        pkgs.imagemagickBig
        pkgs.jq
        pkgs.jujutsu
        pkgs.just
        pkgs.keep-sorted
        pkgs.less
        pkgs.lixPackageSets.latest.nix-eval-jobs
        pkgs.lua-language-server
        pkgs.mergiraf
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
        pkgs.npingler
        pkgs.npins
        pkgs.rbt.npins-init
        pkgs.nvd
        pkgs.omnisharp-roslyn
        pkgs.pandoc
        pkgs.pre-commit
        pkgs.pyright
        pkgs.rbt.python-env
        pkgs.rbt.pywatchman
        pkgs.rcm
        pkgs.ripgrep
        pkgs.rnr # Batch/regex renamer.
        pkgs.rsync
        pkgs.ruff # Python formatter.
        rust-analyzer
        pkgs.rustup
        pkgs.sd # `sed` replacement
        pkgs.shellcheck
        pkgs.stylua
        pkgs.taplo
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
        pkgs.rbt.beets-with-beetcamp
        pkgs.ffmpeg-full
        pkgs.slsk-batchdl
        pkgs.yt-dlp
        # keep-sorted end
      ];
    };
in
{
  inherit pkgs;

  npingler = {
    grandiflora = makeProfile {
    };
    sectra = makeProfile {
      work = true;
    };
    helvetica = makeProfile {
      work = true;
    };
  };
}
