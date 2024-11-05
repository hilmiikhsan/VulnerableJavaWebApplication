# JDK 8 + Maven 3.8.6 untuk multi-arch support (arm64 dan amd64)
FROM maven:3.8.6-openjdk-8

# Prepare the folder
RUN mkdir -p /app
COPY . /app
WORKDIR /app

# Generates the package
RUN mvn install

# Http port
ENV PORT=9000
EXPOSE $PORT

# Executes spring boot's jar
CMD ["java", "-jar", "target/vulnerablejavawebapp-0.0.1-SNAPSHOT.jar"]
