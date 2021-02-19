# Application Metadata
ARG APPLICATION_NAME="demo"
ARG VERSION="0.0.1-SNAPSHOT"
ARG APP_PORT=8080

FROM openjdk:8-jdk-alpine as builder

RUN apk add --no-cache maven

WORKDIR /usr/src/app/src
COPY src/app /usr/src/app/src
RUN mvn package -Dmaven.test.skip=true

FROM openjdk:8-jdk-alpine
ARG APPLICATION_NAME
ARG VERSION
ARG APP_PORT
ENV TERM=xterm-256color

COPY --from=builder /usr/src/app/src/target/${APPLICATION_NAME}-${VERSION}.jar /app/${APPLICATION_NAME}-${VERSION}.jar

EXPOSE ${APP_PORT}
WORKDIR /app
ENV APPLICATION_NAME=${APPLICATION_NAME}
ENV VERSION=${VERSION}

ENTRYPOINT java $JAVA_OPTS -jar /app/${APPLICATION_NAME}-${VERSION}.jar --port=${APP_PORT}