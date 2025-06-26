{ self', pkgs }:
let
  runWrapper = pkgs.runCommand "run-wrapper" { } ''
    mkdir -p $out/bin
    cp ${self'.packages.api-run}/bin/api-run $out/bin/api-run
    chmod +x $out/bin/api-run
  '';
  containerPath = pkgs.dockerTools.buildImage {
    name = "shared-expenses-api";
    tag = "latest";
    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      paths = [
        runWrapper
        pkgs.bash
        pkgs.coreutils
      ];
    };
    config = {
      WorkingDir = "/src";
      Cmd = [ "/bin/api-run" ];
    };
  };
in
pkgs.writeShellApplication {
  name = "api-container";
  runtimeInputs = [
    pkgs.skopeo
    pkgs.awscli2
    pkgs.sops
    pkgs.age
  ];
  text = ''
    set -o allexport
    eval "$(sops -d --output-type dotenv secrets.yaml)"
    set +o allexport
    AWS_REGION="''${AWS_REGION:-us-east-1}"

    ECR_REPO="''${ECR_REPO:-shared-expenses-backend}"

    ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

    ECR_URI="''${ACCOUNT_ID}.dkr.ecr.''${AWS_REGION}.amazonaws.com/''${ECR_REPO}"

    ECR_PASSWORD=$(aws ecr get-login-password --region "$AWS_REGION")

    IMAGE_TAR="${containerPath}"

    echo "[INFO] Pushing container ''${IMAGE_TAR} to ''${ECR_URI}:latest"

    skopeo copy --insecure-policy --dest-creds "AWS:''${ECR_PASSWORD}" \
      "docker-archive://''${IMAGE_TAR}" \
      "docker://''${ECR_URI}:latest"
  '';
}
