# shellcheck shell=bash

function _init {
  set -o allexport
  eval "$(sops -d --output-type dotenv secrets.yaml)"
  set +o allexport
  
  local infra="./infra"

  pushd "${infra}" || return 1
}

function _apply {
  _init
  terraform init
  if test -n "${CI:-}"; then
    terraform apply -auto-approve
    terraform output -json > tfout.json
    IP=$(jq -r '.apprunner_service_url.value' tfout.json)
    echo "public_api_url=$IP" >> $GITHUB_OUTPUT
  else
    terraform apply
  fi
}

function _lint {
  _init
  terraform init
  tflint --init
  tflint --recursive
}

function _plan {
  _init
  terraform init
  terraform plan -lock=false -refresh=true
}

function main {
  local action="${1:-}"

  case "${action}" in
    apply) _apply "${2:-}" ;;
    lint) _lint ;;
    plan) _plan ;;
    *)
      echo "Usage: integrates-infra <apply|lint|plan>"
      return 1
      ;;
  esac
}

main "${@}"
