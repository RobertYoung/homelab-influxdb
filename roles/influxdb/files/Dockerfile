FROM debian:12

RUN apt-get update && \
  apt-get install -y curl zip unzip less vim tar mosquitto-clients

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip && \
  ./aws/install && \
  rm -rf awscliv2.zip aws

RUN curl -sL https://dl.influxdata.com/influxdb/releases/influxdb2-client-2.7.5-linux-amd64.tar.gz -o influxdb2-client.tar.gz && \
  tar xvzf ./influxdb2-client.tar.gz && \
  mv ./influx /usr/local/bin/ && \
  rm -rf influxdb2-client.tar.gz influxdb2-client-2.7.5-linux-amd64

COPY backup.sh .

RUN chmod +x backup.sh

