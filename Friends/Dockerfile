# Use an official Ubuntu runtime as a parent imagelatest
FROM python:3.12.0-alpine3.17

# Set environment variables for Spark
ENV SPARK_VERSION=3.5.0
ENV HADOOP_VERSION=3.2

# Install Java
RUN apt-get update && apt-get install -y openjdk-8-jdk

# Download and install Spark
RUN apt-get install -y wget && \
    wget https://dlcdn.apache.org/spark/spark-3.5.0/spark-3.5.0-bin-hadoop3.tgz && \
    tar -xvf spark-3.5.0-bin-hadoop3.tgz && \
    mv spark-3.5.0-bin-hadoop3 /opt/spark && \
    rm spark-3.5.0-bin-hadoop3.tgz

# Set environment variables
ENV SPARK_HOME=/opt/spark
ENV PATH=$PATH:$SPARK_HOME/bin

# Expose Spark ports
EXPOSE 4040 6066 7077 8080


WORKDIR /app

COPY . /app
RUN pip install -r requirements.txt
CMD ["python3", "friends.py"]


