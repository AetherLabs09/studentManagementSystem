#!/bin/bash

mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld

if [ ! -f "/var/lib/mysql/ibdata1" ]; then
    echo "Initializing MySQL data directory..."
    mysqld --initialize-insecure --user=mysql
fi

echo "Starting MySQL..."
mysqld --user=mysql --daemonize
sleep 10

if [ ! -d "/var/lib/mysql/score" ]; then
    echo "Setting up database..."
    mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED WITH caching_sha2_password BY 'root';
FLUSH PRIVILEGES;
EOF
    
    mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS score CHARACTER SET utf8;"
    mysql -u root -proot score < /app/db/score.sql
    
    echo "Restarting MySQL to apply changes..."
    mysqladmin -u root -proot shutdown
    sleep 3
    mysqld --user=mysql --daemonize
    sleep 5
fi

echo "Starting Spring Boot application..."
cd /app/backend
java -jar StudentScore-0.0.1-SNAPSHOT.jar
