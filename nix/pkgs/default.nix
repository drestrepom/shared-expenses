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
}
