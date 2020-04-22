#!/bin/bash

# exit on failures
set -e
set -o pipefail

usage() {
  echo "Usage: $(basename "$0") [OPTIONS]" 1>&2
  echo "  -h               - help"
  echo "  -p <profile>     - AWS Profile       ( default 'default' )"
  echo "  -P <port>        - Rails server port ( default '3000' )"
  exit 1
}

PROFILE="default"
PORT="4567"
CI_PIPELINE_NAME="ci-terraform-build-pipeline"
ENVIRONMENT_VARIABLES_GUI_PATH="lib/environment-variables-gui"

while getopts "p:P:h" opt; do
  case $opt in
    p)
      PROFILE=$OPTARG
      ;;
    P)
      PORT=$OPTARG
      ;;
    h)
      usage
      exit;;
    *)
      usage
      exit;;
  esac
done

echo "Finding dalmatian config ..."

CI_PIPELINE=$(aws codepipeline get-pipeline --name "$CI_PIPELINE_NAME" --profile "$PROFILE")
CI_BUILD_PROJECT_NAME=$(echo "$CI_PIPELINE" | jq -r '.pipeline.stages[] | select(.name == "Build") | .actions[] | select(.name == "Build-ci") | .configuration.ProjectName')

BUILD_PROJECTS=$(aws codebuild batch-get-projects --names "$CI_BUILD_PROJECT_NAME" --profile "$PROFILE")
DALMATIAN_CONFIG_REPO=$(echo "$BUILD_PROJECTS" | jq -r '.projects[0].environment.environmentVariables[] | select(.name == "dalmatian_config_repo") | .value')

rm -rf "$ENVIRONMENT_VARIABLES_GUI_PATH/dalmatian-config"
git clone "$DALMATIAN_CONFIG_REPO" "$ENVIRONMENT_VARIABLES_GUI_PATH/dalmatian-config"

cd "$ENVIRONMENT_VARIABLES_GUI_PATH"

trap "exit" INT TERM ERR
trap "kill 0" EXIT

echo "Launching gui ..."

bundle install
AWS_PROFILE="$PROFILE" PORT="$PORT" ruby app.rb &
while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:$PORT/check)" != "200" ]];
do
  sleep 0.5;
done

open "http://localhost:$PORT"

read -p ""
