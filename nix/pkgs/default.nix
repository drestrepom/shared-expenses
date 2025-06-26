{ inputs', lib', pkgs, self' }: {
  infra = pkgs.callPackage ./infra { inherit inputs' pkgs; };
}
