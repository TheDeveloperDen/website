{
  description = "DevDen Website Nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.treefmt-nix.flakeModule
      ];

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem =
        { config, pkgs, ... }:
        {
          treefmt = {
            projectRootFile = "flake.nix";
            programs = {
              nixfmt.enable = true;
              elm-format.enable = true;
            };
          };

          devShells.default = pkgs.mkShell {
            name = "devden-website";

            nativeBuildInputs = with pkgs; [
              bun
              elmPackages.elm
              elmPackages.elm-format
              elmPackages.elm-language-server
              elmPackages.elm-test
            ];
          };

          packages.default = pkgs.hello;
        };
    };
}
