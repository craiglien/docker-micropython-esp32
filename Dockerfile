FROM ubuntu:18.04 as espbuild

# Here we use Odditive's fork of micropython. Feel free to change it to the official one:
# https://github.com/micropython/micropython.git

ARG REPOSITORY=https://github.com/odditive/micropython
ARG BRANCH=master
ARG VERSION=5c88c5996dbde6208e3bec05abc21ff6cd822d26

RUN apt-get update \
  && apt-get install -y gcc git wget make libncurses-dev flex bison gperf python python-pip python-setuptools python-serial python-cryptography python-future python-pyparsing python-pyelftools \
  jove

RUN apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && useradd micropython

# Get dev framework
RUN mkdir -p esp && git clone https://github.com/espressif/esp-idf.git \
  && cd esp-idf && git checkout $VERSION && git submodule update --init --recursive

# Get Micropython
RUN git clone $REPOSITORY

RUN cd /micropython  \
  && git checkout $BRANCH && git pull origin $BRANCH 

RUN chown -R micropython:micropython ../esp-idf ../micropython ../esp

#RUN pip install pyserial

USER micropython

ENV ESPIDF=/esp-idf

# Build the cross compiler
RUN cd micropython && make -C mpy-cross

RUN cd micropython && git submodule init lib/berkeley-db-1.xx && git submodule update

RUN cd esp && wget https://dl.espressif.com/dl/xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
RUN cd esp && mkdir xtensa-esp32-elf\
  && tar -xzf ./xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz -C ./xtensa-esp32-elf

ENV PATH=/esp/xtensa-esp32-elf/xtensa-esp32-elf/bin:$PATH

USER root

ADD modules/picoweb /micropython/ports/esp32/modules/picoweb
ADD modules/pkg_resources.py /micropython/ports/esp32/modules/

ADD modules/uasyncio /micropython/ports/esp32/modules/uasyncio
ADD modules/uio.py /micropython/ports/esp32/modules/
ADD modules/ulogging.py /micropython/ports/esp32/modules/

ADD main.c /micropython/ports/esp32/main.c

# show modules
RUN ls -al /micropython/ports/esp32/m*

RUN cd /micropython/ports/esp32 && make
RUN ls -al /micropython/ports/esp32/b*/*.bin

