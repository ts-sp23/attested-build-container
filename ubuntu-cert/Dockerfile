FROM ubuntu:20.04

RUN apt-get update && apt-get -y upgrade && apt-get install -y ca-certificates 
COPY mitmproxy-ca-cert.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates
