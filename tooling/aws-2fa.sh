#!/bin/bash

# exit on failures
set -e
set -o pipefail

usage() {
  echo "Usage: $(basename "$0") [OPTIONS]" 1>&2
  echo "  -h               - help"
  echo "  -m <mfa_code>    - mfa code       ( required )"
  echo "  -e               - export format  ( otherwise outputs the mfa credentials to ~/.aws/credentials )"
  exit 1
}

# if there are no arguments passed exit with usage
if [ $# -lt 0 ];
then
 usage
fi

EXPORT_FORMAT=0

while getopts "m:eh" opt; do
  case $opt in
    m)
      MFA_CODE=$OPTARG
      ;;
    e)
      EXPORT_FORMAT=1
      ;;
    h)
      usage
      exit;;
    *)
      usage
      exit;;
  esac
done

if [ -z "$MFA_CODE" ]; then
  usage
fi

USERNAME=$(aws sts get-caller-identity | jq -r .Arn | rev | cut -f1 -d'/' | rev)
MFA_DEVICE=$(aws iam list-mfa-devices --user-name $USERNAME | jq -r .MFADevices[0].SerialNumber)
JSON=$(aws sts get-session-token --serial-number $MFA_DEVICE --token-code $MFA_CODE)
ACCESS_KEY_ID=$(echo $JSON | jq -r .Credentials.AccessKeyId)
SECRET_ACCESS_KEY=$(echo $JSON | jq -r .Credentials.SecretAccessKey)
SESSION_TOKEN=$(echo $JSON | jq -r .Credentials.SessionToken)
if [ "$EXPORT_FORMAT" == 0 ]; then
  echo "Modifying credentials file ..."
  MFA_LINENUM=$(grep -n '\[mfa\]' ~/.aws/credentials | cut -f1 -d':' | head -n1 || echo "")
  if [ "$MFA_LINENUM" != "" ]; then
    MFA_LINENUM_END=$((MFA_LINENUM + 4))
    sed -i '' -e "${MFA_LINENUM},${MFA_LINENUM_END}d" ~/.aws/credentials
  fi
  echo "[mfa]" >> ~/.aws/credentials
  echo "aws_access_key_id=$ACCESS_KEY_ID" >> ~/.aws/credentials
  echo "aws_secret_access_key=$SECRET_ACCESS_KEY" >> ~/.aws/credentials
  echo "aws_session_token=$SESSION_TOKEN" >> ~/.aws/credentials
  echo "Modified."
else
  echo "export AWS_ACCESS_KEY_ID=$ACCESS_KEY_ID"
  echo "export AWS_SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY"
  echo "export AWS_SESSION_TOKEN=$SESSION_TOKEN"
fi
