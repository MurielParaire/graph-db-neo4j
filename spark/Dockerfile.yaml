# Stage 1: Downloader with full tools
FROM debian:bullseye-slim AS downloader

# Install curl and set working directory
RUN apt-get update && apt-get install -y curl && mkdir -p /tmp/jars

WORKDIR /tmp/jars

RUN useradd -u 185 -m -s /bin/bash spark

# Download the JARs
RUN curl -L -o hadoop-aws-3.3.4.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar && \
curl -L -o aws-java-sdk-bundle-1.12.262.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.262/aws-java-sdk-bundle-1.12.262.jar && \    
chmod 644 *.jar && chown -R spark:spark .

FROM spark:3.5.3

COPY --from=downloader /tmp/jars/*.jar /opt/spark/jars/