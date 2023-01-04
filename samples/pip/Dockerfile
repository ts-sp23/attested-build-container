FROM ubuntu:20.04

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y python3-pip

RUN pip3 install cryptography
