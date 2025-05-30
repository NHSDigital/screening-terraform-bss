ARG AWS_REGION
ARG ACCOUNT_ID
ARG PULL_THROUGH_REPO

FROM ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PULL_THROUGH_REPO}/library/maven:3.6.3-jdk-11-slim

WORKDIR build

COPY . .

# just build the artefacts, no tests, etc.
RUN mvn clean package -DskipTests -f ./sample-apps/sample-java-app/pom.xml
