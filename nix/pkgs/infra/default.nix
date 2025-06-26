{ inputs', pkgs }:
pkgs.writeShellApplication {
  name = "infra";
  runtimeInputs = [
    pkgs.git
    pkgs.terraform
    pkgs.tflint
    pkgs.sops
    pkgs.age
  ];
  text = ''
    # shellcheck disable=SC1091
    source "${./main.sh}" "$@"
  '';
}
