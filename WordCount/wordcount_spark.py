import sys
import time
from pyspark import SparkContext, SparkConf

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: wordcount <input file> <output file>", file=sys.stderr)
        sys.exit(-1)
    
    conf = SparkConf().setAppName("wordcount").setMaster("local")
    sc = SparkContext(conf=conf)
    
    text_file = sc.textFile(sys.argv[1])
    counts = text_file.flatMap(lambda line: line.split(" ")) \
                .map(lambda word: (word, 1)) \
                .reduceByKey(lambda a, b: a + b)
    counts.saveAsTextFile(sys.argv[2])