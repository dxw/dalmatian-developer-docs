#!/bin/bash

# exit on failures
set -e
set -o pipefail

usage() {
  echo "Usage: $(basename "$0") [OPTIONS]" 1>&2
  echo "  -h                  - help"
  echo "  -i <infrastructure> - infrastructure      ( required )"
  echo "  -c <cluster_suffix> - cluster name suffix ( optional )"
  echo "  -e <environment>    - environment         ( required )"
  echo "  -s <service>        - service             ( required )"
  echo "  -p <profile>        - AWS Profile         ( default 'default' )"
  exit 1
}

# if there are no arguments passed exit with usage
if [ $# -lt 0 ];
then
 usage
fi

PROFILE="default"

while getopts "p:e:s:i:c:h" opt; do
  case $opt in
    i)
      SERVICE_INFRASTRUCTURE=$OPTARG
      ;;
    c)
      CLUSTER_SUFFIX=$OPTARG
      ;;
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

if [[ -z "$SERVICE_ENVIRONMENT" || -z "$SERVICE_NAME" || -z $SERVICE_INFRASTRUCTURE ]]; then
  usage
fi

CLUSTERS=$(aws ecs list-clusters --profile "$PROFILE")
CLUSTERS_LENGTH=$(echo "$CLUSTERS" | jq -r '.clusterArns | length')

echo "Seaching for service '$SERVICE_NAME' in '$SERVICE_INFRASTRUCTURE'/'$SERVICE_ENVIRONMENT' environment ..."

for i in $( seq 0 $((CLUSTERS_LENGTH - 1)) ); do
  CLUSTER_ARN=$(echo "$CLUSTERS" | jq -r --argjson i "$i" '.clusterArns[$i]')
  CLUSTER_NAME="/$SERVICE_INFRASTRUCTURE-$SERVICE_ENVIRONMENT"
  if [ -n "$CLUSTER_SUFFIX" ]
  then
    CLUSTER_NAME="/$SERVICE_INFRASTRUCTURE-$SERVICE_ENVIRONMENT-$CLUSTER_SUFFIX"
  fi
  if [[ "$CLUSTER_ARN" != *"$CLUSTER_NAME" ]]; then
    continue
  fi
  SERVICES=$(aws ecs list-services --cluster "$CLUSTER_ARN" --profile "$PROFILE")
  SERVICES_LENGTH=$(echo "$SERVICES" | jq -r '.serviceArns | length')
  for j in $( seq 0 $((SERVICES_LENGTH - 1)) ); do
    SERVICE_ARN=$(echo "$SERVICES" | jq -r --argjson j "$j" '.serviceArns[$j]')
    if [[ "$SERVICE_ARN" != *"$CLUSTER_NAME/$SERVICE_NAME" || "$SERVICE_ARN" == *"daemon"* || "$SERVICE_ARN" == *"worker"* ]]; then
      continue
    fi
    TASK_ARN=$(aws ecs list-tasks --service-name "$SERVICE_ARN" --cluster "$CLUSTER_ARN" --profile "$PROFILE" | jq -r '.taskArns[0]')
    TASKS=$(aws ecs describe-tasks --cluster "$CLUSTER_ARN" --tasks "$TASK_ARN" --profile "$PROFILE")
    TASK_DEFINITION_ARN=$(echo "$TASKS" | jq -r '.tasks[0].taskDefinitionArn')
    CONTAINER_INSTANCE_ARN=$(echo "$TASKS" | jq -r '.tasks[0].containerInstanceArn')
    CONTAINER_NAME_PREFIX="ecs-$(echo "$TASK_DEFINITION_ARN" | cut -d'/' -f2| sed -e 's/:/-/')-$SERVICE_INFRASTRUCTURE-$SERVICE_NAME-$SERVICE_ENVIRONMENT-"
    CONTAINER_INSTANCE_ID=$(aws ecs describe-container-instances --cluster "$CLUSTER_ARN" --container-instances "$CONTAINER_INSTANCE_ARN" --profile "$PROFILE" | jq -r '.containerInstances[0].ec2InstanceId')
    CONTAINER_NAME=$(echo "$TASKS" | jq -r '.tasks[0].containers[0].name')
    echo "Connecting to $CONTAINER_NAME on instance $CONTAINER_INSTANCE_ID ..."
    aws ssm start-session --target "$CONTAINER_INSTANCE_ID" --profile "$PROFILE" --document-name "$SERVICE_INFRASTRUCTURE-$SERVICE_NAME-$SERVICE_ENVIRONMENT-ecs-service-container-access" --parameters "ContainerNamePrefix=$CONTAINER_NAME_PREFIX"
    exit 0
  done
done

echo "No service found"
exit 1
