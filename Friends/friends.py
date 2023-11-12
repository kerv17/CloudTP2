from pyspark.sql import SparkSession
from itertools import permutations
from operator import add

SUGGESTION_AMOUNT = 10
USERS = ["924", "8941", "8942", "9019", "9020", "9021", "9022", "9990", "9992", "9993"]
INPUT = "soc-LiveJournal1Adj.txt"
OUTPUT = "recommandations.txt"




def parse_line(line):
    line_split = line.split('\t')
    user = int(line_split[0])
    
    if len(line_split) == 1: return []

    friends = line_split[1].split(',')
    mutuals = [(users, (False, 1)) for users in list(permutations(friends, 2))]
    direct = [((user,friend), (True, 1)) for friend in friends]
    return mutuals + direct

def map_line(line):
    connections = sorted(line[1], key=lambda x: x[1], reverse=True)
    return (line[0], connections[:SUGGESTION_AMOUNT])

def reduce_line(user1, user2):
    return (user1[0] or user2[0], user1[1]+user2[1] )


def format_line(user, line):
    print(line)
    usersToRecommend = line
    return f"{user}\t{",".join([str(x[0]) for x in usersToRecommend])}"


if __name__ == "__main__":
    
    spark = SparkSession.builder.master("local").appName("FYMK").getOrCreate()
    sc = spark.sparkContext

    data = sc.textFile(INPUT)

    data = data.flatMap(parse_line) # Parse Text
    data = data.reduceByKey(reduce_line) # Reduce similar connections to one
    data = data.filter(lambda data : data[1][0] == False) # Remove if already friends
    data = data.map(lambda user: (user[0][0],(user[0][1],user[1][1]))) # Change to key = user, data=(friendId, numberOfMutualFriends)
    data = data.groupByKey() # Reduce User
    data = data.map(map_line) # Sort friends
    
    with open(OUTPUT, 'w') as f:
        for user in USERS:
            f.write(format_line(user,data.lookup(user)[0]) + '\n')
    spark.stop()
    #...
