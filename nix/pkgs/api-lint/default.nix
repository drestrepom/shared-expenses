{
  inputs,
  pkgs,
  lib',
}:
let
  python = pkgs.python312;
  workspace = inputs.uv2nix.lib.workspace.loadWorkspace {
    workspaceRoot = ../../../shared-expenses-api;
  };
  overlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
  };
  pythonSet =
    # Use base package set from pyproject.nix builders
    (pkgs.callPackage inputs.pyproject-nix.build.packages {
      inherit python;
    }).overrideScope
      (
        pkgs.lib.composeManyExtensions [
          inputs.pyproject-build-systems.overlays.default
          overlay
        ]
      );
in
pkgs.writeShellApplication {
  name = "api-lint";
  runtimeInputs = pkgs.lib.flatten [
    pkgs.uv
    ((pythonSet.mkVirtualEnv "shared-expenses-api-env" workspace.deps.all).overrideAttrs (old: {
      # You could also ignore all collisions with:
      venvIgnoreCollisions = [ "*" ];
    }))
  ];
  text = ''
    pushd shared-expenses-api

     if test -n "''${CI:-}"; then
       ruff format --config ruff.toml --diff
       ruff check --config ruff.toml
     else
       ruff format --config ruff.toml
       ruff check --config ruff.toml --fix
     fi

    mypy --config-file mypy.ini .
    popd
  '';
}
