FROM openjdk:11-jre-alpine
LABEL MAINTAINER=juandacorias@gmail.com
COPY ./target/*.jar /app.jar
CMD ["java","-jar","app.jar"]