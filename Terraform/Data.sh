#!/bin/bash
echo "Apt update"
sudo apt update
echo "Installing Java"
sudo apt-get -y install default-jdk default-jre

echo "Installing Hadoop"
wget https://downloads.apache.org/hadoop/common/hadoop-3.3.1/hadoop-3.3.1.tar.gz
tar -xvzf hadoop-3.3.1.tar.gz
sudo mv hadoop-3.3.1 /usr/local/hadoop
rm -r hadoop-3.3.1.tar.gz

git clone https://github.com/kerv17/CloudTP2
cd CloudTP2
git checkout test

echo "Setting Hadoop environment variables"
export HADOOP_HOME=/usr/local/hadoop
export PATH=$PATH:/usr/local/hadoop/sbin:/usr/local/hadoop/bin
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# PG4300.TXT experiment
echo "Wordcount on pg4300.txt with hadoop"
{ time hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.1.jar wordcount pg4300.txt output_pg4300 ; } 2> time_hadoop_pg4300.txt

echo "Wordcount on pg4300.txt with linux cat"
{ time cat pg4300.txt | tr ' ' '\n' | sort | uniq -c ; } 2> time_linux_pg4300.txt

echo "Installing tinyurl datasets in input_datasets"
hdfs dfs -mkdir input_datasets
cd input_datasets
wget https://tinyurl.com/4vxdw3pa
wget https://tinyurl.com/kh9excea
wget https://tinyurl.com/dybs9bnk
wget https://tinyurl.com/datumz6m
wget https://tinyurl.com/j4j4xdw6
wget https://tinyurl.com/ym8s5fm4
wget https://tinyurl.com/2h6a75nk
wget https://tinyurl.com/vwvram8
wget https://tinyurl.com/weh83uyn
cd ..

echo "Wordcount on tinyurl datasets with hadoop"
{ time hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.1.jar wordcount input_datasets output_hadoop_datasets ; } 2> time_hadoop_datasets_1.txt
sudo rm -r output_hadoop_datasets
{ time hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.1.jar wordcount input_datasets output_hadoop_datasets ; } 2> time_hadoop_datasets_2.txt
sudo rm -r output_hadoop_datasets
{ time hadoop jar /usr/local/hadoop/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.1.jar wordcount input_datasets output_hadoop_datasets ; } 2> time_hadoop_datasets_3.txt


echo "Installing spark"
wget https://dlcdn.apache.org/spark/spark-3.3.1/spark-3.3.1-bin-hadoop3.tgz
tar -xvzf spark-3.3.1-bin-hadoop3.tgz
sudo mv spark-3.3.1-bin-hadoop3 /usr/local/spark
sudo rm -r spark-3.3.1-bin-hadoop3.tgz
export SPARK_HOME=/usr/local/spark
export PATH=$PATH:$SPARK_HOME/bin:$SPARK_HOME/sbin
export PYSPARK_PYTHON=/usr/bin/python3

echo "Wordcount on tinyurl datasets with pyspark"
{ time spark-submit Wordcount/wordcount_spark.py input_datasets output_spark_datasets ; } 2> time_spark_datasets_1.txt
sudo rm -r output_spark_datasets
{ time spark-submit Wordcount/wordcount_spark.py input_datasets output_spark_datasets ; } 2> time_spark_datasets_2.txt
sudo rm -r output_spark_datasets
{ time spark-submit Wordcount/wordcount_spark.py input_datasets output_spark_datasets ; } 2> time_spark_datasets_3.txt

#echo "Run friends.py"
#spark-submit friends.py