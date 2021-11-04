FROM openjdk:8-jre-alpine
LABEL MAINTAINER=juandacorias@gmail.com
COPY ./target/*.jar /app.jar
CMD ["java","-jar","app.jar"]
