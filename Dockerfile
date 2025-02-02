FROM maven:3.6.3-jdk-8

WORKDIR /app

RUN git clone https://github.com/vitalibo/Brick-Game-9999-in-1.git

WORKDIR /app/Brick-Game-9999-in-1

RUN mvn clean install