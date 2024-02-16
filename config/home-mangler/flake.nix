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
          pkgs.delta # `git-delta`
          pkgs.dig
          pkgs.direnv
          pkgs.eza
          pkgs.fd
          pkgs.findutils # `find` and `xargs`
          pkgs.fnm
          pkgs.fzf
          pkgs.fzy
          pkgs.gh
          pkgs.git-absorb
          pkgs.gitleaks
          pkgs.gnugrep
          pkgs.home-mangler
          pkgs.hub
          pkgs.hyperfine
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
          pkgs.units
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
