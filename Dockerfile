FROM openjdk:8-jre-alpine
LABEL MAINTAINER=juandacorias@gmail.com
COPY ./target/*.jar /app.jar
USER 1000:1000
CMD ["java","-jar","app.jar"]
