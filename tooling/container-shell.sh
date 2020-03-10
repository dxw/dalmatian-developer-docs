#!/bin/bash

# exit on failures
set -e
set -o pipefail

usage() {
  echo "Usage: $(basename "$0") [OPTIONS]" 1>&2
  echo "  -h               - help"
  echo "  -e <environment> - environment   ( required )"
  echo "  -s <service>     - service       ( required )"
  echo "  -p <profile>     - AWS Profile   ( default 'default' )"
  exit 1
}

# if there are no arguments passed exit with usage
if [ $# -lt 0 ];
then
 usage
fi

PROFILE="default"

while getopts "p:e:s:h" opt; do
  case $opt in
    e)
      SERVICE_ENVIRONMENT=$OPTARG
      ;;
    s)
      SERVICE_NAME=$OPTARG
      ;;
    p)
      PROFILE=$OPTARG
      ;;
    h)
      usage
      exit;;
    *)
      usage
      exit;;
  esac
done

if [[ -z "$SERVICE_ENVIRONMENT" || -z "$SERVICE_NAME"  ]]; then
  usage
fi

CLUSTERS=$(aws ecs list-clusters --profile "$PROFILE")
CLUSTERS_LENGTH=$(echo "$CLUSTERS" | jq -r '.clusterArns | length')

echo "Seaching for service '$SERVICE_NAME' in '$SERVICE_ENVIRONMENT' environment ..."

for i in $( seq 0 $((CLUSTERS_LENGTH - 1)) ); do
  CLUSTER_ARN=$(echo "$CLUSTERS" | jq -r --argjson i "$i" '.clusterArns[$i]')
  if [[ "$CLUSTER_ARN" != *"$SERVICE_ENVIRONMENT"* ]]; then
    continue
  fi
  SERVICES=$(aws ecs list-services --cluster "$CLUSTER_ARN" --profile "$PROFILE")
  SERVICES_LENGTH=$(echo "$SERVICES" | jq -r '.serviceArns | length')
  for j in $( seq 0 $((SERVICES_LENGTH - 1)) ); do
    SERVICE_ARN=$(echo "$SERVICES" | jq -r --argjson j "$j" '.serviceArns[$j]')
    if [[ "$SERVICE_ARN" != *"$SERVICE_NAME-$SERVICE_ENVIRONMENT"* || "$SERVICE_ARN" == *"daemon"* || "$SERVICE_ARN" == *"worker"* ]]; then
      continue
    fi
    TASK_ARN=$(aws ecs list-tasks --service-name "$SERVICE_ARN" --cluster "$CLUSTER_ARN" --profile "$PROFILE" | jq -r '.taskArns[0]')
    TASKS=$(aws ecs describe-tasks --cluster "$CLUSTER_ARN" --tasks "$TASK_ARN" --profile "$PROFILE")
    CONTAINER_INSTANCE_ARN=$(echo "$TASKS" | jq -r '.tasks[0].containerInstanceArn')
    CONTAINER_INSTANCE_ID=$(aws ecs describe-container-instances --cluster "$CLUSTER_ARN" --container-instances "$CONTAINER_INSTANCE_ARN" --profile "$PROFILE" | jq -r '.containerInstances[0].ec2InstanceId')
    CONTAINER_NAME=$(echo "$TASKS" | jq -r '.tasks[0].containers[0].name')
    echo "Connecting to $CONTAINER_NAME on instance $CONTAINER_INSTANCE_ID ..."
    aws ssm start-session --target "$CONTAINER_INSTANCE_ID" --profile "$PROFILE" --document-name "$SERVICE_ENVIRONMENT-$SERVICE_NAME-container-access"
    exit 0
  done
done

echo "No service found"
exit 1
