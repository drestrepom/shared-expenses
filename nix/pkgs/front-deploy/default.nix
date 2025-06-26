{ lib', pkgs }:
pkgs.writeShellApplication {
  name = "front-deploy";
  runtimeInputs = [
    pkgs.nodejs
    pkgs.awscli2
    pkgs.sops
    pkgs.age
    pkgs.jq
    pkgs.terraform
  ];
  text = ''
    set -o allexport
    eval "$(sops -d --output-type dotenv secrets.yaml)"
    set +o allexport

    pushd infra
    terraform output -json > tfout.json
    DB_API_HOST="https://$(jq -r '.apprunner_service_url.value' tfout.json)"
    echo "$DB_API_HOST"	
    rm -f tfout.json
    popd
  
    pushd frontend

    # Instalar dependencias de manera reproducible
    npm ci --prefer-offline --no-audit --progress=false

    # Build de producción (sin prompts interactivos)
    CI=true npx --yes ng build --configuration=production \
      --define="DB_API_HOST=\"''${DB_API_HOST}\""

    # Sincronizar únicamente el contenido estático (carpeta browser) al bucket S3
    aws s3 sync dist/frontend/browser s3://shared-expenses-frontend-test-bucket --delete

    popd
  '';
}
