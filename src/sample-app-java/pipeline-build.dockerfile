FROM maven:3.6.3-jdk-11-slim

WORKDIR build

COPY . .

# just build the artefacts, no tests, etc.
RUN mvn clean package -DskipTests -f ./src/sample-app-java/pom.xml
