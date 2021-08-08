#!/bin/bash
set -e
set -x

STACK_NAME=$1
ALB_LISTENER_ARN=$2

if ! aws cloudformation describe-stacks --region us-west-2 --stack-name $STACK_NAME 2>&1 > /dev/null
then
    finished_check=stack-create-complete
else
    finished_check=stack-update-complete
fi

aws cloudformation deploy \
    --region us-west-2 \
    --stack-name $STACK_NAME \
    --template-file service.yaml \
    --capabilities CAPABILITY_NAMED_IAM \
    --parameter-overrides \
    "DockerImage=107936300658.dkr.ecr.us-west-2.amazonaws.com/example-webapp:$(git rev-parse HEAD)" \
    "VPC=vpc-56b5dd33" \
    "Subnet=subnet-0d8b3354" \
    "Cluster=default" \
    "Listener=$ALB_LISTENER_ARN"

aws cloudformation wait $finished_check --region us-west-2 --stack-name $STACK_NAME
