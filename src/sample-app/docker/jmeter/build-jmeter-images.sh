#!/bin/bash -e

ECR_REPO='730319765130.dkr.ecr.eu-west-2.amazonaws.com/texas'
JMETER_VERSION='5.4.1'
# TAG="$JMETER_VERSION"
TAG="$JMETER_VERSION-log4j2-patch"

echo "Building JMeter images using version $JMETER_VERSION..."
echo ""

docker build --no-cache --build-arg JMETER_VERSION="$JMETER_VERSION" --tag="$ECR_REPO/jmeter-base:$TAG" -f jmeter-base.dockerfile .
docker build --build-arg TAG=$TAG --tag="$ECR_REPO/jmeter-master:$TAG" -f jmeter-master.dockerfile .
docker build --build-arg TAG=$TAG --tag="$ECR_REPO/jmeter-slave:$TAG" -f jmeter-slave.dockerfile .

docker push "$ECR_REPO/jmeter-master:$TAG" 
docker push "$ECR_REPO/jmeter-slave:$TAG" 
