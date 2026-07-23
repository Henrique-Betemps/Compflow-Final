# Usa uma versão oficial e super leve do Java 17
FROM eclipse-temurin:17-jdk-alpine

# Define um volume para arquivos temporários que o Spring Boot usa
VOLUME /tmp

# Copia o arquivo .jar gerado pelo Maven para dentro do contêiner
COPY target/compflow-0.0.1-SNAPSHOT.jar app.jar

# Executa a aplicação limitando o uso de memória a 512MB
ENTRYPOINT ["java", "-Xmx512m", "-jar", "/app.jar"]