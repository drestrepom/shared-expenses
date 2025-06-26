{
  inputs',
  inputs,
  lib',
  pkgs,
  self',
}:
{
  infra = pkgs.callPackage ./infra { inherit inputs' pkgs; };
  front-lint = pkgs.callPackage ./front-lint { inherit lib' pkgs; };
  api-lint = pkgs.callPackage ./api-lint { inherit inputs pkgs lib'; };
  front-deploy = pkgs.callPackage ./front-deploy { inherit lib' pkgs; };
  api-run = pkgs.callPackage ./api-run { inherit inputs pkgs lib'; };
  api-container = pkgs.callPackage ./api-container { inherit self' pkgs; };
  api-container-push = pkgs.callPackage ./api-container-push { inherit self' pkgs; };
}
