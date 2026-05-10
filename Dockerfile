FROM eclipse-temurin:8-jdk AS builder

WORKDIR /build

RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests

FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN sed -i 's@http://archive.ubuntu.com@http://mirrors.aliyun.com@g' /etc/apt/sources.list.d/ubuntu.sources && \
    sed -i 's@http://security.ubuntu.com@http://mirrors.aliyun.com@g' /etc/apt/sources.list.d/ubuntu.sources

RUN apt-get update && apt-get install -y \
    openjdk-8-jdk \
    mysql-server \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN mkdir -p /app/frontend /app/backend /app/db

COPY --from=builder /build/target/StudentScore-0.0.1-SNAPSHOT.jar /app/backend/

COPY src/main/resources/public /app/frontend

COPY src/main/resources/score.sql /app/db/

COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

EXPOSE 8088 3306

CMD ["/app/start.sh"]
