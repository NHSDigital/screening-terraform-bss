#!/usr/bin/env bash

RUNNER_LABEL=$1
RUNNER_TAG=${2:-"dev"}

echo "RUNNER_LABEL: $RUNNER_LABEL"

VPC_ID=$(aws ec2 describe-vpcs --filter "Name=tag:Name,Values=*texas*" --query "Vpcs[].VpcId" --output text)
echo $VPC_ID

SUBNETS=$(aws ec2 describe-subnets --filter Name=vpc-id,Values=$VPC_ID --query 'Subnets[?MapPublicIpOnLaunch==`false`].SubnetId' | jq -c)
echo $SUBNETS

SECURITY_GROUP=$(aws ec2 describe-security-groups --filter "Name=group-name,Values=texas-github-runners-sg" --query 'SecurityGroups[*].[GroupId]'  --output text)
echo $SECURITY_GROUP

TASK_DEFINITION_ARN=$(aws ecs describe-task-definition --task-definition texas-github-runners-$RUNNER_TAG --query taskDefinition.taskDefinitionArn --output text)
echo $TASK_DEFINITION_ARN

aws ecs run-task \
    --cluster texas-github-runners \
    --task-definition $TASK_DEFINITION_ARN \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=$SUBNETS,securityGroups=['$SECURITY_GROUP'],assignPublicIp=DISABLED}" \
    --overrides "{
        \"containerOverrides\": [
            {
                \"environment\": [
                    {
                        \"name\": \"RUNNER_LABEL\",
                        \"value\": \"$RUNNER_LABEL\"
                    },
                    {
                        \"name\": \"GITHUB_REPO\",
                        \"value\": \"sample-deployment-pipeline\"
                    }
                ],
                \"name\": \"texas-github-runner\"
            }
        ]
    }"
