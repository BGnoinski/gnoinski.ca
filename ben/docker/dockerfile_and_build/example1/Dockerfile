FROM ubuntu:18.04
ENV foo /bar
RUN mkdir ${foo}
COPY Dockerfile ${foo}/
WORKDIR ${foo}
RUN pwd
