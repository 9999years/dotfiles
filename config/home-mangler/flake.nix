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
      pkgs = nixpkgs.legacyPackages.${system};
      home-mangler-lib = home-mangler.lib.${system};
    in
      home-mangler-lib.makeConfiguration
      {
        packages = [
          pkgs.alejandra
          pkgs.bash
          pkgs.broot
          pkgs.cargo-nextest
          pkgs.coreutils
          pkgs.dig
          pkgs.eza
          pkgs.fzf
          pkgs.fzy
          pkgs.gitleaks
          pkgs.jujutsu
          pkgs.lua-language-server
          pkgs.neovim
          pkgs.nil
          pkgs.nix-diff
          pkgs.nix-direnv
          pkgs.nix-top
          pkgs.nix-your-shell
          pkgs.rust-analyzer
          pkgs.stylua
        ];
      };
  in {
    home-mangler = {
      grandiflora = configuration "aarch64-darwin";
      san-fransisco = configuration "aarch64-darwin";
    };
  };
}
