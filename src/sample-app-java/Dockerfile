FROM maven:3.6.3-jdk-11-slim AS builder
 
WORKDIR build
 
COPY . .
 
# just build the artefacts, no tests, etc.
RUN mvn clean package -DskipTests -f pom.xml
 
 
 
# FROM sample-app-build:${VERSION} AS build
 
FROM openjdk:11-jre-slim
 
WORKDIR /app
 
COPY --from=builder /build/target/sample-deployment-0.0.1-SNAPSHOT.jar /usr/local/lib/app.jar
 
RUN groupadd -g 999 adminGroup && \
    useradd -r -u 999 -g adminGroup admin
RUN chown -R admin:adminGroup /app
RUN chmod 755 /app
 
USER admin
 
EXPOSE 8080
ENTRYPOINT ["java","-jar","/usr/local/lib/app.jar"]

