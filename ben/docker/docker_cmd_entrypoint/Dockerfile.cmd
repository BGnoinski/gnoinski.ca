FROM ubuntu:18.04
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y curl
RUN apt-get install -y nginx-light
CMD ["nginx", "-g", "daemon off;"]