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
    (pkgs.callPackage inputs.pyproject-nix.build.packages {
      inherit python;
    }).overrideScope
      (
        pkgs.lib.composeManyExtensions [
          inputs.pyproject-build-systems.overlays.default
          overlay
        ]
      );
  repo = lib'.projectPath "/shared-expenses-api";
in
pkgs.writeShellApplication {
  name = "api-run";
  runtimeInputs = pkgs.lib.flatten [
    pkgs.uv
    ((pythonSet.mkVirtualEnv "shared-expenses-api-env" workspace.deps.all).overrideAttrs (old: {
      venvIgnoreCollisions = [ "*" ];
    }))
  ];
  text = ''
    pushd ${repo}

    # Run in production mode: no auto-reload, multiple workers
    export WEB_CONCURRENCY="4"
    uvicorn shared_expenses_api:app --host 0.0.0.0 --port 8000 --workers "$WEB_CONCURRENCY"
    popd
  '';
}
