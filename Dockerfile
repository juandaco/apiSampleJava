#BUILD IMAGE
FROM openjdk:8-jre-alpine
LABEL MAINTAINER=juandacorias@gmail.com
COPY ./target/*.jar /app.jar
CMD ["java","-jar","app.jar"]

#docker build -t  jenkinsApp
#docker run --name jenkinsApp-con jenkinsApp

