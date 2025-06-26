{ pkgs, self' }:
let
  mkApp = name: package: {
    type = "app";
    program = "${package}/bin/${name}";
  };
  apps = pkgs.lib.mapAttrs mkApp self'.packages;
in
apps
