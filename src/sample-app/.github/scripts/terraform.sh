#!/usr/bin/env bash

STACK=$1
ENV=$2
REGION=$3
MODE=$4
OVERRIDE_TFVARS=$5

if [[ ! -f terraform.sh ]]
then
  echo "$0 must be run from the same directory"
  exit 1
fi

if [[ ( "$#" -lt 4 ) || ( "$#" -gt 5 ) ]]
then
	printf "\n $RED  Usage: $0 <stack> <tfvars env name> <tfvars region name> <command> <tfvars overrides (optional)>\n"
	printf "\n     e.g. $0 app-mesh dev-k8s eu-west-2 plan \n"
  printf "\n\n"
  printf "\t|-- Available Commands --|\n"
  printf "\t|------------------------|\n"
  printf "\t|plan                    |\n"
  printf "\t|plan-destroy            |\n"
  printf "\t|plan-log                |\n"
  printf "\t|apply                   |\n"
  printf "\t|apply-refresh           |\n"
  printf "\t|apply-log               |\n"
  printf "\t|destroy                 |\n"
  printf "\t|destroy-log             |\n"
  printf "\t|------------------------|\n"
	exit 1
fi

if [[ $MODE == 'plan' ]]
then
  TF_ACTION_STRING='plan'
elif [[ $MODE == 'apply-refresh' ]]
then
  TF_ACTION_STRING='apply -refresh-only -auto-approve'
elif [[ $MODE = 'apply' ]]
then
  TF_ACTION_STRING='apply -auto-approve'
elif [[ $MODE = 'plan-destroy' ]]
then
  TF_ACTION_STRING='plan -destroy'
elif [[ $MODE = 'plan-log' ]]
then
  export TF_LOG='Trace'
  TF_ACTION_STRING='plan'
elif [[ $MODE = 'apply-log' ]]
then
  export TF_LOG=Trace
  TF_ACTION_STRING='apply -auto-approve'
elif [[ $MODE = 'destroy' ]]
then
  TF_ACTION_STRING='destroy -auto-approve'
  if [[ $REGION == 'eu-west-2' ]] 
  then
    if [[ $ENV != 'dev-k8s' && $ENV != 'dev-mgmt' && $ENV != 'test-k8s' && $ENV != 'test-mgmt' ]]
    then
      echo "You can only destroy a dev or test environment"
      exit 1
    fi
  fi
elif [[ $MODE = 'destroy-log' ]]
then
  export TF_LOG='Trace'
  TF_ACTION_STRING='destroy -auto-approve'
  if [[ $ENV != 'dev-k8s' && $ENV != 'dev-mgmt' && $ENV != 'test-k8s' && $ENV != 'test-mgmt' ]]
  then
    echo "You can only destroy a dev or test environment"
    exit 1
  fi
else
  echo "invalid mode $MODE"
  exit 1
fi

TF_DIR='../../terraform'
TFVARS_FILE="../../tfvars/env/$ENV-$REGION.tfvars"
GLOBAL_TFVARS_FILE="../../tfvars/global/global.tfvars"
STACKDIR="$TF_DIR/stacks/$STACK"
TF_OUTPUT_FILE="/var/tmp/$ENV-$REGION-$STACK-output.txt"

> $TF_OUTPUT_FILE

cd $STACKDIR

echo "DEBUG:  "
pwd
echo ""

# keep these the same unless doing an upgrade
CURRENT_TF_VERSION="1.7.5"
NEW_TF_VERSION="1.7.5"

# Add environment names here to keep them on the current Terraform version when doing an upgrade
# "live-prod live-mgmt live-nonprod test-mgmt test-k8s dev-mgmt dev-k8s"
PROTECTED_ENVIRONMENTS=""
if echo "$PROTECTED_ENVIRONMENTS" | grep -w -q "$ENV"
then
  TF_VERSION=$CURRENT_TF_VERSION
else
  TF_VERSION=$NEW_TF_VERSION
fi

tee versions.tf <<EOF > /dev/null
terraform {
  required_version = "= $TF_VERSION"
}
EOF

for BUCKET in $(aws s3api list-buckets --query 'Buckets[?contains(Name, `terraform-state-store`) == `true`].Name' --output text); do
  RESULT=$(aws s3api get-bucket-location --bucket $BUCKET --query 'LocationConstraint' --output text)
  if [[ $RESULT == $REGION ]]; then
    TF_BUCKET="$BUCKET"
  fi
done


if [ -f "pre_deploy.sh" ]; then
  echo "Executing pre_deploy.sh"
  source pre_deploy.sh
fi;

terraform init -upgrade -reconfigure -backend-config="bucket=$TF_BUCKET" -backend-config="region=$REGION" -backend-config="key=$(basename $(pwd))/terraform.tfstate"

if [[ ${OVERRIDE_TFVARS} == '' ]]
then
    terraform $TF_ACTION_STRING -var-file=${GLOBAL_TFVARS_FILE} -var-file=${TFVARS_FILE} 2>&1 | tee $TF_OUTPUT_FILE
else
    terraform $TF_ACTION_STRING -var-file=${GLOBAL_TFVARS_FILE} -var-file=${TFVARS_FILE} -var="${OVERRIDE_TFVARS}" 2>&1 | tee $TF_OUTPUT_FILE
fi

# ensures that during an upgrade the local version files don't get reverted to the previous version
tee versions.tf <<EOF > /dev/null
terraform {
  required_version = "= $NEW_TF_VERSION"
}
EOF

# Make TF/pipeline error if a stack fails
if [[ "$(grep '^.*Error:' $TF_OUTPUT_FILE)" != '' ]]
then
  exit 1
fi
