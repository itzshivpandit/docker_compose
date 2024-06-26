#!/bin/bash


mkdir -p my-maven-project/src/main/java/com/example
mkdir -p my-maven-project/src/test/java/com/example


cat << 'EOF' > my-maven-project/pom.xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.example</groupId>
    <artifactId>my-app</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <maven.compiler.source>1.8</maven.compiler.source>
        <maven.compiler.target>1.8</maven.compiler.target>
    </properties>

    <dependencies>
        <dependency>
            <groupId>junit</groupId>
            <artifactId>junit</artifactId>
            <version>4.12</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>2.22.2</version>
            </plugin>
        </plugins>
    </build>
</project>
EOF


cat << 'EOF' > my-maven-project/src/main/java/com/example/App.java
package com.example;

public class App {
    public static void main(String[] args) {
        System.out.println("Hello World!");
    }
}
EOF


cat << 'EOF' > my-maven-project/src/test/java/com/example/AppTest.java
package com.example;

import org.junit.Test;
import static org.junit.Assert.*;

public class AppTest {
    @Test
    public void testApp() {
        assertTrue(true);
    }
}
EOF


cat << 'EOF' > docker-compose.yml
version: '3.8'

services:
  jenkins:
    image: jenkins/jenkins:lts
    container_name: jenkins
    ports:
      - "8080:8080"
      - "50000:50000"
    volumes:
      - jenkins_home:/var/jenkins_home
    networks:
      - dev-network
    deploy:
      resources:
        limits:
          memory: 512M

  sonarqube:
    image: sonarqube:latest
    container_name: sonarqube
    ports:
      - "9000:9000"
    networks:
      - dev-network
    deploy:
      resources:
        limits:
          memory: 2G

  maven:
    image: maven:3.8.1-jdk-11
    container_name: maven
    volumes:
      - ./my-maven-project:/usr/src/mymaven
      - maven_repository:/root/.m2
    working_dir: /usr/src/mymaven
    networks:
      - dev-network
    command: mvn clean install
    deploy:
      resources:
        limits:
          memory: 256M

networks:
  dev-network:

volumes:
  jenkins_home:
  maven_repository:
EOF

# Run Docker Compose
echo "Setting up Jenkins, SonarQube, and Maven containers..."
docker-compose up -d

# Wait for containers to start
echo "Waiting for containers to start..."
sleep 60

# Output URLs for jenkins and SonarQube
echo "Jenkins should be accessible at http://localhost:8080"
echo "SonarQube should be accessible at http://localhost:9000"

# instructions
echo "Please configure Jenkins to run tests and SonarQube to analyze the test results."

#end
