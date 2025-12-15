# ====================== Stage 1: Build ======================
FROM maven:3.9.6-eclipse-temurin-17 AS build

WORKDIR /app

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy rest of the source code
COPY src ./src

# Build the application
RUN mvn package -DskipTests

# ====================== Stage 2: Run ======================
FROM eclipse-temurin:17-jdk

WORKDIR /app

# Copy built jar from stage 1
COPY --from=build /app/target/*.jar app.jar

# Expose Razorpay backend port
EXPOSE 8081

# Start the Spring Boot app
ENTRYPOINT ["java", "-jar", "app.jar"]

