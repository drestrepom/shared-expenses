{
  description = "Shared Expenses";

  inputs = {
    flake-parts.url =
      "github:hercules-ci/flake-parts/f4330d22f1c5d2ba72d3d22df5597d123fdb60a9?shallow=1";
    nixpkgs.url =
      "github:nixos/nixpkgs/ab472a7a8fcfd7c778729e7d7c8c3a9586a7cded?shallow=1";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      debug = false;

      systems = [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];

      perSystem = { inputs', pkgs, self', system, ... }:
        let
          projectPath = path: ./. + path;
          lib' = {
            envs = import ./nix/envs {
              inherit inputs pkgs projectPath inputs' lib';
            };
            inherit projectPath;
          };
        in {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };

          packages = import ./nix/pkgs { inherit inputs' lib' pkgs self'; };
        };
    };
}
