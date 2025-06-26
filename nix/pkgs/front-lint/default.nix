{ lib', pkgs }:
pkgs.writeShellApplication {
  name = "front-lint";
  runtimeInputs = [ pkgs.nodejs ];
  text = ''
    npx --yes eslint .
  '';
  bashOptions = [
    "errexit"
    "nounset"
    "pipefail"
  ];
}
