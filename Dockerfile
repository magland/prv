############################################################
# prv
############################################################

# Set the base image to Ubuntu
FROM ubuntu:16.04

# Update the repository sources list
RUN apt-get update

# Install qt5
RUN apt-get install -y software-properties-common
RUN apt-add-repository ppa:ubuntu-sdk-team/ppa
RUN apt-get update
RUN apt-get install -y qtdeclarative5-dev
RUN apt-get install -y qt5-default qtbase5-dev qtscript5-dev make g++

# Install nodejs and npm
RUN apt-get install -y nodejs npm
RUN npm install ini extend

# Make the user
RUN mkdir /home/prvuser
RUN groupadd -r prvuser && \
useradd -r -g prvuser -d /home/prvuser -s /sbin/nologin -c "Docker image user" prvuser && \
chown -R prvuser:prvuser /home/prvuser
RUN apt-get install nano

USER prvuser
WORKDIR /home/prvuser

# Make the source directory
RUN mkdir -p prv
WORKDIR prv

# Compile prv
ADD src src
USER root
RUN chown -R prvuser:prvuser *
USER prvuser
WORKDIR src
RUN qmake
RUN make -j 4
WORKDIR ..

# Add the source files
ADD prv.json.default prv.json.default
ADD prvfileserver prvfileserver
ADD prv.json.default prv.json.default
USER root
RUN chown -R prvuser:prvuser *
RUN ln -s $PWD /base
USER prvuser

ENV path /home/prvuser/prv/bin:$PATH

#CMD ["nodejs","src/mountainfileserver.js"]
