from gcr.io/datamechanics/spark:platform-3.1-dm14

ENV PYSPARK_MAJOR_PYTHON_VERSION=3

RUN wget  https://jdbc.postgresql.org/download/postgresql-42.2.5.jar
RUN mv postgresql-42.2.5.jar /opt/spark/jars

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY friends.py friends.py
COPY soc-LiveJournal1Adj.txt soc-LiveJournal1Adj.txt

CMD [ "python3", "friends.py"]