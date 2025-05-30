ARG VERSION
ARG AWS_REGION
ARG ACCOUNT_ID
ARG PULL_THROUGH_REPO
FROM sample-app-build:${VERSION} AS build

FROM ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PULL_THROUGH_REPO}/library/openjdk:11-jre-slim

WORKDIR /app

COPY --from=build /build/sample-apps/sample-java-app/target/sample-deployment-0.0.1-SNAPSHOT.jar /usr/local/lib/app.jar

RUN groupadd -g 999 adminGroup && \
    useradd -r -u 999 -g adminGroup admin
RUN chown -R admin:adminGroup /app
RUN chmod 755 /app

USER admin

EXPOSE 8443
ENTRYPOINT ["java","-jar","/usr/local/lib/app.jar"]
