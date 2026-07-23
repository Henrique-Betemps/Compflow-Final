# ---------- Etapa 1: compilar o projeto com Maven ----------
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

# Copia primeiro só o pom.xml pra aproveitar cache de dependências
# (só reinstala as dependências se o pom.xml mudar)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Agora copia o código-fonte e compila de verdade
COPY src ./src
RUN mvn clean package -DskipTests

# ---------- Etapa 2: imagem final, só com o necessário pra rodar ----------
FROM eclipse-temurin:17-jdk-alpine

VOLUME /tmp

# Pega o .jar já compilado da etapa anterior (não depende de nada
# ter sido rodado manualmente antes do "docker build")
COPY --from=build /app/target/compflow-0.0.1-SNAPSHOT.jar app.jar

ENTRYPOINT ["java", "-Xmx512m", "-jar", "/app.jar"]
