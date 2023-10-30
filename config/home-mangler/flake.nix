{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
  }: {
    home-mangler = let
      configuration = system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        packages = pkgs.symlinkJoin {
          name = "home-mangler-packages";
          paths = [
            pkgs.nix-your-shell
            pkgs.alejandra
            pkgs.nil
            pkgs.coreutils
            pkgs.dig
            pkgs.rust-analyzer
            pkgs.nix-top
            pkgs.broot
            pkgs.eza
            pkgs.neovim
            pkgs.jujutsu
            pkgs.bash
            pkgs.fzf
            pkgs.fzy
          ];
        };

        script = pkgs.writeShellScriptBin "home-mangler-script" ''
          ${pkgs.rcm}/bin/rcup -v
        '';

        files =
          pkgs.runCommand "home-mangler-files" {}
          ''
            mkdir $out
            echo "hii" > $out/.foo
            mkdir $out/.config
            echo "hiiiii" > $out/.config/heyy
          '';
      };
    in {
      grandiflora = configuration "aarch64-darwin";
    };
  };
}
