VERSION 0.6

build:
  FROM debian:bullseye
  RUN apt-get update
  RUN apt-get install -y git make gcc sudo g++
  COPY . .
  RUN bash ManualBuild.sh
