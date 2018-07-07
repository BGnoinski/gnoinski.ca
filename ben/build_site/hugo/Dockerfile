FROM ubuntu:18.04

RUN adduser -gecos '' ben --disabled-password
RUN apt-get update
RUN apt-get install -y hugo python3-pip git
RUN pip3 install pygments
WORKDIR /hugo/ben.gnoinski.ca
