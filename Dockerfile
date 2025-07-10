# --- front ---
FROM node:16-alpine AS frontend-builder
WORKDIR /app/front
COPY front/package*.json ./
RUN npm ci
COPY front/ .
RUN npm run build

# --- back ---
FROM maven:3.8-amazoncorretto-17 AS backend-builder
WORKDIR /app/back
COPY back/pom.xml ./
RUN mvn dependency:go-offline -B
COPY back/src ./src
RUN mvn clean package -DskipTests -B

# --- Image finale ---
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=backend-builder /app/back/target/*.jar app.jar
COPY --from=frontend-builder /app/front/dist ./static
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]
