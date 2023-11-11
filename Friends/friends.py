from pyspark.sql import SparkSession
from itertools import combinations
import copy

SUGGESTION_AMOUNT = 10
USERS = ["924", "8941", "8942", "9019", "9020", "9021", "9022", "9990", "9992", "9993"]

def mutuals(data_line):
    user, friends = data_line
    return [(combo, ('mutual',False)) for combo in list(combinations(friends,2))]
def directs(data_line):
    user, friends = data_line
    return [((user,friend),("direct",True)) for friend in friends]


def parse_line(line):
    line_split = line[0].split('\t')
    user = int(line_split[0])
    #Prevent crashes for missing tab
    if len(line_split) == 1: line_split.append("")
    #Exit if empty string
    if len(line_split[1]) == 0: return (id, [])
    #Convert friends to list of ints
    friends = [int(id) for id in line_split[1].split(',')]
    return (user, friends)

def relations(parsed_line):
    return directs(parsed_line) + mutuals(parsed_line)



def map(line):
    sortedMutuals = sorted(line[1], key=lambda x: x[1], reverse=True)
    return (line[0],sortedMutuals[:SUGGESTION_AMOUNT])

def reduce(A,B):
    return (A[0] or B[0], A[1]+B[1])


if __name__ == "__main__":
    filepath = "soc-LiveJournal1Adj.txt"
    spark = SparkSession.builder.master("local").appName("FYMK").getOrCreate()
    #Map friends from textfile using l
    data = spark.read.text(filepath).rdd.map(lambda line: processInput(line))
    relations = data.flatMap(lambda parsed_line: relations(parsed_line))
    reduced = relations.reduceByKey(reduce).filter(lambda relation: not relation[1][0])
    recommendations = reduced.map(lambda user: (user[0][0],(user[0][1],user[1][1]))).groupByKey().map(map)
    
    
    print("User: <id> Friends : [<id>(<numberOfConnection>)]")
    for user in USERS:
        print("User: " + user + " Friends : ", end = '')
        for friend, connection in data.lookup(user)[0]:
            print(friend+"("+ str(connection) +")", end = ' ')
        print('')

    spark.stop()    