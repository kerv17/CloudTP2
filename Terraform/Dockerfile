FROM ubuntu
RUN apt-get update && apt-get install -y wget sudo git time
COPY Data.sh .
RUN chmod +x Data.sh
RUN tr -d '\r' < Data.sh > Data1.sh

CMD ["sh","Data1.sh"]