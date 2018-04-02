FROM alpine:latest

COPY requirements.txt /site/requirements.txt

RUN adduser -g '' ben -D
RUN apk update
RUN apk add python3 alpine-sdk bash vim
RUN pip3 install --upgrade pip
RUN pip3 install -r /site/requirements.txt

WORKDIR /site
